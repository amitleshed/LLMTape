# frozen_string_literal: true

require_relative "LLMTape/version"
require_relative "LLMTape/services/record"
require_relative "LLMTape/services/replay"
require_relative "LLMTape/services/stale_buster"
require_relative "LLMTape/services/utilities"

module LLMTape
  DEFAULT_FIXTURES_PATH = "test/fixtures/llm"
  DEFAULT_MODE          = (ENV["LLMTape"] || "auto").to_sym

  class << self
    attr_accessor :fixtures_directory_path, :mode

    def configure(fixtures_directory_path: DEFAULT_FIXTURES_PATH, mode: DEFAULT_MODE)
      self.fixtures_directory_path = fixtures_directory_path.to_s
      self.mode = mode
      FileUtils.mkdir_p(self.fixtures_directory_path)
    end

    def use(description, record: false, request: nil, &block)
      raise ArgumentError, "You must provide a block" unless block_given?
      raise ArgumentError, "Description is required" if description.to_s.strip.empty?

      fixture_path     = File.join(DEFAULT_FIXTURES_PATH, "#{description}.yml")
      current_request  = request || {}
      current_response = block.call

      @operation_mode = record ? :record : mode
      @stale          = Services::StaleBuster.call(description, current_request[:prompt])

      response = Services::Record.call(
        description: description,
        request:     current_request,
        response:    current_response,
        metadata:    { fixture_path:, mode: @operation_mode }
      ) if should_record?

      response = Services::Replay.call(
        description: description,
        request:     current_request
      ) if should_replay?

      response
    end

    private

    def should_replay?
      (@operation_mode == :replay || @operation_mode == :auto) && !@stale
    end

    def should_record?
      @operation_mode == :record || @stale
    end
  end
end
