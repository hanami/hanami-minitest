# frozen_string_literal: true

require "test_helper"

class Hanami::Minitest::Commands::Generate::OperationTest < ::Minitest::Test
  def setup
    @fs = Dry::Files.new
    @subject = Hanami::Minitest::Commands::Generate::Operation.new(fs: @fs)
  end

  def test_generates_test_file_for_app_operation
    within_application_directory do
      @subject.call(name: "books.add")

      operation_test = <<~RUBY
        # frozen_string_literal: true

        require "test_helper"

        class Bookshelf::Books::AddTest < Hanami::Minitest::Test
          # Use `Success` and `Failure` (from test/support/operations.rb) to assert on an operation's
          # wrapped value:
          #
          # assert_equal Success(thing), result

          test "succeeds" do
            skip "Add assertions for your operation"

            result = Bookshelf::Books::Add.new.call

            assert_predicate result, :success?
          end
        end
      RUBY

      assert_equal operation_test, @fs.read("test/books/add_test.rb")
    end
  end

  def test_generates_test_file_for_top_level_operation
    within_application_directory do
      @subject.call(name: "add")

      assert_includes @fs.read("test/add_test.rb"), "class Bookshelf::AddTest < Hanami::Minitest::Test"
    end
  end

  def test_does_not_generate_test_file_when_skip_tests_given
    within_application_directory do
      @subject.call(name: "books.add", skip_tests: true)

      refute @fs.exist?("test/books/add_test.rb")
    end
  end

  def test_generates_test_file_for_slice_operation
    within_application_directory do
      @subject.call(name: "books.add", slice: "main")

      assert_includes @fs.read("test/slices/main/books/add_test.rb"),
        "class Main::Books::AddTest < Hanami::Minitest::Test"
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
