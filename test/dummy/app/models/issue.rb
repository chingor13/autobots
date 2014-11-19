class Issue < ActiveRecord::Base

  belongs_to :project
  has_many :comments, inverse_of: :issue

end