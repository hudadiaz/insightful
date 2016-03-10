class Datum < ActiveRecord::Base
  belongs_to :user

  after_initialize :default_values
  before_save :retrieve_headers
  # before_save :assign_name_to_unnamed_headers

  def heads
    unless self.ignored.nil? || self.ignored.blank?
      eval(self.headers) - eval(self.ignored)
    else
      eval(self.headers)
    end
  end

  def csv
    CSV.parse(content, :headers => true)
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
    d = {}
    d[:id] = self.id
    d[:name] = self.name
    d[:headers] = self.heads
    d[:values] = {}
      self.heads.each do |h|
        d[:values][h] = self.csv[h].uniq
      end
    d[:items] = self.items
    d[:count] = d[:items].count
    d
  end

  private
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
