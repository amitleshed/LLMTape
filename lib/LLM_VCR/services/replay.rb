module LLMVCR
  module Services
    class Replay
      attr_reader :description, :request

      def self.call(description:, request:)
        new(
          description: description,
          request:     request
        ).call
      end

      def initialize(description:, request:)
        @description = description
        @request     = request
      end

      def call
        puts "Replaying interaction:"
        puts "Description: #{@description}"
        puts "Request: #{@request}"
      end
    end
  end
end