# frozen_string_literal: true

require "hanami/cli/generators/app/ruby_class_file"
require "hanami/cli/ruby_file_generator"

module Hanami
  module Minitest
    module Generators
      class Mailer
        def initialize(fs:, inflector:)
          @fs = fs
          @inflector = inflector
        end

        def call(key:, namespace:, base_path:)
          ruby_class_file = mailer_ruby_class_file(key:, namespace:, base_path:)
          test_file_path = ruby_class_file.path.gsub(/\.rb$/, "_test.rb")
          mailer_class_name = ruby_class_file.fully_qualified_name

          fs.write(test_file_path, test_content(mailer_class_name))
        end

        private

        attr_reader :fs, :inflector

        def mailer_ruby_class_file(key:, namespace:, base_path:)
          Hanami::CLI::Generators::App::RubyClassFile.new(
            fs: fs,
            inflector: inflector,
            namespace: namespace,
            key: inflector.underscore(key),
            base_path: base_path,
            extra_namespace: "Mailers"
          )
        end

        def test_content(class_name)
          Hanami::CLI::RubyFileGenerator.class(
            "#{class_name}Test",
            header: ["# frozen_string_literal: true", "", 'require "test_helper"'],
            parent_class_name: "Hanami::Minitest::Test",
            body: <<~RUBY.lines(chomp: true)
              # Inspect the delivered message to assert on its contents:
              #
              # assert_equal ["recipient@example.com"], result.message.to
              # assert_equal "Welcome", result.message.subject

              test "delivers" do
                skip "Add assertions for your mailer"

                result = #{class_name}.new.deliver

                assert_predicate result, :success?
              end
            RUBY
          )
        end
      end
    end
  end
end
