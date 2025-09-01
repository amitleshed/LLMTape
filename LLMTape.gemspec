# frozen_string_literal: true

require_relative "lib/LLMTape/version"

Gem::Specification.new do |spec|
  spec.name = "LLMTape"
  spec.version = LLMTape::VERSION
  spec.authors = ["Amit Leshed"]
  spec.email = ["amitleshed@icloud.com"]

  spec.summary = "LLMTape is a lightweight Ruby gem for testing code that calls Large Language Models. It works like a cassette tape: record an API call once, then replay it forever."
  spec.description = "It wraps any LLM client with a tiny DSL. In test environement, it records “tapes” (YAML fixtures of real LLM calls) and replays them on subsequent runs; when a tape is stale, it re-records to keep tests current. Production stays clean and safe, while CI avoids hammering the API every run--yielding deterministic tests, faster pipelines, and fewer tokens spent."
  spec.homepage = "https://www.amitleshed.com"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://www.amitleshed.com"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
