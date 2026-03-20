# frozen_string_literal: true

require "test_helper"

class Hanami::Minitest::Commands::Generate::SliceTest < ::Minitest::Test
  def setup
    @fs = Dry::Files.new(memory: true)
    @subject = Hanami::Minitest::Commands::Generate::Slice.new(fs: @fs)
  end

  def test_generates_action_test_file
    @subject.call(name: "main")

    action_test = <<~EXPECTED
      # frozen_string_literal: true

      require "test_helper"

      module Main
        class ActionTest < Hanami::Minitest::Test
          test "pending" do
            skip "Add tests for Main actions"
          end
        end
      end
    EXPECTED

    assert_equal action_test, @fs.read("test/slices/main/action_test.rb")
  end

  def test_generates_actions_keep_file
    @subject.call(name: "main")

    assert_equal "", @fs.read("test/slices/main/actions/.keep")
  end

  def test_generates_files_for_snake_case_slice_name
    @subject.call(name: "my_slice")

    action_test = <<~EXPECTED
      # frozen_string_literal: true

      require "test_helper"

      module MySlice
        class ActionTest < Hanami::Minitest::Test
          test "pending" do
            skip "Add tests for MySlice actions"
          end
        end
      end
    EXPECTED

    assert_equal action_test, @fs.read("test/slices/my_slice/action_test.rb")
    assert_equal "", @fs.read("test/slices/my_slice/actions/.keep")
  end
end
