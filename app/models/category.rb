class Category < ApplicationRecord
  has_many :types
  belongs_to :gender
end
