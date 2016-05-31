module Analyzable

  # find the average price of the passed products
  def average_price(products)
    price_sum = products.inject(0){ |sum, product| sum + product.price.to_f }
    (price_sum / products.size).round(2)
  end
end
