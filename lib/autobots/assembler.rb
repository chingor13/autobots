module Autobots
  class Assembler
    class_attribute :serializer
    attr_reader :identifiers, :options, :objects

    def initialize(identifiers, options = {})
      @identifiers, @options = identifiers, options
      @objects = assemble(identifiers)
    end

    def data
      roll_out(objects)
    end

    private

    # builds our skeleton resources
    def assemble(identifiers)
      identifiers
    end

    # fetch any additional objects and modify our resources
    def transform(resources)
      resources
    end

    # serialize everything
    def roll_out(objects)
      transform(objects).map{|obj| serializer.new(obj).serializable_hash }
    end

    prepend Helpers::Caching

  end
end