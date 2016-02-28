class Survey < ActiveRecord::Base
  belongs_to :user

  has_many :questions, :dependent => :destroy
  accepts_nested_attributes_for :questions, :reject_if => lambda { |a| a[:question].blank? }, :allow_destroy => true

  has_many :responses, :dependent => :destroy

  after_initialize :default_values

  private
    def default_values
      self.title ||= "Untitled survey"
    end
end
