# frozen_string_literal: true

require "test_helper"

class Hanami::Minitest::Commands::Generate::SliceTest < ::Minitest::Test
  def setup
    @fs = Dry::Files.new
    @subject = Hanami::Minitest::Commands::Generate::Slice.new(fs: @fs)
  end

  def test_generates_action_test_file
    within_application_directory do
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
  end

  def test_generates_actions_keep_file
    within_application_directory do
      @subject.call(name: "main")

      assert_equal "", @fs.read("test/slices/main/actions/.keep")
    end
  end

  def test_generates_files_for_snake_case_slice_name
    within_application_directory do
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

  private

  def within_application_directory(app: "Bookshelf")
    root = @fs.join(TMP, SecureRandom.uuid)
    dir = @fs.join(root, app)

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
    @fs.delete_directory(root)
  end
end
