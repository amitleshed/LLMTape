require "digest"
require "fileutils"
require "yaml"
require "time"

module LLMTape
  module Services
    class Record
      attr_reader :description, :request, :response, :metadata

      def self.call(description:, request:, response:, metadata: {}, path: LLMTape.fixtures_directory_path)
        new(
          description: description,
          request:     request,
          response:    response,
          metadata:    metadata,
          path:        path
        ).call
      end

      def initialize(description:, request:, response:, metadata: {}, path: LLMTape.fixtures_directory_path)
        @description = description
        @request     = request
        @response    = response
        @metadata    = metadata
        @path        = path 
      end

      def call
        generate_fixture
        puts "Recorded fixture: #{@description}"
        LLMTape::Services::Utilities.find_fixture(@path, @description)
      end

      private
      
      def generate_fixture
        # TODO: get created_at out of metadata 

        existing_created_at = @metadata["created_at"] || @metadata[:created_at]
        fixture_data = {
          "description" => @description,
          "data"        => {
            "id"       => generate_hash(@description),
            "request"  => @request,
            "response" => @response,
            "metadata" => @metadata.merge({ :created_at => existing_created_at || Time.now.utc.iso8601 })
          }
        }
      
        fixture_file_path = File.join(
          LLMTape.fixtures_directory_path,
          "llm_calls.yml"
        )
      
        file_exists = File.exist?(fixture_file_path)
        fixtures    = YAML.load_stream(File.read(fixture_file_path)) if file_exists
        fixtures    = [] unless file_exists
      
        existing_index = fixtures.find_index { |f| f["description"] == @description }

        fixtures[existing_index] = fixture_data if existing_index
        fixtures << fixture_data                unless existing_index
      
        File.open(fixture_file_path, "w") do |file|
          fixtures.each { |fixture| file.write(fixture.to_yaml) }
        end
      end

      def generate_hash(description)
        description.downcase.split.join("_") + "_" + Digest::SHA256.hexdigest(description)[0..7]
      end
    end
  end
end