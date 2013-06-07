require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../common/adapter_tests', __FILE__)
require File.expand_path('../../../common/adapter_integration_tests', __FILE__)

describe 'Integration with RSpec 2' do
  include AdapterTests
  instance_methods.each do |method_name|
    if method_name =~ /^test_(.+)$/
      it(method_name) { __send__(method_name) }
    end
  end

  include AdapterIntegrationTests

  def assert_equal(expected, actual)
    expect(actual).to eq actual
  end

  def assert_raise(error, message=nil, &block)
    expect(&block).to raise_error(error, message)
  end

  def test_framework_path
    'rspec/autorun'
  end

  def error_test
    <<-EOT
      #{bootstrap}

      describe 'A test' do
        it 'is a test' do
          object = Object.new
          mock(object).foo
        end
      end
    EOT
  end

  def include_adapter_test
    <<-EOT
      #{bootstrap}

      RSpec.configure do |c|
        c.mock_with :rr
      end

      describe 'A test' do
        it 'is a test' do
          object = Object.new
          mock(object).foo
          object.foo
        end
      end
    EOT
  end

  def include_adapter_where_rr_included_before_test_framework_test
    <<-EOT
      #{bootstrap :include_rr_before => true}

      RSpec.configure do |c|
        c.mock_with :rr
      end

      describe 'A test' do
        it 'is a test' do
          object = Object.new
          mock(object).foo
          object.foo
        end
      end
    EOT
  end

  specify "it is still possible to use a custom RSpec-2 adapter" do
    output = run_fixture_tests <<-EOT
      #{bootstrap}

      module RR
        module Adapters
          module RSpec2
            include DSL

            def setup_mocks_for_rspec
              RR.reset
            end

            def verify_mocks_for_rspec
              RR.verify
            end

            def teardown_mocks_for_rspec
              RR.reset
            end

            def have_received(method = nil)
              RR::Adapters::Rspec::InvocationMatcher.new(method)
            end
          end
        end
      end

      RSpec.configure do |c|
        c.mock_with RR::Adapters::RSpec2
      end

      describe 'RR' do
        specify 'mocks work' do
          object = Object.new
          mock(object).foo
          object.foo
        end

        specify 'have_received works' do
          object = Object.new
          stub(object).foo
          object.foo
          object.should have_received.foo
        end
      end
    EOT
    all_tests_should_pass(output)
  end

  describe '#have_received' do
    it "succeeds if the method was called with the given arguments" do
      stub(subject).foobar
      subject.foobar(1, 2)
      expect(subject).to have_received.foobar(1, 2)
    end

    it "fails if the method was called with different arguments" do
      expect {
        expect(subject).to have_received.foobar(1, 2, 3)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end
end
