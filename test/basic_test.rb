require 'test_helper'

class BasicModelSerializer < ActiveModel::Serializer

  attributes :id, :name
  has_many :bars

end

class BasicModelAssembler < Autobots::Assembler
  self.serializer = BasicModelSerializer
end

class BasicModel
  include ActiveModel::Model
  include ActiveModel::SerializerSupport

  attr_accessor :id, :name

  def bars
    []
  end
end

class BasicTest < ActiveSupport::TestCase

  def test_basic_model
    objs = [1,2,3].map do |i|
      BasicModel.new({
        id: i,
        name: "Model: #{i}"
      })
    end
    assembler = BasicModelAssembler.new(objs)

    data = assembler.data

    assert data.is_a?(Array)
    data.each do |item|
      assert item.is_a?(Hash)
    end
  end

end