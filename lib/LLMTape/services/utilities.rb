require "yaml"
require "digest"

module LLMTape
  module Backpack
    def self.generate_hash(description)
      require "digest"
      Digest::SHA256.hexdigest(description)[0..7]
    end

    def self.create_file
      fixture_file_path = File.join(
        LLMTape.fixtures_directory_path,
        "llm_tapes.yml"
      )

      FileUtils.mkdir_p(LLMTape.fixtures_directory_path) unless Dir.exist?(LLMTape.fixtures_directory_path)
      FileUtils.touch(fixture_file_path) unless File.exist?(fixture_file_path)
      fixture_file_path
    end

    def self.find_tape(fixture_path, description)
      return nil unless File.exist?(fixture_path)

      fixture_path = File.join(LLMTape.fixtures_directory_path, "llm_tapes.yml")
      create_file unless File.exist?(fixture_path)
      docs = YAML.load_stream(File.read(fixture_path)).compact
      docs = [YAML.safe_load(File.read(fixture_path))].compact if docs.empty?
      target = description.to_s

      docs.find { |doc| (doc["description"] || doc[:description]).to_s == target }
    end
  end
end
