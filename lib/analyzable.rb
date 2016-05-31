module Analyzable

  # find the average price of the passed products
  def average_price(items)
    price_sum = items.inject(0){ |sum, item| sum + item.price.to_f }
    (price_sum / items.size).round(2)
  end

  def print_report(items)
    items.map do |item|
      item.attributes.map { |key,value| "#{key}:#{value}" }.join("   ")
    end.join("\n")
  end

  def count_by_brand(items)
    count_by(items, "brand")
  end

  def count_by_name(items)
    count_by(items, "name")
  end

  private

  # generic count_by method
  def count_by(items, what)
      categories = items.map { |item| eval("item.#{what}") }.uniq
      result = Hash.new
      categories.each do |category| 
        result[category] = items.select { |item| eval("item.#{what}") == category }.length
      end
      result
  end

end
