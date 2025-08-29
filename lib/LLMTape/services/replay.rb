module LLMTape
  module Services
    class Replay
      attr_reader :description, :request

      def self.call(description:, request:, path: File.join(LLMTape.fixtures_directory_path, "llm_calls.yml"))
        new(
          description: description,
          request:     request,
          path:        path
        ).call
      end

      def initialize(description:, request:, path: File.join(LLMTape.fixtures_directory_path, "llm_calls.yml"))
        @description  = description
        @request      = request
        @fixture_path = path
      end

      def call
        puts "Replaying fixture: #{@description}"
        fixture = LLMTape::Services::Utilities.find_fixture(@fixture_path, @description)
      end
    end
  end
end