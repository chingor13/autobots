class Project < ActiveRecord::Base

  has_many :issues, inverse_of: :project

end