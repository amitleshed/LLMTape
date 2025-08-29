require "test_helper"
require "tmpdir"
require "yaml"
require "debug"

class LLMStaleTest < Minitest::Test
  FIXTURE_DIR  = "tmp/fixtures"
  FIXTURE_PATH = File.join(FIXTURE_DIR, "llm_tapes.yml")

  def setup
    # FileUtils.rm_rf(FIXTURE_DIR)
    FileUtils.mkdir_p(FIXTURE_DIR)

    LLMTape.configure(
      fixtures_directory_path: FIXTURE_DIR,
      mode: :record
    )
  end

  def test_freshness
    request  = { prompt: "I'm" }
    response = { text: "fresh" }

    LLMTape::Services::Record.call(
      description: "Basic LLM Fresh call",
      request:     request,
      response:    response,
      metadata:    { record: "the tape", created_at: (Time.now - 3600).utc.iso8601 },
      path:        FIXTURE_PATH
    )

    assert File.exist?(FIXTURE_PATH), "Fixture file should be created"

    stale = LLMTape::Services::StaleBuster.call("Basic LLM Fresh call", request[:prompt])
    assert_equal false, stale, "Fixture should not be stale"
  end

  def test_staleness
    request  = { prompt: "I'm" }
    response = { text: "stale" }

    LLMTape::Services::Record.call(
      description: "Basic LLM Stale call",
      request:     request,
      response:    response,
      metadata:    { record: "the tape", created_at: (Time.now - (90000 * 31)).utc.iso8601 },
      path:        FIXTURE_PATH
    )

    assert File.exist?(FIXTURE_PATH), "Fixture file should be created"

    stale = LLMTape::Services::StaleBuster.call("Basic LLM Stale call", request[:prompt])
    assert_equal true, stale, "Fixture should be stale"
  end
end