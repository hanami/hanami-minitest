# frozen_string_literal: true

require "erb"

module Hanami
  module Minitest
    module Generators
      # @since 2.0.0
      # @api private
      class Slice
        # @since 2.0.0
        # @api private
        def initialize(fs:, inflector:)
          @fs = fs
          @inflector = inflector
        end

        # @since 2.0.0
        # @api private
        def call(slice)
          context = Struct.new(:slice, :camelized_slice_name).new(
            slice,
            inflector.camelize(slice)
          )

          fs.write("test/slices/#{slice}/action_test.rb", t("action_test.erb", context))

          fs.write("test/slices/#{slice}/actions/.keep", t("keep.erb", context))
        end

        private

        attr_reader :fs

        attr_reader :inflector

        def template(path, context)
          require "erb"

          ERB.new(
            File.read(__dir__ + "/slice/#{path}")
          ).result(context.instance_eval { binding })
        end

        alias_method :t, :template
      end
    end
  end
end
