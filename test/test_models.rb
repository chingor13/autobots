###########################
# ActiveRecord examples
###########################
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

  def transform(objects)
    ActiveRecord::Associations::Preloader.new(objects, {issues: :comments}).run
    objects
  rescue ArgumentError
    ActiveRecord::Associations::Preloader.new.preload(objects, {issues: :comments})
    objects
  end
end

###########################
# ActiveModel examples
###########################
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