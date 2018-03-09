class Recommend < ApplicationRecord

  belongs_to :product
  belongs_to :gender
  belongs_to :category
  belongs_to :type

end
