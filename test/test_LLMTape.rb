# frozen_string_literal: true

require "test_helper"

class TestLLMTape < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::LLMTape::VERSION
  end

  def test_it_does_something_useful
    LLMTape.configure(
      fixtures_directory_path: "tmp/fixtures",
      mode: :auto
    )

    assert_equal :auto, LLMTape.mode
  end

  def test_flow
    LLMTape.configure(
      fixtures_directory_path: "tmp/fixtures",
      mode: :auto
    )

    response = LLMTape.use("My second LLM call") do
      { prompt: "Hello, LLM!" }
    end
  end
end
