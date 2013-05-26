module RR
  module Integrations
    class RSpec2 < RSpec1
      def name
        'RSpec 2'
      end

      def applies?
        defined?(::RSpec)
      end

      def hook
        ::RSpec.configure do |config|
          config.mock_with Mixin
          config.include RR::API
        end
        patterns = ::RSpec.configuration.backtrace_clean_patterns
        unless patterns.include?(RR::Errors::BACKTRACE_IDENTIFIER)
          patterns.push(RR::Errors::BACKTRACE_IDENTIFIER)
        end
      end
    end
  end
end
