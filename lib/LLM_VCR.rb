# frozen_string_literal: true

require_relative "LLM_VCR/version"
require_relative "LLM_VCR/services/record"
require_relative "LLM_VCR/services/replay"
require_relative "LLM_VCR/services/stale_buster"
require_relative

module LLMVCR
  class Error < StandardError; end

  def self.record(description:, request:, response:, metadata: {})
    LLMVCR::Services::Record.call(
      description: description,
      request: request,
      response: response,
      metadata: metadata
    )
  end

  def self.replay(description:, request:)
    LLMVCR::Services::Replay.call(
      description: description,
      request: request
    )
  end

  def self.stale_buster(description:)
    LLMVCR::Services::StaleBuster.call(
      description: description
    )
  end
end
