class Datum < ActiveRecord::Base
  belongs_to :user
  has_many :visualizations, dependent: :destroy
  validates_presence_of :user_id

  after_initialize :default_values
  before_save :retrieve_headers

  def significant_headers
    unless self.ignored.nil? || self.ignored.blank?
      eval(self.headers) - eval(self.ignored)
    else
      eval(self.headers)
    end
  end

  def number_headers
    unless self.numbers.nil? || self.numbers.blank?
      eval(self.numbers)
    else
      []
    end
  end

  def ordinal_and_nominal_headers
    self.significant_headers - self.number_headers
  end

  def csv
    csv_helper
  end

  def items
    items = self.csv

    unless self.ignored.nil? || self.ignored.blank?
      eval(self.ignored).each do |i|
        items.delete i
      end
    end

    items.map {|row| row.to_hash }
  end

  def as_json
    as_json_helper
  end

  private
    def cache_key name
      "datum_"+self.id.to_s+"_"+name
    end

    def csv_helper
      csv = Rails.cache.read(cache_key("csv"))
      if csv.nil? || csv.blank?
        csv = CSV.parse(content, :headers => true)
        Rails.cache.write(cache_key("csv"), csv, expires_in: 3.hours)
      end
      csv
    end

    def as_json_helper
      json = Rails.cache.read(cache_key("json"))
      if json.nil? || json.blank?
        csv = self.csv
        json = {}
        json[:id] = self.id
        json[:name] = self.name
        json[:headers] = self.significant_headers
        json[:numbers] = self.number_headers
        json[:values] = {}
          self.ordinal_and_nominal_headers.each do |h|
            json[:values][h] = csv[h].reject{ |v| v.nil? || v.empty? }.map{ |v| v.strip unless v.nil? }.uniq.sort_by!{ |v| v.downcase }
          end
        json[:items] = self.items
        json[:count] = json[:items].count
        Rails.cache.write(cache_key("json"), json, expires_in: 3.hours)
      end
      json
    end

    def default_values
      self.name ||= "Untitled data"
    end

    def retrieve_headers
      self.headers = CSV.parse(self.content.lines.first).first.to_a
    end

    def assign_name_to_unnamed_headers
      arr = []
      headers = CSV.parse(self.content.lines.first).first
        headers.each_with_index do |h, index|
        if h.empty?
          h = 'unnamed_attribute_'+(index+1).to_s
        end
        arr << h
      end
      self.headers = arr
      
      if self.content.lines.count > 1
        a = "\"" + eval(self.headers).join("\"\,\"") + "\""
        self.content.sub! self.content.lines.first, eval(self.headers).to_csv
      end
    end
end
