class Visualization < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :datum
end
