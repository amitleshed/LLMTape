module LLMTape
  module Backpack
    module RecordInitializer
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def call(**kwargs)
          new(**defaults.merge(kwargs)).call
        end

        private

        def defaults
          { metadata: {}, path: LLMTape.fixtures_directory_path }
        end
      end

      def initialize(description:, request:, response:, metadata: {}, path: LLMTape.fixtures_directory_path)
        @description = description
        @request     = request
        @response    = response
        @metadata    = metadata
        @path        = path
      end

      attr_reader :description, :request, :response, :metadata, :path
    end
  end
end
