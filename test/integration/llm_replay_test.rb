require "test_helper"
require "tmpdir"
require "yaml"
require "debug"

class LLMReplayTest < Minitest::Test
  FIXTURE_DIR  = "tmp/fixtures"
  FIXTURE_PATH = File.join(FIXTURE_DIR, "llm_calls.yml")

  def setup
    # FileUtils.mkdir_p(FIXTURE_DIR)

    # LLMVCR.configure(
    #   fixtures_directory_path: FIXTURE_DIR,
    #   mode: :record
    # )
  end

  def teardown
    # FileUtils.rm_rf(FIXTURE_DIR)
  end

  def test_replays_if_stale
  end
end