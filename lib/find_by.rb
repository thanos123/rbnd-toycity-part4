class Module
  def create_finder_methods(*attributes)
    attributes.each do |attribute|
      find_method = %Q{
         def self.find_by_#{attribute}(value)
            return all.find { |item| item.#{attribute} == value }
         end
      }
      self.class_eval(find_method) if ! self.respond_to?("find_by_#{attribute}")
    end
  end
end
