class Visualization < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :datum
  delegate :user, to: :datum, :allow_nil => true

  def modified
    (self.updated_at > self.datum.updated_at ? self : self.datum).updated_at
  end

  private
    def default_values
      self.name ||= datum.name
    end
end
