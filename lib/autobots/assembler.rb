module Autobots
  class Assembler
    class_attribute :serializer
    attr_reader :identifiers, :options, :objects

    def initialize(identifiers, options = {})
      @identifiers, @options = identifiers, options
      @objects = load(identifiers)
    end

    def roll_out
      objects.map{|obj| serializer.new(obj) }.map(&:serializable_hash)
    end

    private

    def load(identifiers)
      identifiers
    end
  end
end