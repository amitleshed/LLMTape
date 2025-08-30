require_relative "../concerns/replay_initializer"

module LLMTape
  module Services
    class Replay
      attr_reader :description, :request

      include LLMTape::Backpack::ReplayInitializer

      def call
        puts "Replaying fixture: #{@description}"

        LLMTape::Backpack.find_tape(@fixture_path, @description) ||
        raise(ArgumentError, "Tape not found for description: #{@description}")
      end
    end
  end
end