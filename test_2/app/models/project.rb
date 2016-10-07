class Project < ActiveRecord::Base

  extend Modificators::ModelAttrsEscaper
  include ProjectRepository
  include AccountColor

  scope :by_name, -> (name) { where('name LIKE ?', "%#{name.downcase}%") }
  scope :completed, -> (completed) { where(completed: completed) }
  scope :without_blank_name, -> { where("name <> ''") }

  has_and_belongs_to_many :users

  attr_escaper :name, :first_letter, :notes

end
