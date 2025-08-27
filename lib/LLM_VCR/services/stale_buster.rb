module LLMVCR
  module Services
    class StaleBuster
      attr_reader :fixture_description

      def initialize()
        @fixture_description = fixture_description
      end

      def call
        # Check yaml for existing
        # if exists check if created_at is < 30 days ago
        # if the new prompt is different than the old one
        # if so, delete the fixture and record a new one
      end
    end
  end
end