module RR
  module Integrations
    class TestUnit2ActiveSupport
      def initialize
        @tu2_adapter = TestUnit2.new
      end

      def name
        'Test::Unit 2 w/ ActiveSupport'
      end

      def applies?
        @tu2_adapter.applies? && defined?(::ActiveSupport::TestCase)
      end

      def hook
        RR.trim_backtrace = true
        RR.overridden_error_class = ::Test::Unit::AssertionFailedError

        ::ActiveSupport::TestCase.class_eval do
          include RR::DSL
          include TestUnit1::Mixin

          setup do
            RR.reset
          end

          teardown do
            RR.verify
          end
        end
      end
    end
  end
end
