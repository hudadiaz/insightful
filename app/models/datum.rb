class Datum < ActiveRecord::Base
  belongs_to :user
  has_many :visualizations, dependent: :destroy
  validates_presence_of :user_id, :content

  after_initialize :default_values
  before_save :retrieve_headers
  after_update :reload_cache
  before_destroy :clear_cache

  def significant_headers
    headers = []
    unless self.ignored.nil? || self.ignored.blank?
      headers = eval(self.headers) - eval(self.ignored)
    else
      headers = eval(self.headers)
    end
    headers.reject { |e| e.nil? || e.blank? }
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

    to_remove = (eval(self.headers) - significant_headers)
    unless to_remove.nil? || to_remove.blank?
      to_remove.each do |i|
        items.delete key_gen(eval(self.headers).index(i))
      end
    end

    items.map {|row| row.to_hash }
  end

  def as_json
    as_json_helper
  end

  private
    def reload_cache
      clear_cache
      as_json_helper
    end

    def clear_cache
      Rails.cache.write(cache_key("csv"), nil)
      Rails.cache.write(cache_key("json"), nil)
    end

    def cache_key name
      "datum_"+self.id.to_s+"_"+name
    end

    def csv_helper
      csv = Rails.cache.read(cache_key("csv"))
      if csv.nil? || csv.blank?
        csv = CSV.parse(content, headers: true, header_converters: header_converter, converters: lambda{ |v| v.strip unless v.nil? })
        Rails.cache.write(cache_key("csv"), csv)
      end
      csv
    end

    def header_converter
      lambda { |h, index| key_gen index.index unless h.nil? }
    end

    def as_json_helper
      json = Rails.cache.read(cache_key("json"))
      if json.nil? || json.blank?
        csv = self.csv
        json = {}
        json[:id] = self.id
        json[:name] = self.name
        json[:header_keys] = header_keys
        json[:numbers] = self.number_headers
        json[:values] = {}
          self.ordinal_and_nominal_headers.each do |h|
            json[:values][json[:header_keys][h]] = csv[json[:header_keys][h]].reject{ |v| v.nil? || v.empty? }.uniq.sort_by!{ |v| v.downcase }
          end
        json[:items] = self.items
        json[:count] = json[:items].count
        Rails.cache.write(cache_key("json"), json)
      end
      json
    end

    def header_keys
      keys = {}
      self.significant_headers.each do |h|
        keys[h] = key_gen(eval(self.headers).index(h))
      end
      keys
    end

    def key_gen index
      letters = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
      key = ''
      while true
        key = letters[index%letters.size] + key;
        index -= index%letters.size
        index /= letters.size
        break if index == 0
      end
      key
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
