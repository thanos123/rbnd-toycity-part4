require_relative 'find_by'
require_relative 'errors'
require 'csv'

class Udacidata
  @@data_path = File.dirname(__FILE__) + "/../data/data.csv"
  
  def self.create(attributes = nil)
    # if(item_exists(attributes))

    # end

    object = self.new(attributes)
    row = object_to_row(object)
    CSV.open(@@data_path, "ab") do |csv|
      csv << row
    end
    object
  end 

  # turns the object into a CSV row, 
  # placing the values in the correct order based on the headers of the CSV file
  def self.object_to_row(object)
    row = []
    headers = get_headers
    headers.each do |header|
      # if the header has the name of the class then look for its name variable
      var_name = header == object.class.name.downcase ? "name" : header
      row << object.instance_variable_get("@#{var_name}")
    end
    row
  end

  # returns the headers of the CSV file
  def self.get_headers  
    data = CSV.read(@@data_path)
    data[0]
  end

  # # returns the data of the CSV file, minus the headers
  # def self.get_data
  #   data = CSV.read(@@data_path)
  #   data.shift
  #   data
  # end

  # def self.get_data_hashes
  #   headers = get_headers
  #   data = get_data
  #   data.map {|a| Hash[ headers.zip(a) ] }
  # end

  # def self.item_exists(attributes)
  #   # headers = get_headers
  #   # data = get_data_hashes
  #   # puts data
  #   # attributes.each do |header, value|
      
  #   # end
  #   false
  # end
end
