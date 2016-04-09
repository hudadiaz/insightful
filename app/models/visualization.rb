class Visualization < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :datum
  delegate :user, to: :datum, allow_nil: false
  after_initialize :default_values

  validates_presence_of :datum_id

  def modified
    (self.updated_at > self.datum.updated_at ? self : self.datum).updated_at
  end

  private
    def default_values
      self.title ||= datum.name + " " + self.type.humanize
    end
end
