# frozen_string_literal: true

require "erb"

module Hanami
  module Minitest
    module Generators
      # @since 2.1.0
      # @api private
      class Part
        # @since 2.1.0
        # @api private
        def initialize(fs:, inflector:)
          @fs = fs
          @inflector = inflector
        end

        # @since 2.1.0
        # @api private
        def call(app, slice, name)
          context = Struct.new(
            :camelized_app_name,
            :camelized_slice_name,
            :camelized_name,
            :underscored_name
          ).new(
            inflector.camelize(app),
            slice ? inflector.camelize(slice) : nil,
            inflector.camelize(name),
            inflector.underscore(name)
          )

          if slice
            generate_for_slice(slice, context)
          else
            generate_for_app(context)
          end
        end

        private

        # @since 2.1.0
        # @api private
        def generate_for_slice(slice, context)
          generate_base_part_for_app(context)
          generate_base_part_for_slice(context, slice)

          fs.write(
            "test/slices/#{slice}/views/parts/#{context.underscored_name}_test.rb",
            t("part_slice_test.erb", context)
          )
        end

        # @since 2.1.0
        # @api private
        def generate_for_app(context)
          generate_base_part_for_app(context)

          fs.write(
            "test/views/parts/#{context.underscored_name}_test.rb",
            t("part_test.erb", context)
          )
        end

        # @since 2.1.0
        # @api private
        def generate_base_part_for_app(context)
          path = fs.join("test", "views", "part_test.rb")
          return if fs.exist?(path)

          fs.write(
            path,
            t("part_base_test.erb", context)
          )
        end

        # @since 2.1.0
        # @api private
        def generate_base_part_for_slice(context, slice)
          path = "test/slices/#{slice}/views/part_test.rb"
          return if fs.exist?(path)

          fs.write(
            path,
            t("part_slice_base_test.erb", context)
          )
        end

        # @since 2.1.0
        # @api private
        attr_reader :fs

        # @since 2.1.0
        # @api private
        attr_reader :inflector

        # @since 2.1.0
        # @api private
        def template(path, context)
          require "erb"

          ERB.new(
            File.read(__dir__ + "/part/#{path}"),
            trim_mode: "-"
          ).result(context.instance_eval { binding })
        end

        # @since 2.1.0
        # @api private
        alias_method :t, :template
      end
    end
  end
end
