class Style < ApplicationRecord
  has_many :products
  belongs_to :type
end
