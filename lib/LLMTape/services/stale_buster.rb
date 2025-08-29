require "yaml"
require "debug"

module LLMTape
  module Services
    class StaleBuster
      def self.call(description, current_prompt)
        @current_prompt = current_prompt
        @description    = description

        stale?(current_prompt: @current_prompt)
      end

      private

      def self.stale?(current_prompt:)
        return true unless file_exists?
      
        fixture = LLMTape::Services::Utilities.find_fixture(fixture_path, @description)
        return true unless fixture
      
        created_at  = fixture.dig("data", "metadata", :created_at)&.to_s
        return true unless created_at
      
        created_time = Time.parse(created_at) rescue nil
        return true unless created_time
      
        too_old      = (Time.now - created_time) > 30*24*60*60
        prompt_diff  = fixture.dig("data", "request", :prompt).to_s != current_prompt.to_s
      
        too_old || prompt_diff
      end
      

      def self.fixture_path
        File.join(
          LLMTape.fixtures_directory_path,
          "llm_calls.yml"
        )
      end

      def self.file_exists?
        File.exist?(fixture_path)
      end
    end
  end
end