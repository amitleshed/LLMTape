require "yaml"
require "digest"

module LLMVCR
  module Services
    class Utilities
      def self.generate_hash(description)
        require "digest"
        Digest::SHA256.hexdigest(description)[0..7]
      end

      def self.find_fixture(fixture_path, description)
        return nil unless File.exist?(fixture_path)

        docs = YAML.load_stream(File.read(fixture_path)).compact
        docs = [YAML.safe_load(File.read(fixture_path))] if docs.empty?

        target = description.to_s
        docs.find { |doc| (doc["description"] || doc[:description]).to_s == target }
      end
    end
  end
end
