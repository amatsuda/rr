require File.expand_path('../../spec_helper', __FILE__)

describe 'mock' do
  def self.include_tests(&block)
    specify "TimesCalledError is raised at the verify step if the method is never called" do
      object = build_object_with_possible_method(:some_method)
      mock(object).some_method
      expect { RR.verify }.to raise_error(RR::Errors::TimesCalledError)
    end

    context 'with a times-called qualifier' do
      context 'upon verification after the method is called too few times' do
        specify "TimesCalledError is raised" do
          object = build_object_with_possible_method(:some_method)
          mock(object).some_method.times(2)
          object.some_method
          expect { RR.verify }.to raise_error(RR::Errors::TimesCalledError)
        end

        specify "nothing happens upon being reset" do
          object = build_object_with_possible_method(:some_method)
          mock(object).some_method.times(2)
          RR.reset
          call_possible_method_on(object, :some_method)
          call_possible_method_on(object, :some_method)
          expect { RR.verify }.not_to raise_error
        end
      end

      context 'as soon as the method is called one too many times' do
        specify "TimesCalledError is raised" do
          object = build_object_with_possible_method(:some_method)
          mock(object).some_method.times(2)
          call_possible_method_on(object, :some_method)
          call_possible_method_on(object, :some_method)
          expect { object.some_method }.to raise_error(RR::Errors::TimesCalledError)
          RR.reset
        end

        specify "nothing happens upon being reset" do
          object = build_object_with_possible_method(:some_method)
          mock(object).some_method.times(2)
          RR.reset
          call_possible_method_on(object, :some_method)
          call_possible_method_on(object, :some_method)
          expect {
            call_possible_method_on(object, :some_method)
          }.not_to raise_error
        end
      end
    end

    context 'with a never-called qualifier' do
      it "works as long as the method is never called" do
        object = build_object_with_possible_method(:some_method)
        mock(object).some_method.never
      end

      specify "TimesCalledError is raised as soon as the method is called" do
        object = build_object_with_possible_method(:some_method)
        mock(object).some_method.never
        expect { object.some_method }.to raise_error(RR::Errors::TimesCalledError)
        RR.reset
      end

      specify "nothing happens upon being reset" do
        object = build_object_with_possible_method(:some_method)
        mock(object).some_method.never
        RR.reset
        expect {
          call_possible_method_on(object, :some_method)
        }.not_to raise_error
      end
    end

    context 'setting implementation' do
      it "without giving a block is the same as returning nil" do
        object = build_object_with_possible_method(:some_method) { 'value' }
        mock(object).some_method
        expect(object.some_method).to eq nil
      end

      context 'by giving a block' do
        it "works" do
          method_called = false
          object = build_object_with_possible_method(:some_method) { 'value' }
          mock(object).some_method { method_called = true; 'bar' }
          expect(object.some_method).to eq 'bar'
          expect(method_called).to eq true
        end

        it "is reset correctly" do
          method_called = false
          object = build_object_with_possible_method(:some_method) { 'existing value' }
          mock(object).some_method { method_called = true; 'new value' }
          RR.reset
          assert_method_value_or_absence('existing value', object, :some_method)
          expect(method_called).to eq false
        end
      end

      context 'by using #returns' do
        it "works" do
          method_called = false
          object = build_object_with_possible_method(:some_method) { 'value' }
          mock(object).some_method.returns { method_called = true; 'bar' }
          expect(object.some_method).to eq 'bar'
          expect(method_called).to eq true
        end

        it "is reset correctly" do
          method_called = false
          object = build_object_with_possible_method(:some_method) { 'existing value' }
          mock(object).some_method.returns { method_called = true; 'new value' }
          RR.reset
          assert_method_value_or_absence('existing value', object, :some_method)
          expect(method_called).to eq false
        end
      end
    end

    context 'mocking invocations of specific argument sets' do
      def self.argument_expectation_tests(&add_argument_expectation)
        context 'with a times-called qualifier' do
          context 'upon verification after the invocation occurs too few times' do
            specify "TimesCalledError is raised" do
              object = build_object_with_possible_method(:some_method)
              add_argument_expectation.call(mock(object), :some_method, 1).times(2)
              call_possible_method_on(object, :some_method, 1)
              expect { RR.verify }.to raise_error(RR::Errors::TimesCalledError)
            end

            specify "nothing happens upon reset" do
              object = build_object_with_possible_method(:some_method)
              add_argument_expectation.call(mock(object), :some_method, 1).times(2)
              RR.reset
              call_possible_method_on(object, :some_method, 1)
              expect { RR.verify }.not_to raise_error
            end
          end

          context 'the moment the invocation occurs one too many times' do
            specify "TimesCalledError is raised" do
              object = build_object_with_possible_method(:some_method)
              add_argument_expectation.call(mock(object), :some_method, 1).times(2)
              call_possible_method_on(object, :some_method, 1)
              call_possible_method_on(object, :some_method, 1)
              expect { object.some_method(1) }.to raise_error(RR::Errors::TimesCalledError)
              RR.reset
            end

            specify "nothing happens upon reset" do
              object = build_object_with_possible_method(:some_method)
              add_argument_expectation.call(mock(object), :some_method, 1).times(2)
              RR.reset
              call_possible_method_on(object, :some_method, 1)
              call_possible_method_on(object, :some_method, 1)
              expect {
                call_possible_method_on(object, :some_method, 1)
              }.not_to raise_error
            end
          end
        end

        context 'with a never-called qualifier' do
          it "works as long as the invocation never occurs" do
            object = build_object_with_possible_method(:some_method)
            add_argument_expectation.call(mock(object), :some_method, 1).never
          end

          it "works as long as the invocation never occurs even if other invocations occur" do
            object = build_object_with_possible_method(:some_method) {|arg| }
            stub(object).some_method
            add_argument_expectation.call(mock(object), :some_method, 1).never
            object.some_method(2)
          end

          specify "TimesCalledError is raised as soon as the invocation occurs" do
            object = build_object_with_possible_method(:some_method)
            add_argument_expectation.call(mock(object), :some_method, 1).never
            expect { object.some_method(1) }.to raise_error(RR::Errors::TimesCalledError)
            RR.reset
          end

          specify "nothing happens upon being reset" do
            object = build_object_with_possible_method(:some_method)
            add_argument_expectation.call(mock(object), :some_method, 1).never
            RR.reset
            expect {
              call_possible_method_on(object, :some_method, 1)
            }.not_to raise_error
          end
        end

        context 'without any extra qualifiers' do
          it "defines the double just for that specific invocation" do
            object = build_object_with_possible_method(:some_method) {|arg| 'value' }
            add_argument_expectation.call(mock(object), :some_method, 1).returns { 'bar' }
            expect(object.some_method(1)).to eq 'bar'
          end

          context 'upon verification after the invocation occurs too few times' do
            specify "TimesCalledError is raised at the verify step if the method is never called at all" do
              object = build_object_with_possible_method(:some_method)
              add_argument_expectation.call(mock(object), :some_method, 1)
              expect { RR.verify }.to raise_error(RR::Errors::TimesCalledError)
            end

            specify "nothing happens upon being reset" do
              object = build_object_with_possible_method(:some_method)
              add_argument_expectation.call(mock(object), :some_method, 1)
              RR.reset
              expect { RR.verify }.not_to raise_error
            end
          end

          context 'the moment the invocation occurs one too many times' do
            specify "DoubleNotFoundError is raised" do
              object = build_object_with_possible_method(:some_method)
              add_argument_expectation.call(mock(object), :some_method, 1)
              expect { object.some_method }.to raise_error(RR::Errors::DoubleNotFoundError)
              RR.reset
            end

            specify "nothing happens upon being reset" do
              object = build_object_with_possible_method(:some_method)
              add_argument_expectation.call(mock(object), :some_method, 1)
              RR.reset
              expect {
                call_possible_method_on(object, :some_method, 1)
              }.not_to raise_error
            end
          end

          it "lets you define a catch-all double by definining a stub without arguments" do
            object = build_object_with_possible_method(:some_method) {|arg| }
            stub(object).some_method
            add_argument_expectation.call(mock(object), :some_method, 1)
            object.some_method(1)
            expect { object.some_method(2) }.not_to raise_error
          end
        end
      end

      context 'by passing arguments to the double definition directly' do
        argument_expectation_tests do |mocked_object, method_name, *args|
          mocked_object.__send__(method_name, *args)
        end
      end

      context 'by using #with and arguments' do
        argument_expectation_tests do |mocked_object, method_name, *args|
          mocked_object.__send__(method_name).with(*args)
        end
      end
    end

    context '#yields' do
      context 'without arguments' do
        it "inserts a yield that passes no arguments" do
          object = build_object_with_possible_method(:some_method)
          mock(object).some_method.yields
          x = 0
          object.some_method { x = 1 }
          expect(x).to eq 1
        end

        it "does not affect setting the implementation otherwise" do
          object = build_object_with_possible_method(:some_method) { 'existing value' }
          mock(object).some_method { 'value' }.yields
          expect(object.some_method { }).to eq 'value'
        end

        it "also lets you set the implementation in preference to #returns" do
          object = build_object_with_possible_method(:some_method) { 'existing value' }
          mock(object).some_method.yields { 'value' }
          expect(object.some_method { }).to eq 'value'
        end

        it "is reset correctly" do
          object = build_object_with_possible_method(:some_method)
          stub(object).some_method.yields
          RR.reset
          x = 0
          if self.class.metadata[:method_exists]
            object.some_method { x = 1 }
            expect(x).to eq 0
          else
            assert_no_method(object, :some_method)
          end
        end
      end

      context 'with arguments' do
        it "inserts a yield that passes those arguments" do
          object = build_object_with_possible_method(:some_method)
          mock(object).some_method.yields(1)
          x = 0
          object.some_method {|a| x = a }
          expect(x).to eq 1
        end

        it "does not affect setting the implementation otherwise" do
          object = build_object_with_possible_method(:some_method) { 'existing value' }
          mock(object).some_method { 'value' }.yields(1)
          expect(object.some_method { }).to eq 'value'
        end

        it "also lets you set the implementation in preference to #returns" do
          object = build_object_with_possible_method(:some_method) { 'existing value' }
          mock(object).some_method.yields(1) { 'value' }
          expect(object.some_method { }).to eq 'value'
        end

        it "is reset correctly" do
          object = build_object_with_possible_method(:some_method)
          mock(object).some_method.yields(1)
          RR.reset
          if self.class.metadata[:method_exists]
            x = 0
            object.some_method {|a| x = a }
            expect(x).to eq 0
          else
            assert_no_method(object, :some_method)
          end
        end
      end
    end

    context 'block form' do
      it "allows multiple methods to be mocked" do
        object = build_object_with_possible_methods(
          :some_method => lambda { 'existing value 1' },
          :another_method => lambda { 'existing value 2' }
        )
        mock(object) do
          some_method { 'value 1' }
          another_method { 'value 2' }
        end
        expect(object.some_method).to eq 'value 1'
        expect(object.another_method).to eq 'value 2'
      end

      it "yields rather than using instance_eval if a block argument is given" do
        object = build_object_with_possible_methods(
          :some_method => lambda { 'existing value 1' },
          :another_method => lambda { 'existing value 2' }
        )
        y = 0
        callable = lambda { y = 1 }
        mock(object) do |o|
          o.some_method { 'value 1' }
          o.another_method { 'value 2' }
          callable.call
        end
        expect(object.some_method).to eq 'value 1'
        expect(object.another_method).to eq 'value 2'
        expect(y).to eq 1
      end
    end

    context 'mocking sequential invocations of a method' do
      it "works" do
        object = build_object_with_possible_method(:some_method)
        mock(object).some_method { 'value 1' }.twice.ordered
        mock(object).some_method { 'value 2' }.once.ordered
        expect(object.some_method).to eq 'value 1'
        expect(object.some_method).to eq 'value 1'
        expect(object.some_method).to eq 'value 2'
      end

      it "works when using #then instead of #ordered" do
        object = build_object_with_possible_method(:some_method)
        mock(object).
          some_method { 'value 1' }.once.then.
          some_method { 'value 2' }.once
        expect(object.some_method).to eq 'value 1'
        expect(object.some_method).to eq 'value 2'
      end
    end

    # btakita/rr issue #44
    context 'when wrapped in an array that is then flattened' do
      it "does not raise an error" do
        object = build_object_with_possible_method(:some_method)
        mock(object).some_method
        object.some_method
        expect([object].flatten).to eq [object]
      end

      it "honors a #to_ary that already exists" do
        object = build_object_with_possible_method(:some_method)
        (class << object; self; end).class_eval do
          def to_ary; []; end
        end
        mock(object).some_method
        object.some_method
        expect([object].flatten).to eq []
      end

      it "is reset correctly" do
        object = build_object_with_possible_method(:some_method)
        mock(object).some_method
        object.some_method   # force RR to define method_missing
        RR.reset
        expect([object].flatten).to eq [object]
      end
    end
  end

  context 'with an instance method', :method_type => :instance do
    context "with a method that exists", :method_exists => true do
      include_tests
    end
    context "with a method that doesn't exist", :method_exists => false do
      include_tests
    end

    # btakita/rr issue #24
    # this happens when defining a double on an ActiveRecord association object
    context 'when the object being stubbed is actually a proxy for another object' do
      it "places the stub on the proxy object and not the target object by mistake" do
        target_object = build_object_with_possible_method(:some_method) { 'existing value' }
        proxy_object = proxy_object_class.new(target_object)
        expect(proxy_object.methods).to match_array(target_object.methods)
        stub(proxy_object).some_method { 'value' }
        expect(proxy_object.some_method).to eq 'value'
      end

      it "is reset correctly" do
        target_object = build_object_with_possible_method(:some_method) { 'existing value' }
        proxy_object = proxy_object_class.new(target_object)
        expect(proxy_object.methods).to match_array(target_object.methods)
        stub(proxy_object).some_method { 'value' }
        RR.reset
        assert_method_value_or_absence('existing value', proxy_object, :some_method)
      end

      def proxy_object_class
        Class.new do
          # This matches what AssociationProxy was like as of Rails 2
          instance_methods.each do |m|
            undef_method m unless m.to_s =~ /^(?:nil\?|send|object_id|to_a)$|^__|^respond_to|proxy_/
          end

          def initialize(target)
            @target = target
          end

          def method_missing(name, *args, &block)
            if @target.respond_to?(name)
              @target.__send__(name, *args, &block)
            else
              super
            end
          end
        end
      end
    end
  end

  context 'with a class method', :method_type => :class do
    context "with a method that exists", :method_exists => true do
      include_tests
    end
    context "with a method that doesn't exist", :method_exists => false do
      include_tests
    end
  end

  def build_object_with_possible_methods(*args)
    if self.class.metadata[:method_exists]
      build_object_with_methods(*args)
    elsif self.class.metadata[:method_type] == :class
      Class.new
    else
      Object.new
    end
  end
  alias :build_object_with_possible_method :build_object_with_possible_methods

  def build_object_with_methods(*args, &block)
    if args[0].is_a?(Symbol)
      methods = { args[0] => (block || lambda {|*args| }) }
    else
      methods = args[0]
    end
    klass = Class.new do
      methods.each do |method_name, implementation|
        define_method(method_name, &implementation)
      end
    end
    klass.new
  end
  alias :build_object_with_method :build_object_with_methods

  def assert_method_value_or_absence(return_value, object, method_name, *args, &block)
    if self.class.metadata[:existing]
      expect(object.__send__(method_name, *args, &block)).to eq return_value
    else
      assert_no_method(object, method_name)
    end
  end

  def assert_no_method(object, method_name)
    expect { object.method_name }.to raise_error(NoMethodError)
    # Commenting this out for now since this is broken.
    # See: <btakita/rr #43
    #expect(object).not_to respond_to(method_name)
  end

  def call_possible_method_on(object, method_name, *args, &block)
    object.__send__(method_name, *args, &block)
  rescue NoMethodError
  end
end