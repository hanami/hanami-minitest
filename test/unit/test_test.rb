# frozen_string_literal: true

require "test_helper"

class Hanami::Minitest::TestTest < ::Minitest::Test
  def test_block_test_method
    klass = Class.new(Hanami::Minitest::Test) do
      test "it works" do
        assert true
      end
    end

    assert_includes klass.instance_methods, :test_it_works
  end

  def test_block_test_method_with_special_characters
    klass = Class.new(Hanami::Minitest::Test) do
      test "it's a test (really)" do
        assert true
      end
    end

    assert_includes klass.instance_methods, :test_it_s_a_test_really
  end

  def test_block_test_raises_when_duplicate_name_given
    assert_raises(RuntimeError) do
      Class.new(Hanami::Minitest::Test) do
        test "duplicate" do; end
        test "duplicate" do; end
      end
    end
  end

  def test_block_test_without_block_defines_a_skipped_test
    klass = Class.new(Hanami::Minitest::Test) do
      test "pending"
    end

    instance = klass.new("test_pending")
    result = instance.run

    assert_predicate result, :skipped?
  end

  def test_block_test_runs_its_block
    klass = Class.new(Hanami::Minitest::Test) do
      test "sets an ivar" do
        @ran = true
        assert @ran
      end
    end

    result = klass.new("test_sets_an_ivar").run
    assert_predicate result, :passed?
  end

  def test_setup_block_runs_before_each_test
    klass = Class.new(Hanami::Minitest::Test) do
      setup do
        @value = 42
      end

      test "sees setup value" do
        assert_equal 42, @value
      end
    end

    result = klass.new("test_sees_setup_value").run
    assert_predicate result, :passed?
  end

  def test_setup_block_runs_after_superclass_setup
    order = []

    parent = Class.new(Hanami::Minitest::Test) do
      define_method(:setup) do
        super()
        order << :parent
      end
    end

    child = Class.new(parent) do
      setup do
        order << :child
      end

      test "check order" do
        assert_equal [:parent, :child], order
      end
    end

    child.new("test_check_order").run
    assert_equal [:parent, :child], order
  end

  def test_teardown_block_runs_after_each_test
    torn_down = []

    klass = Class.new(Hanami::Minitest::Test) do
      teardown do
        torn_down << :done
      end

      test "something" do
        assert true
      end
    end

    klass.new("test_something").run
    assert_equal [:done], torn_down
  end

  def test_teardown_block_runs_before_superclass_teardown
    order = []

    parent = Class.new(Hanami::Minitest::Test) do
      define_method(:teardown) do
        order << :parent
        super()
      end
    end

    child = Class.new(parent) do
      teardown do
        order << :child
      end

      test "check order" do
        assert true
      end
    end

    child.new("test_check_order").run
    assert_equal [:child, :parent], order
  end

  def test_subclass_inherits_class_methods
    klass = Class.new(Hanami::Minitest::Test)

    assert_respond_to klass, :test
    assert_respond_to klass, :setup
    assert_respond_to klass, :teardown
  end
end
