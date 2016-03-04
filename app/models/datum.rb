class Datum < ActiveRecord::Base
  belongs_to :user

  after_initialize :default_values

  def item_count
    content.lines.count - 1
  end

  private
    def default_values
      self.name ||= "Untitled data"
    end
end
