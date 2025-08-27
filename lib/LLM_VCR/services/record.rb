module LLMVCR
  module Services
    class Record
      attr_reader :description, :request, :response, :metadata

      def self.call(description:, request:, response:, metadata: {})
        new(
          description: description,
          request:     request,
          response:    response,
          metadata:    metadata
        ).call
      end

      def initialize(description:, request:, response:, metadata: {})
        @description = description
        @request     = request
        @response    = response
        @metadata    = metadata
      end

      def create_fixture
      end

      def call
        puts "Recording interaction:"
        puts "Description: #{@description}"
        puts "Request: #{@request}"
        puts "Response: #{@response}"
        puts "Metadata: #{@metadata}"

        create_fixture
      end
    end
  end
end