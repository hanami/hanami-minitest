# frozen_string_literal: true

require "test_helper"

class Hanami::Minitest::Commands::Generate::PartTest < ::Minitest::Test
  def setup
    @fs = Dry::Files.new
    @subject = Hanami::Minitest::Commands::Generate::Part.new(fs: @fs)
  end

  # App-level part generation

  def test_generates_base_part_test_file_and_part_test_file_for_app
    within_application_directory do
      @subject.call(name: "client")

      base_part_test = <<~EXPECTED
        # frozen_string_literal: true

        require "test_helper"

        class PartTest < Hanami::Minitest::Test
          setup do
            @value = Object.new
            @subject = Bookshelf::Views::Part.new(value: @value)
          end

          test "works" do
            assert_kind_of Bookshelf::Views::Part, @subject
          end
        end
      EXPECTED
      assert_equal base_part_test, @fs.read("test/views/part_test.rb")

      part_test = <<~EXPECTED
        # frozen_string_literal: true

        require "test_helper"

        class ClientTest < Hanami::Minitest::Test
          setup do
            @value = Object.new
            @subject = Bookshelf::Views::Parts::Client.new(value: @value)
          end

          test "works" do
            assert_kind_of Bookshelf::Views::Parts::Client, @subject
          end
        end
      EXPECTED
      assert_equal part_test, @fs.read("test/views/parts/client_test.rb")
    end
  end

  def test_does_not_overwrite_existing_base_part_test_file_for_app
    within_application_directory do
      @fs.touch("test/views/part_test.rb")

      @subject.call(name: "client")

      assert_equal "", @fs.read("test/views/part_test.rb")

      part_test = <<~EXPECTED
        # frozen_string_literal: true

        require "test_helper"

        class ClientTest < Hanami::Minitest::Test
          setup do
            @value = Object.new
            @subject = Bookshelf::Views::Parts::Client.new(value: @value)
          end

          test "works" do
            assert_kind_of Bookshelf::Views::Parts::Client, @subject
          end
        end
      EXPECTED
      assert_equal part_test, @fs.read("test/views/parts/client_test.rb")
    end
  end

  def test_does_not_generate_test_file_when_skip_tests_given_for_app_part
    within_application_directory do
      @subject.call(name: "client", skip_tests: true)

      refute @fs.exist?("test/views/parts/client_test.rb")
    end
  end

  # Slice-level part generation

  def test_generates_base_part_test_files_and_part_test_file_for_slice
    within_application_directory do
      @subject.call(name: "client", slice: "main")

      base_app_part_test = <<~EXPECTED
        # frozen_string_literal: true

        require "test_helper"

        class PartTest < Hanami::Minitest::Test
          setup do
            @value = Object.new
            @subject = Bookshelf::Views::Part.new(value: @value)
          end

          test "works" do
            assert_kind_of Bookshelf::Views::Part, @subject
          end
        end
      EXPECTED
      assert_equal base_app_part_test, @fs.read("test/views/part_test.rb")

      base_slice_part_test = <<~EXPECTED
        # frozen_string_literal: true

        require "test_helper"

        class PartTest < Hanami::Minitest::Test
          setup do
            @value = Object.new
            @subject = Main::Views::Part.new(value: @value)
          end

          test "works" do
            assert_kind_of Main::Views::Part, @subject
          end
        end
      EXPECTED
      assert_equal base_slice_part_test, @fs.read("test/slices/main/views/part_test.rb")

      part_test = <<~EXPECTED
        # frozen_string_literal: true

        require "test_helper"

        class ClientTest < Hanami::Minitest::Test
          setup do
            @value = Object.new
            @subject = Main::Views::Parts::Client.new(value: @value)
          end

          test "works" do
            assert_kind_of Main::Views::Parts::Client, @subject
          end
        end
      EXPECTED
      assert_equal part_test, @fs.read("test/slices/main/views/parts/client_test.rb")
    end
  end

  def test_does_not_overwrite_existing_base_part_test_files_for_slice
    within_application_directory do
      @fs.touch("test/views/part_test.rb")
      @fs.touch("test/slices/main/views/part_test.rb")

      @subject.call(name: "client", slice: "main")

      assert_equal "", @fs.read("test/views/part_test.rb")
      assert_equal "", @fs.read("test/slices/main/views/part_test.rb")

      part_test = <<~EXPECTED
        # frozen_string_literal: true

        require "test_helper"

        class ClientTest < Hanami::Minitest::Test
          setup do
            @value = Object.new
            @subject = Main::Views::Parts::Client.new(value: @value)
          end

          test "works" do
            assert_kind_of Main::Views::Parts::Client, @subject
          end
        end
      EXPECTED
      assert_equal part_test, @fs.read("test/slices/main/views/parts/client_test.rb")
    end
  end

  def test_does_not_generate_test_file_when_skip_tests_given_for_slice_part
    within_application_directory do
      @subject.call(name: "client", slice: "main", skip_tests: true)

      refute @fs.exist?("test/slices/main/views/parts/client_test.rb")
    end
  end

  private

  def within_application_directory(app: "Bookshelf")
    dir = @fs.join(TMP, SecureRandom.uuid, app)

    @fs.mkdir(dir)
    @fs.chdir(dir) do
      app_code = <<~CODE
        # frozen_string_literal: true

        require "hanami"

        module #{app}
          class App < Hanami::App
          end
        end
      CODE
      @fs.write("config/app.rb", app_code)

      routes = <<~CODE
        # frozen_string_literal: true

        require "hanami/routes"

        module #{app}
          class Routes < Hanami::Routes
            define do
              root { "Hello from Hanami" }
            end
          end
        end
      CODE
      @fs.write("config/routes.rb", routes)

      yield
    end
  ensure
    @fs.delete_directory(dir)
  end
end
