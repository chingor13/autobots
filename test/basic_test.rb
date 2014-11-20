require 'test_helper'

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