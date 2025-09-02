require "test_helper"
require "tmpdir"
require "yaml"
require "debug"

class LLMRedactionTest < Minitest::Test
  def setup
  end

  def test_masks_email_and_key
    input = "contact: amit@company.com, key sk-proj-ABCDEF1234567890"
    out   = LLMTape::Redactor.redact(input)

    assert_match(/a\*+@example\.com/, out)
    assert_includes out, "sk-********"
  end

  def test_plain_replacements_when_keep_lengths_false
    out = LLMTape::Redactor.redact("a@b.com sk-proj-ABCDEF1234567890",
                                   keep_lengths: false)
    assert_includes out, "[EMAIL_REDACTED]"
    assert_includes out, "[API_KEY_REDACTED]"
  end
end