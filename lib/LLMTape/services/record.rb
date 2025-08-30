require "digest"
require "fileutils"
require "yaml"
require "time"
require_relative "../concerns/record_initializer"

module LLMTape
  module Services
    class Record
      attr_reader :description, :request, :response, :metadata

      include LLMTape::Backpack::RecordInitializer

      def call
        generate_fixture
      end

      private
      
      def generate_fixture
        existing_created_at = @metadata["created_at"] || @metadata[:created_at]
        fixture_data        = build_fixture_data(@description, @request, @response, @metadata, existing_created_at)
        file_exists         = File.exist?(file_path)
        fixtures            = file_exists ? YAML.load_stream(File.read(file_path)) : []
        existing_index      = fixtures.find_index { |f| f["description"] == @description }

        fixtures[existing_index] = fixture_data if existing_index
        fixtures << fixture_data                unless existing_index
      
        record_dat_tape(file_path, fixtures, fixture_data)
      end

      def build_fixture_data(description, request, response, metadata, existing_created_at = nil)
        {
          "description" => description,
          "data"        => {
            "id"       => generate_hash(description),
            "request"  => request,
            "response" => response,
            "metadata" => metadata.merge({ :created_at => existing_created_at || Time.now.utc.iso8601 })
          }
        }
      end

      def record_dat_tape(file_path, fixtures, fixture_data)
        File.open(file_path, "w") do |file|
          fixtures.each { |fixture| file.write(fixture.to_yaml) }
        end

        fixture_data
      end

      def generate_hash(description)
        description.downcase.split.join("_") + "_" + Digest::SHA256.hexdigest(description)[0..7]
      end

      def file_path
        fixture_file_path = File.join(
          LLMTape.fixtures_directory_path,
          "llm_tapes.yml"
        )
      end
    end
  end
end