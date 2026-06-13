# frozen_string_literal: true

require "test_helper"

class Hanami::Minitest::Commands::Generate::MailerTest < ::Minitest::Test
  def setup
    @fs = Dry::Files.new
    @subject = Hanami::Minitest::Commands::Generate::Mailer.new(fs: @fs)
  end

  def test_generates_test_file_for_app_mailer
    within_application_directory do
      @subject.call(name: "welcome")

      mailer_test = <<~RUBY
        # frozen_string_literal: true

        require "test_helper"

        class Bookshelf::Mailers::WelcomeTest < Hanami::Minitest::Test
          # Inspect the delivered message to assert on its contents:
          #
          # assert_equal ["recipient@example.com"], result.message.to
          # assert_equal "Welcome", result.message.subject

          test "delivers" do
            skip "Add assertions for your mailer"

            result = Bookshelf::Mailers::Welcome.new.deliver

            assert_predicate result, :success?
          end
        end
      RUBY

      assert_equal mailer_test, @fs.read("test/mailers/welcome_test.rb")
    end
  end

  def test_generates_test_file_for_nested_app_mailer
    within_application_directory do
      @subject.call(name: "notifications.welcome")

      assert_includes @fs.read("test/mailers/notifications/welcome_test.rb"),
        "class Bookshelf::Mailers::Notifications::WelcomeTest < Hanami::Minitest::Test"
    end
  end

  def test_does_not_generate_test_file_when_skip_tests_given
    within_application_directory do
      @subject.call(name: "welcome", skip_tests: true)

      refute @fs.exist?("test/mailers/welcome_test.rb")
    end
  end

  def test_generates_test_file_for_slice_mailer
    within_application_directory do
      @subject.call(name: "welcome", slice: "main")

      assert_includes @fs.read("test/slices/main/mailers/welcome_test.rb"),
        "class Main::Mailers::WelcomeTest < Hanami::Minitest::Test"
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
