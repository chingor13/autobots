require 'test_helper'

class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :issues
end

class IssueSerializer < ActiveModel::Serializer
  attributes :id, :title, :body
end

class ProjectAssembler < Autobots::Assembler
  self.serializer = ProjectSerializer
end

class ActiveRecordTest < ActiveSupport::TestCase
  fixtures :all

  def test_basic
    assembler = ProjectAssembler.new(Project.all)
    data = assembler.roll_out

    assert data.is_a?(Array)
    data.each do |item|
      assert item.is_a?(Hash)
    end

    pp data
  end

end