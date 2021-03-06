require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Adapters
    describe RRMethods do
      subject { Object.new }

      after(:each) do
        RR.reset
      end

      describe "normal strategy definitions" do
        attr_reader :strategy_method_name

        def call_strategy(*args, &block)
          __send__(strategy_method_name, *args, &block)
        end

        describe "#mock" do
          before do
            @strategy_method_name = :mock
          end

          context "when passing no args" do
            it "returns a DoubleDefinitionCreate" do
              expect(call_strategy.class).to eq RR::DoubleDefinitions::DoubleDefinitionCreate
            end
          end

          context "when passed a method_name argument" do
            it "creates a mock Double for method" do
              double_definition = mock(subject, :foobar).returns {:baz}
              expect(double_definition.times_matcher).to eq RR::TimesCalledMatchers::IntegerMatcher.new(1)
              expect(double_definition.argument_expectation.class).to eq RR::Expectations::ArgumentEqualityExpectation
              expect(double_definition.argument_expectation.expected_arguments).to eq []
              expect(subject.foobar).to eq :baz
            end
          end
        end

        describe "#stub" do
          before do
            @strategy_method_name = :stub
          end

          context "when passing no args" do
            it "returns a DoubleDefinitionCreate" do
              expect(call_strategy.class).to eq RR::DoubleDefinitions::DoubleDefinitionCreate
            end
          end

          context "when passed a method_name argument" do
            it "creates a stub Double for method when passed a method_name argument" do
              double_definition = stub(subject, :foobar).returns {:baz}
              expect(double_definition.times_matcher).to eq RR::TimesCalledMatchers::AnyTimesMatcher.new
              expect(double_definition.argument_expectation.class).to eq RR::Expectations::AnyArgumentExpectation
              expect(subject.foobar).to eq :baz
            end
          end
        end

        describe "#dont_allow" do
          before do
            @strategy_method_name = :dont_allow
          end

          context "when passing no args" do
            it "returns a DoubleDefinitionCreate" do
              expect(call_strategy.class).to eq RR::DoubleDefinitions::DoubleDefinitionCreate
            end
          end

          context "when passed a method_name argument_expectation" do
            it "creates a mock Double for method" do
              double_definition = dont_allow(subject, :foobar)
              expect(double_definition.times_matcher).to eq RR::TimesCalledMatchers::NeverMatcher.new
              expect(double_definition.argument_expectation.class).to eq RR::Expectations::AnyArgumentExpectation

              expect {
                subject.foobar
              }.to raise_error(RR::Errors::TimesCalledError)
              RR.reset
            end
          end
        end
      end

      describe "! strategy definitions" do
        attr_reader :strategy_method_name
        def call_strategy(*args, &definition_eval_block)
          __send__(strategy_method_name, *args, &definition_eval_block)
        end

        describe "#mock!" do
          before do
            @strategy_method_name = :mock!
          end

          context "when passed a method_name argument" do
            it "sets #verification_strategy to Mock" do
              proxy = mock!(:foobar)
              expect(proxy.double_definition_create.verification_strategy.class).to eq RR::DoubleDefinitions::Strategies::Verification::Mock
            end
          end
        end

        describe "#stub!" do
          before do
            @strategy_method_name = :stub!
          end

          context "when passed a method_name argument" do
            it "sets #verification_strategy to Stub" do
              proxy = stub!(:foobar)
              expect(proxy.double_definition_create.verification_strategy.class).to eq RR::DoubleDefinitions::Strategies::Verification::Stub
            end
          end
        end

        describe "#dont_allow!" do
          before do
            @strategy_method_name = :dont_allow!
          end

          context "when passed a method_name argument" do
            it "sets #verification_strategy to DontAllow" do
              proxy = dont_allow!(:foobar)
              expect(proxy.double_definition_create.verification_strategy.class).to eq RR::DoubleDefinitions::Strategies::Verification::DontAllow
            end
          end
        end
      end
    end
  end
end
