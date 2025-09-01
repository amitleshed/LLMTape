# frozen_string_literal: true

require_relative "LLMTape/version"
require_relative "LLMTape/services/record"
require_relative "LLMTape/services/replay"
require_relative "LLMTape/services/stale_buster"
require_relative "LLMTape/services/utilities"

module LLMTape
  Record      = Services::Record
  Replay      = Services::Replay
  StaleBuster = Services::StaleBuster

  DEFAULT_FIXTURES_PATH = "test/fixtures/llm"
  DEFAULT_MODE          = (ENV["LLMTape"] || "auto").to_sym

  class << self
    attr_accessor :fixtures_directory_path, :mode
    
    def use(description, record: false, request: nil, &block)
      safety_first!(description, &block)
      configure unless fixtures_directory_path
      setup(description, record, request, &block)
      use_tape(description)
    end

    def configure(fixtures_directory_path: DEFAULT_FIXTURES_PATH, mode: DEFAULT_MODE)
      configure_fixtures_directory(fixtures_directory_path:, mode:)
    end

    private

    def safety_first!(description, &block)
      raise ArgumentError, "You must provide a block" unless block_given?
      raise ArgumentError, "Description is required" if description.to_s.strip.empty?
    end

    def setup(description, record, request, &block)
      @fixture_path     = File.join(fixtures_directory_path, "#{description}.yml")
      @current_request  = request || {}
      @current_response = block.call
      @operation_mode   = record ? :record : mode
      @stale            = StaleBuster.call(description, @current_request[:prompt])
    end

    def configure_fixtures_directory(fixtures_directory_path: DEFAULT_FIXTURES_PATH, mode: DEFAULT_MODE)
      self.fixtures_directory_path = fixtures_directory_path.to_s
      FileUtils.mkdir_p(self.fixtures_directory_path)
      self.mode = mode
    end

    def use_tape(description)
      if should_record?
        Record.call(
          description: description,
          request:     @current_request,
          response:    @current_response,
          metadata:    { fixture_path: @fixture_path, mode: @operation_mode }
        )
      elsif should_replay?
        Replay.call(
          description: description,
          request:     @current_request
        )
      end
    end

    def should_replay?
      (@operation_mode == :replay || @operation_mode == :auto) && !@stale
    end

    def should_record?
      @operation_mode == :record || @stale
    end
  end
end
