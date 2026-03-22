# frozen_string_literal: true

require "test_helper"

class Hanami::Minitest::Commands::Generate::ActionTest < ::Minitest::Test
  def setup
    @fs = Dry::Files.new
    @subject = Hanami::Minitest::Commands::Generate::Action.new(fs: @fs)
  end

  def test_generates_test_file_for_app_action
    within_application_directory do
      @subject.call(name: "client.create")

      action_test = <<~EXPECTED
        # frozen_string_literal: true

        require "test_helper"

        class Bookshelf::Actions::Client::CreateTest < Hanami::Minitest::Test
          test "works" do
            params = {}
            response = Bookshelf::Actions::Client::Create.new.call(params)
            assert_predicate response, :successful?
          end
        end
      EXPECTED

      assert_equal action_test, @fs.read("test/actions/client/create_test.rb")
    end
  end

  def test_generates_test_file_for_nested_app_action
    within_application_directory do
      @subject.call(name: "reporting.annual.billing.index")

      action_test = <<~EXPECTED
        # frozen_string_literal: true

        require "test_helper"

        class Bookshelf::Actions::Reporting::Annual::Billing::IndexTest < Hanami::Minitest::Test
          test "works" do
            params = {}
            response = Bookshelf::Actions::Reporting::Annual::Billing::Index.new.call(params)
            assert_predicate response, :successful?
          end
        end
      EXPECTED

      assert_equal action_test, @fs.read("test/actions/reporting/annual/billing/index_test.rb")
    end
  end

  def test_does_not_generate_test_file_when_skip_tests_given_for_app_action
    within_application_directory do
      @subject.call(name: "client.create", skip_tests: true)

      refute @fs.exist?("test/actions/client/create_test.rb")
    end
  end

  def test_generates_test_file_for_slice_action
    within_application_directory do
      @subject.call(name: "client.create", slice: "main")

      action_test = <<~EXPECTED
        # frozen_string_literal: true

        require "test_helper"

        class Main::Actions::Client::CreateTest < Hanami::Minitest::Test
          test "works" do
            params = {}
            response = Main::Actions::Client::Create.new.call(params)
            assert_predicate response, :successful?
          end
        end
      EXPECTED

      assert_equal action_test, @fs.read("test/slices/main/actions/client/create_test.rb")
    end
  end

  def test_does_not_generate_test_file_when_skip_tests_given_for_slice_action
    within_application_directory do
      @subject.call(name: "client.create", slice: "main", skip_tests: true)

      refute @fs.exist?("test/slices/main/actions/client/create_test.rb")
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
