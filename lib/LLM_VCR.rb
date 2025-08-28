# frozen_string_literal: true

require_relative "LLM_VCR/version"
require_relative "LLM_VCR/services/record"
require_relative "LLM_VCR/services/replay"
require_relative "LLM_VCR/services/stale_buster"

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

    def use(fixture_description, record: false, &block)
      raise ArgumentError, "Block is required" unless block_given?
      raise ArgumentError, "Fixture description is required" if fixture_description.nil? || fixture_description.strip.empty?

      fixture_path   = File.join(FIXTURES_DIRECTORY_PATH, "#{fixture_description}.yml")
      operation_mode = record ? :record : mode 

      stale = LLMVCR::Services::StaleBuster.call(
        description: description
      )

      LLMVCR::Services::Record.call(
        description: fixture_description,
        request:     yield,
        response:    nil,
        metadata:    { fixture_path: fixture_path, mode: operation_mode }
      ) if should_record?

      LLMVCR::Services::Replay.call(
        description: fixture_description,
        request:     yield
      ) if should_replay?
    end
  end

  private

  FIXTURES_DIRECTORY_PATH = "test/fixtures/llm"
  MODE                    = (ENV["LLM_VCR"] || "auto").to_sym

  def should_replay?
    (operation_mode == :replay || operation_mode == :auto) && !stale
  end

  def should_record?
    operation_mode == :record || stale
  end
end
