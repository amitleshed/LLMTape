# frozen_string_literal: true

require "test_helper"

class TestLLMVCR < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::LLMVCR::VERSION
  end

  def test_it_does_something_useful
    LLMVCR.configure(
      fixtures_directory_path: "tmp/fixtures",
      mode: :auto
    )

    assert_equal :auto, LLMVCR.mode
  end

  def test_flow
    LLMVCR.configure(
      fixtures_directory_path: "tmp/fixtures",
      mode: :auto
    )

    response = LLMVCR.use("My second LLM call") do
      { prompt: "Hello, LLM!" }
    end
  end
end
