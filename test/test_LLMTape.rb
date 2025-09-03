# frozen_string_literal: true

require "test_helper"

class TestLLMTape < Minitest::Test
  TAPE_FILE = File.join("tmp/fixtures/llm", "llm_tapes.yml")

  def setup
    LLMTape.configure(
      fixtures_directory_path: "tmp/fixtures/llm",
      mode: :auto
    )
  end

  def test_that_it_has_a_version_number
    refute_nil ::LLMTape::VERSION
  end

  def test_it_does_something_useful
    assert_equal :auto, LLMTape.mode
  end

  def test_flow
    prompt = "Hello, LLM!!"
    response = LLMTape.use("My second LLM call", request: {prompt: prompt}) do
      { prompt: prompt }
    end
  end

  def test_tape_not_found
    prompt = "Nobody can ever find this!"
    error  = assert_raises(ArgumentError) do
      LLMTape::Services::Replay.call(description: "Tape to hide ;)", request: {prompt: prompt}).call
    end

    assert_match "Tape not found for description: Tape to hide ;)", error.message
  end

  def test_record_then_replay_in_test_env
    ENV["RAILS_ENV"] = "test"
    FileUtils.rm_f(TAPE_FILE)
  
    first = LLMTape.use("greeting", request: { prompt: "contact: amit@company.com, key sk-proj-ABCDEF1234567890" }) { "hello world" }
    assert_equal "hello world", first["data"]["response"], "Should return live response on first call"
    assert File.exist?(TAPE_FILE), "Tape file should be created"
  
    second = LLMTape.use("greeting", request: { prompt: "contact: amit@company.com, key sk-proj-ABCDEF1234567890" }) { "NEW LIVE VALUE" }
    assert_equal "hello world", second["data"]["response"], "Should replay taped response when fresh"
  end
  
  def test_noop_outside_test_env
    ENV["RAILS_ENV"] = "development"
    FileUtils.rm_f(TAPE_FILE)
  
    value = LLMTape.use("outside_test", request: { prompt: "x" }) { "live call" }
    assert_equal "live call", value, "Should just return live value outside test env"
    refute File.exist?(TAPE_FILE), "Should not create any tape outside test env"
  end
end
