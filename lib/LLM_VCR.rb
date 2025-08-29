# frozen_string_literal: true

require_relative "LLM_VCR/version"
require_relative "LLM_VCR/services/record"
require_relative "LLM_VCR/services/replay"
require_relative "LLM_VCR/services/stale_buster"
require_relative "LLM_VCR/services/utilities"

module LLMVCR
  class << self
    attr_accessor :fixtures_directory_path, :mode

    def configure(
      fixtures_directory_path: FIXTURES_DIRECTORY_PATH,
      mode: MODE
    )

      self.fixtures_directory_path = fixtures_directory_path.to_s
      self.mode = mode
      FileUtils.mkdir_p(self.fixtures_directory_path)
    end

    def use(fixture_description, record: false, request: nil, &block)
      raise ArgumentError, "Block is required" unless block_given?
      raise ArgumentError, "Fixture description is required" if fixture_description.nil? || fixture_description.strip.empty?

      fixture_path    = File.join(FIXTURES_DIRECTORY_PATH, "#{fixture_description}.yml")
      req = request || {}
      res = block.call
      @operation_mode = record ? :record : mode 
      @stale = LLMVCR::Services::StaleBuster.call(fixture_description, req[:prompt])

      LLMVCR::Services::Record.call(
        description: fixture_description,
        request:     req,
        response:    res,
        metadata:    { fixture_path: fixture_path, mode: @operation_mode }
      ) if should_record?

      LLMVCR::Services::Replay.call(
        description: fixture_description,
        request:     req
      ) if should_replay?
    end
  end

  private

  FIXTURES_DIRECTORY_PATH = "test/fixtures/llm"
  MODE                    = (ENV["LLM_VCR"] || "auto").to_sym

  def self.should_replay?
    (@operation_mode == :replay || @operation_mode == :auto) && !@stale
  end

  def self.should_record?
    @operation_mode == :record || @stale
  end
end
