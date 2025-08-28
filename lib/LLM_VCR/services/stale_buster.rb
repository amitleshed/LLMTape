require "yaml"
require "debug"

module LLMVCR
  module Services
    class StaleBuster
      def self.call(description)
        @description = description

        stale?
      end

      private

      def self.stale?
        return true unless file_exists?

        fixture = LLMVCR::Services::Utilities.find_fixture(fixture_path, @description)
        return true if fixture.nil?
        
        created_at = fixture["data"]["metadata"]["created_at"] || fixture["data"]["metadata"][:created_at]
        return true if created_at.nil?

        created_time = Time.parse(created_at)

        (Time.now - created_time) > (30 * 24 * 60 * 60) # 30 days in seconds
      end

      def self.fixture_path
        File.join(
          LLMVCR.fixtures_directory_path,
          "llm_calls.yml"
        )
      end

      def self.file_exists?
        File.exist?(fixture_path)
      end
    end
  end
end