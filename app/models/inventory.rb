class Inventory < ApplicationRecord
  acts_as_paranoid

  has_many :counts
  has_and_belongs_to_many :technologies
  has_and_belongs_to_many :users
end