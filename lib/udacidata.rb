require_relative 'find_by'
require_relative 'errors'
require 'csv'

class Udacidata
  @@data_path = File.dirname(__FILE__) + "/../data/data.csv"
  @@headers = []
  
  # creates a new object and saves it if it doesn't exist in the CSV file 
  def self.create(attributes={})
    return self.new(attributes) if item_exists?(attributes)
    object = self.new(attributes)
    add_to_csv(object)
    object
  end 

  # returns an array of all objects in the database
  def self.all
    get_data_hashes.map {|item| self.create(item) }
  end 


  # returns the "n" number of first objects from the database
  def self.first(n=1)
    # create new objects if n less than data length
    (n-all.length).times { self.create }
    return n == 1 ? all.first : all.first(n)
  end 

  # returns the "n" number of last objects from the database
  def self.last(n=1)
    # create new objects if n less than data length
    (n-all.length).times { self.create }
    return n == 1 ? all.last : all.last(n)
  end 

  # finds a product by id, or creates it if it doesn't exist
  def self.find(id)
    item = all.find { |item| item.id == id }
    return item == nil ? self.new({id: id}) : item
  end

  # deletes the entry with id
  def self.destroy(id)
    object = find(id)
    delete_from_csv(object)
  end

  # finds all products with the passed condition
  def self.where(options={})
    all.select do |item|
      eval("item.#{options.keys[0]}") == options.values[0]
    end
  end

  # updates the item in the database
  def update(options={})
    options.each do |key,value|
      self.instance_variable_set("@#{key}", value)
    end
    self.class.destroy(self.id)
    self.class.create(self.attributes)
  end

  # method that converts the instance variables to a Hash
  def attributes
    self.instance_variables.each_with_object({}) do |var, hash| 
      hash[var.to_s.delete("@").to_sym] = self.instance_variable_get(var)
    end
  end

  def self.method_missing(method_name, *arguments)
    if method_name.to_s.start_with?('find_by_')
      # get the substring after "find_by", which is what we are trying to find
      field = method_name.to_s[8..-1]
      return all.find { |item| eval("item.#{field}") == arguments[0] }
    else
      puts "No method named #{method_name}"
      super
    end
  end

  private

  # turns the object into a CSV row, 
  # placing the values in the correct order based on the headers of the CSV file
  def self.object_to_row(object)
    row = []
    get_headers.each do |header|
      header = header == self.name.downcase ? "name" : header
      row << object.instance_variable_get("@#{header}").to_s
    end
    row
  end

  # returns the headers of the CSV file
  def self.get_headers
    return @@headers if @@headers != []
    @@headers = CSV.read(@@data_path).first
  end

  # returns the data of the CSV file, minus the headers
  def self.get_data
    CSV.read(@@data_path).drop(1)
  end

  # saves all data to the CSV file
  # it leaves the file completely empty if destroy is set to true and there is no data
  def self.save_data(rows)
    headers = get_headers
    CSV.open(@@data_path, "wb") do |csv|
      csv << headers
      rows.each { |row| csv << row }
    end
  end

  # combines the data and the headers into an array of hashes
  def self.get_data_hashes
    # if the header has the class name, change it to "name"
    headers = get_headers.map do |header|
      header == self.name.downcase ? "name" : header
    end
    get_data.map {|a| Hash[ headers.map { |x| x.to_sym }.zip(a) ] }
  end

  # checks if an item with the passed attributes exists in the database
  def self.item_exists?(attributes)
    return false if attributes == {}
    get_data_hashes.each do |data_hash|
      # remove the elements of the hash whose keys are not present in the attributes hash
      filtered_hash = data_hash.select { |key,_| attributes.keys.include? key }
      return true if filtered_hash == attributes
    end
    false
  end

  # adds a single entry to the CSV file
  def self.add_to_csv(object)
    CSV.open(@@data_path, "ab") do |csv|
      csv << object_to_row(object)
    end
  end

  # deletes a single object from the CSV
  def self.delete_from_csv(object)
    rows = get_data
    rows.delete_if{ |row| object_to_row(object) == row }
    save_data(rows)
    object
  end

end
