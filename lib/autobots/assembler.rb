module Autobots
  class Assembler
    class_attribute :serializer
    attr_reader :identifiers, :options, :objects

    def initialize(identifiers, options = {})
      @identifiers, @options = identifiers, options
      @objects = assemble(identifiers)
    end

    def data
      return @data if defined?(@data)
      transform
      @data = roll_out
    end

    private

    def assemble(identifiers)
      identifiers
    end

    def transform
    end

    def roll_out
      objects.map{|obj| serializer.new(obj) }.map(&:serializable_hash)
    end
  end
end