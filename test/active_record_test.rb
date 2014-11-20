require 'test_helper'

class ProjectPreloadIncludedAssembler < Autobots::Assembler
  self.serializer = ProjectSerializer
  include Autobots::Helpers::ActiveRecordPreloading

  def preloads
    {issues: :comments}
  end
end

class ProjectIdAssembler < Autobots::Assembler
  self.serializer = ProjectSerializer
  def assemble(identifiers)
    Project.where(id: identifiers).to_a
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

  def test_can_preload_with_mixin
    projects = Project.all
    assembler = ProjectPreloadIncludedAssembler.new(projects)

    data = nil
    assert_queries 3 do
      data = assembler.data
    end

    assert data.is_a?(Array)
    data.each do |item|
      assert item.is_a?(Hash)
    end
  end

  def test_can_use_ids
    project_ids = Project.all.pluck(:id)
    assembler = ProjectIdAssembler.new(project_ids)

    data = nil
    assert_queries 4 do
      data = assembler.data
    end

    assert data.is_a?(Array)
    data.each do |item|
      assert item.is_a?(Hash)
    end
  end

end
