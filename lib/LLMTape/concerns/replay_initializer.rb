module LLMTape
  module Backpack
    module ReplayInitializer
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def call(**kwargs)
          new(**defaults.merge(kwargs)).call
        end

        private

        def defaults
          { path: LLMTape.fixtures_directory_path }
        end
      end

      def initialize(description:, request:, path: File.join(LLMTape.fixtures_directory_path, "llm_tapes.yml"))
        @description  = description
        @request      = request
        @fixture_path = path
      end

      attr_reader :description, :request, :fixture_path
    end
  end
end
