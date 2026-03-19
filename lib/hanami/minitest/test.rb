# frozen_string_literal: true

require "minitest/autorun"

module Hanami
  module Minitest
    # Base test class for Hanami applications.
    #
    # @since 2.0.0
    # @api public
    class Test < ::Minitest::Test
      # Provides class-level block syntax for defining tests, setup, and teardown.
      #
      # @since 2.2.0
      # @api public
      module ClassMethods
        # Defines a test method using a block.
        #
        # @param desc [String] the test description
        # @yieldparam block the test body
        #
        # @example
        #   test "it does something" do
        #     assert true
        #   end
        #
        # @since 2.2.0
        # @api public
        def test(desc = "anonymous", &block)
          block ||= proc { skip "(no tests defined)" }
          name = :"test_#{desc.gsub(/\s+/, "_")}"
          raise "#{name} is already defined in #{self}" if method_defined?(name)

          define_method(name, &block)
        end

        # Defines a setup method using a block.
        #
        # The block runs after any superclass setup, ensuring the framework is
        # fully initialized before your setup code runs.
        #
        # If you need control over when +super+ is called, define a regular
        # +setup+ method instead:
        #
        #   def setup
        #     @subject = MyClass.new
        #     super
        #   end
        #
        # @example
        #   setup do
        #     @subject = MyClass.new
        #   end
        #
        # @since 2.2.0
        # @api public
        def setup(&block)
          define_method(:setup) do
            super()
            instance_exec(&block)
          end
        end

        # Defines a teardown method using a block.
        #
        # The block runs before any superclass teardown, ensuring your cleanup
        # code runs before the framework tears down (e.g. before Capybara resets
        # its session).
        #
        # If you need control over when +super+ is called, define a regular
        # +teardown+ method instead:
        #
        #   def teardown
        #     super
        #     @subject.close
        #   end
        #
        # @example
        #   teardown do
        #     @subject.close
        #   end
        #
        # @since 2.2.0
        # @api public
        def teardown(&block)
          define_method(:teardown) do
            instance_exec(&block)
            super()
          end
        end
      end

      extend ClassMethods
    end
  end
end
