<p align="center">
  <img src="logo_white.png" alt="LLMTape Logo" width="250"/>
</p>

# 🎥 LLMTape

**LLMTape** is a lightweight Ruby gem for testing code that calls Large Language Models.
It works like a cassette tape: record an API call once, then replay it forever.

---

## 🌟 Features

**🎥 Record & Replay** – Capture any LLM API call once, then replay it in future test runs.

**🔒 Deterministic Tests** – Eliminate flaky outputs and unstable CI runs caused by live LLM calls.

**📼 Human-Readable Fixtures** – Responses are stored as YAML “tapes” you can inspect, diff, and commit.

**⚡ Fast & Cheap** – No repeated API calls in CI; only re-record when your prompt or logic changes.

**🧪 Client-Agnostic** – Works with any Ruby LLM client (e.g. ruby_llm), since you wrap the call yourself.

**⏳ Staleness Detection** – Marks a tape as stale if it’s too old or if the prompt has changed.

**🔧 Simple DSL** – Just wrap your LLM call in LLMTape.use("my_call") { ... } and it handles the rest.

**📂 Configurable Storage** – Choose where tapes live (e.g. tmp/fixtures, spec/fixtures/llm).

**🚀 CI-Friendly** – Run in replay mode to avoid network calls and API keys entirely on CI.

---

## 📦 Installation

Add this gem to your application's `Gemfile`:

```bash
gem "LLMTape", "~> 0.1.0" # in your gemfile
bundle add LLMTape        # or through cli
bundle install
```

## ⚙️ Configuration
```ruby
require "llm_tape"

LLMTape.configure(
  fixtures_directory_path: "tmp/fixtures/llm",
  mode: (ENV["LLM_TAPE"] || "auto").to_sym # :record, :replay, or :auto
)
```

## 📖 Usage
```ruby
class LLMTest < Minitest::Test
  def test_three_word_greeting
    prompt = "Say hello in exactly three words."
    result = LLMTape.use("three_word_greeting", request: { prompt: prompt }) do
      RubyLLM.chat.ask(prompt)
    end

    refute_empty result.to_s.strip
  end
end
```

## 🖥️ CLI
```bash
LLM_TAPE=record/replay/auto bundle exec rake test
```

## 🛠 Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## 🤝 Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/LLMTape. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/LLMTape/blob/main/CODE_OF_CONDUCT.md).

## 📜 License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## 🧭 Code of Conduct

Everyone interacting in the LLMTape project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/LLMTape/blob/main/CODE_OF_CONDUCT.md).
