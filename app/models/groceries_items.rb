class GroceriesItems < ActiveRecord::Base
  belongs_to :item
  belongs_to :grocery

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
end
