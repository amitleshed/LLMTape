require "test_helper"
require "tmpdir"
require "yaml"
require "debug"

class LLMReplayTest < Minitest::Test
  FIXTURE_DIR  = "tmp/fixtures"
  FIXTURE_PATH = File.join(FIXTURE_DIR, "llm_calls.yml")

  def setup
    # FileUtils.mkdir_p(FIXTURE_DIR)

    LLMVCR.configure(
      fixtures_directory_path: FIXTURE_DIR,
      mode: :replay
    )
  end

  def teardown
    # FileUtils.rm_rf(FIXTURE_DIR)
  end

  def test_replay
    request  = { prompt: "hello" }
    response = { text: "hi" }

    new_fixture = LLMVCR::Services::Record.call(
      description: "Basic LLM Call -> Should Record",
      request:     request,
      response:    response,
      metadata:    { record: "the tape" },
      path:        FIXTURE_PATH
    )

    assert_equal new_fixture, LLMVCR::Services::Replay.call(
      description: "Basic LLM Call -> Should Record",
      request:     request
    )
  end
end