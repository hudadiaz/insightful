class Visualization < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :datum
  delegate :user, to: :datum, allow_nil: false
  after_initialize :default_values
  
  has_many :visits
  visitable

  is_impressionable counter_cache: true, column_name: :views_counter_cache, unique: :session_hash

  validates_presence_of :datum_id

  def modified
    (self.updated_at > self.datum.updated_at ? self : self.datum).updated_at
  end

  private
    def default_values
      self.title ||= datum.name + " " + self.type.humanize
    end
end
