# frozen_string_literal: true

require "test_helper"

class TestLLMTape < Minitest::Test
  def setup
    LLMTape.configure(
      fixtures_directory_path: "tmp/fixtures",
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
    prompt = "Hello, LLM!"
    response = LLMTape.use("My second LLM call", request: {prompt: prompt}) do
      { prompt: prompt }
    end
  end
end
