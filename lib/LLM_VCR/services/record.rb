require "digest"
require "fileutils"
require "yaml"
require "time"

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

      def call
        generate_fixture
      end

      private

      def generate_fixture
        fixture_data = {
          "description" => @description,
          "data"        => {
            "id"          => generate_hash(@description),
            "request"     => @request,
            "response"    => @response,
            "metadata"    => @metadata.merge({ "created_at" => Time.now.utc.iso8601 })
          }
        }

        fixture_path = File.join(
          LLMVCR.fixtures_directory_path,
          "llm_calls.yml"
        )

        File.open(fixture_path, "w") do |file|
          file.write(fixture_data.to_yaml)
        end

        puts "Fixture saved to #{fixture_path}"
      end

      def generate_hash(description)
        description.downcase.split.join("_") + "_" + Digest::SHA256.hexdigest(description)[0..7]
      end
    end
  end
end