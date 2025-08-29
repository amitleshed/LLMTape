require "test_helper"
require "tmpdir"
require "yaml"
require "debug"

class LLMRecordTest < Minitest::Test
  FIXTURE_DIR  = "tmp/fixtures"
  FIXTURE_PATH = File.join(FIXTURE_DIR, "llm_calls.yml")

  def setup
    FileUtils.mkdir_p(FIXTURE_DIR)

    LLMTape.configure(
      fixtures_directory_path: FIXTURE_DIR,
      mode: :record
    )
  end

  def test_record_writes_fixture_file
    request  = { prompt: "hello" }
    response = { text: "hi" }

    new_fixture = LLMTape::Services::Record.call(
      description: "Basic LLM call",
      request:     request,
      response:    response,
      metadata:    { record: "the tape" },
      path:        FIXTURE_PATH
    )

    assert File.exist?(FIXTURE_PATH), "Fixture file should be created"

    fixture = LLMTape::Services::Utilities.find_fixture(FIXTURE_PATH, "Basic LLM call")
    assert_equal "Basic LLM call", fixture["description"]
    assert_equal request,          fixture["data"]["request"]
    assert_equal response,         fixture["data"]["response"]
    assert_equal "the tape",       fixture["data"]["metadata"][:record]
    assert_equal new_fixture,      fixture
  end
end