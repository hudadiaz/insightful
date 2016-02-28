class Question < ActiveRecord::Base
  enum type: [:multiple_choice, :checkboxes]
  
  belongs_to :survey

  has_many :options, :dependent => :destroy
  accepts_nested_attributes_for :options, :reject_if => lambda { |a| a[:option].blank? }, :allow_destroy => true

  has_many :responses, :dependent => :destroy
end
