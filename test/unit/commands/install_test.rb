# frozen_string_literal: true

require "test_helper"

class Hanami::Minitest::Commands::InstallTest < ::Minitest::Test
  def setup
    @fs = Dry::Files.new
    @dir = Dir.mktmpdir
    @subject = Hanami::Minitest::Commands::Install.new(fs: @fs)
  end

  def teardown
    @fs.delete_directory(@dir)
  end

  def test_copies_all_test_support_files_with_hanami_db
    within_application_directory do
      Hanami.stub(:bundled?, ->(gem) { ["hanami-db", "hanami-mailer"].include?(gem) }) do
        @subject.call({})
      end

      # Gemfile
      gemfile = <<~EXPECTED
        group :test do
          # Database
          gem "database_cleaner-sequel"

          # Web integration
          gem "capybara"
          gem "rack-test"
        end
      EXPECTED
      assert_includes @fs.read("Gemfile"), gemfile

      # .gitignore
      gitignore = <<~EXPECTED
        .test_results/
      EXPECTED
      assert_includes @fs.read(".gitignore"), gitignore

      # test/test_helper.rb
      test_helper = <<~EXPECTED
        # frozen_string_literal: true

        require "pathname"
        TEST_ROOT = Pathname(__dir__).realpath.freeze

        ENV["HANAMI_ENV"] ||= "test"
        require "hanami/minitest"
        require "hanami/prepare"

        require_relative "support/minitest"
        TEST_ROOT.glob("support/**/*.rb").each { |f| require f }
      EXPECTED
      assert_equal test_helper, @fs.read("test/test_helper.rb")

      # test/support/minitest.rb
      support_minitest = <<~EXPECTED
        # frozen_string_literal: true

        class Hanami::Minitest::Test
          # Add helper methods to be used by all tests here.
        end
      EXPECTED
      assert_equal support_minitest, @fs.read("test/support/minitest.rb")

      # test/support/db.rb
      support_db = <<~EXPECTED
        # frozen_string_literal: true

        require_relative "features"
        require_relative "db/cleaning"

        module TestSupport
          module DB
            def self.included(mod)
              mod.include DB::Cleaning
            end

            # Add helper methods to be used by DB tests here.
          end
        end

        class FeatureTest
          include TestSupport::DB
        end
      EXPECTED
      assert_equal support_db, @fs.read("test/support/db.rb")

      # test/support/db/cleaning.rb
      support_db_cleaning = <<~EXPECTED
        # frozen_string_literal: true

        require "database_cleaner/sequel"

        module TestSupport
          module DB
            module Cleaning
              def self.included(base)
                base.extend(ClassMethods)
              end

              module ClassMethods
                def db_cleaning_with_truncation!
                  @db_cleaning_with_truncation = true
                end

                def js! = db_cleaning_with_truncation!
              end

              def setup
                # Clean all databases before the first test
                Cleaning.once do
                  Cleaning.all_databases.each do |db|
                    DatabaseCleaner[:sequel, db: db].clean_with :truncation, except: ["schema_migrations"]
                  end
                end

                use_truncation = self.class.instance_variable_get(:@db_cleaning_with_truncation)
                strategy = use_truncation ? :truncation : :transaction

                Cleaning.all_databases.each do |db|
                  DatabaseCleaner[:sequel, db: db].strategy = strategy
                  DatabaseCleaner[:sequel, db: db].start
                end

                super
              end

              def teardown
                Cleaning.all_databases.each do |db|
                  DatabaseCleaner[:sequel, db: db].clean
                end

                super
              end

              class << self
                def once
                  @cleaned_once ||= false
                  return if @cleaned_once

                  yield

                  @cleaned_once = true
                end

                def all_databases
                  @all_databases ||= Hanami.app.with_slices.each_with_object([]) { |slice, dbs|
                    next unless slice.key?("db.rom")

                    dbs.concat slice["db.rom"].gateways.values.map(&:connection)
                  }.uniq
                end
              end
            end
          end
        end
      EXPECTED
      assert_equal support_db_cleaning, @fs.read("test/support/db/cleaning.rb")

      # test/support/features.rb
      support_features = <<~EXPECTED
        # frozen_string_literal: true

        class Hanami::Minitest::FeatureTest
          # Add custom feature test helpers here.
        end
      EXPECTED
      assert_equal support_features, @fs.read("test/support/features.rb")

      # test/support/operations.rb
      support_operations = <<~EXPECTED
        # frozen_string_literal: true

        require "dry/monads"

        class Hanami::Minitest::Test
          # Provide `Success` and `Failure` for testing operation results.
          include Dry::Monads[:result]
        end
      EXPECTED
      assert_equal support_operations, @fs.read("test/support/operations.rb")

      # test/support/mailers.rb
      support_mailers = <<~EXPECTED
        # frozen_string_literal: true

        # Reset recorded mail deliveries between tests.
        #
        # In the test env, mail is delivered via a shared test delivery method, so recorded
        # deliveries accumulate across tests. Include this module in any test that sends mail
        # to start with a clean slate:
        #
        #   class Mailers::WelcomeTest < Hanami::Minitest::Test
        #     include TestSupport::Mailers
        #     # ...
        #   end
        module TestSupport
          module Mailers
            def setup
              Hanami.app.with_slices.each do |slice|
                next unless slice.key?("mailers.delivery_method")

                slice["mailers.delivery_method"].clear
              end

              super
            end
          end
        end
      EXPECTED
      assert_equal support_mailers, @fs.read("test/support/mailers.rb")

      # test/support/requests.rb
      support_requests = <<~EXPECTED
        # frozen_string_literal: true

        class Hanami::Minitest::RequestTest
          # Add custom request test helpers here.
        end
      EXPECTED
      assert_equal support_requests, @fs.read("test/support/requests.rb")

      # test/requests/root_test.rb
      root_test = <<~EXPECTED
        # frozen_string_literal: true

        require "test_helper"

        class RootTest < Hanami::Minitest::RequestTest
          test "not found" do
            get "/"

            # Generate new action via:
            #   `bundle exec hanami generate action home.index --url=/`
            assert_equal 404, last_response.status
          end
        end
      EXPECTED
      assert_equal root_test, @fs.read("test/requests/root_test.rb")
    end
  end

  def test_does_not_add_db_gems_or_files_without_hanami_db
    within_application_directory do
      Hanami.stub(:bundled?, ->(_gem) { false }) do
        @subject.call({})
      end

      # Gemfile should use the non-db variant
      gemfile = <<~EXPECTED
        group :test do
          # Web integration
          gem "capybara"
          gem "rack-test"
        end
      EXPECTED
      assert_includes @fs.read("Gemfile"), gemfile

      refute @fs.exist?("test/support/db.rb")
      refute @fs.exist?("test/support/db/cleaning.rb")
      refute @fs.exist?("test/support/mailers.rb")
    end
  end

  private

  def within_application_directory
    @fs.chdir(@dir) do
      @fs.write("Gemfile", "")
      @fs.write(".gitignore", "")
      yield
    end
  end
end
