# frozen_string_literal: true

require "database_cleaner/sequel"

module TestSupport
  module DB
    module Cleaning
      def db_cleaning_with_truncation! = @db_cleaning_with_truncation = true
      def js! = db_cleaning_with_truncation!

      def setup
        # Clean all databases before the first test
        Cleaning.once do
          Cleaning.all_databases.each do |db|
            DatabaseCleaner[:sequel, db: db].clean_with :truncation, except: ["schema_migrations"]
          end
        end

        use_truncation = defined?(@db_cleaning_with_truncation) && @db_cleaning_with_truncation
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
          @all_databases ||= begin
            slices = [Hanami.app] + Hanami.app.slices.with_nested

            slices.each_with_object([]) { |slice, dbs|
              next unless slice.key?("db.rom")

              dbs.concat slice["db.rom"].gateways.values.map(&:connection)
            }.uniq
          end
        end
      end
    end
  end
end
