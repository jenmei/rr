module RR
  # RR::ScenarioCreator is the superclass for all creators.
  class ScenarioCreator
    attr_reader :space, :subject
    def initialize(space, subject)
      @space = space
      @subject = subject
      @strategy = nil
    end
    
    def create!(method_name, *args, &handler)
      @method_name = method_name
      @args = args
      @handler = handler
      @double = @space.double(@subject, method_name)
      @scenario = @space.scenario(@double)
      transform!
      @scenario
    end

    def mock
      @strategy = :mock
    end

    def stub
      @strategy = :stub
    end

    def mock_probe
      @strategy = :mock_probe
    end

    def stub_probe
      @strategy = :stub_probe
    end

    def do_not_call
      @strategy = :do_not_call
    end

    protected
    def transform!
      case @strategy
      when :mock
        @scenario.with(*@args).once.returns(&@handler)
      when :stub
        @scenario.returns(&@handler)
        stub_times_transform!
        permissive_argument_transform!
      when :mock_probe
        @scenario.with(*@args).once
        probe_transform!
      when :stub_probe
        stub_times_transform!
        permissive_argument_transform!
        probe_transform!
      when :do_not_call
        permissive_argument_transform!
        @scenario.never.returns(&@handler)
      end
    end

    def stub_times_transform!
      @scenario.any_number_of_times
    end

    def permissive_argument_transform!
      if @args.empty?
        @scenario.with_any_args
      else
        @scenario.with(*@args)
      end
    end
    
    def probe_transform!
      @scenario.implemented_by_original_method
      @scenario.after_call(&@handler) if @handler
    end
  end
end