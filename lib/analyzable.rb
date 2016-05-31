module Analyzable

  # find the average price of the passed products
  def average_price(products)
    price_sum = products.inject(0){ |sum, product| sum + product.price.to_f }
    (price_sum / products.size).round(2)
  end

  def print_report(products)
    products.map do |product|
      product.name
    end.join("\n")
  end

  # metaprogramming for counting items by...
  def self.method_missing(method_name, *arguments)
    if method_name.to_s.start_with?('count_by_')
      items = arguments[0]
      # get the substring after "count_by"
      field = method_name.to_s[9..-1]
      categories = items.map { |item| eval("item.#{field}") }.uniq
      result = Hash.new
      categories.each do |category| 
        result[category] = items.select { |item| eval("item.#{field}") == category }.length
      end
      return result
    else
      puts "No method named #{method_name}"
      super
    end
  end

end
