class Country < ApplicationRecord
  has_many :districts
  validates :name, presence: true
end
