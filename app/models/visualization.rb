class Visualization < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :datum
  delegate :user, to: :datum, :allow_nil => true

  private
    def default_values
      self.name ||= datum.name
    end
end
