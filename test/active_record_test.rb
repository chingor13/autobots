require 'test_helper'

class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :issues
end

class IssueSerializer < ActiveModel::Serializer
  attributes :id, :title, :body
  has_many :comments
end

class CommentSerializer < ActiveModel::Serializer
  attributes :id, :title, :body
end

class ProjectAssembler < Autobots::Assembler
  self.serializer = ProjectSerializer
end

class ProjectPreloadAssembler < Autobots::Assembler
  self.serializer = ProjectSerializer

  def transform
    ActiveRecord::Associations::Preloader.new(objects, {issues: :comments}).run
  rescue ArgumentError
    ActiveRecord::Associations::Preloader.new.preload(objects, {issues: :comments})
  end
end

class ActiveRecordTest < ActiveSupport::TestCase
  fixtures :all

  def test_basic
    projects = Project.all
    assembler = ProjectAssembler.new(projects)

    data = nil
    assert_queries 5 do
      data = assembler.data
    end

    assert data.is_a?(Array)
    data.each do |item|
      assert item.is_a?(Hash)
    end
  end

  def test_can_preload
    projects = Project.all
    assembler = ProjectPreloadAssembler.new(projects)

    data = nil
    assert_queries 3 do
      data = assembler.data
    end

    assert data.is_a?(Array)
    data.each do |item|
      assert item.is_a?(Hash)
    end
  end

  protected

  def assert_queries(count = 1)
    QueryCounter.clear!
    yield
    assert_equal count, QueryCounter.count, "expected to have #{count} sql queries"
  end

end
