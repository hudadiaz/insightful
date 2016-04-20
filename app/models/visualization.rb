class Visualization < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :datum
  delegate :user, to: :datum, allow_nil: false
  after_initialize :default_values

  is_impressionable counter_cache: true, column_name: :views_counter_cache, unique: :session_hash

  validates_presence_of :datum_id

  def modified
    (self.updated_at > self.datum.updated_at ? self : self.datum).updated_at
  end

  def processed_data
    case self.type
      when "sankey"
        sankey_data
      when "sunburst"
        sunburst_data
      when "stacked_bar"
        stacked_bar_data
      when "normalized_stacked_bar"
        stacked_bar_data
    end
  end

  private
    def default_values
      self.title ||= datum.name + " " + self.type.humanize
    end

    def sankey_data
    end

    def sunburst_data
      processedData = Rails.cache.read(cache_key("processedData"))
      if processedData.nil? || processedData.blank?

        selections = eval(self.selections)
        levels = selections[:data]
        measure = selections[:measure]
        items = self.datum.as_json[:items]
        processedData = {name: "All", children: []}

        items.each do |item|
          ii = 0
          max_i = levels.size
          sunburst_helper processedData, {name: nil, children: [], size: 0}, ii, levels, measure, item, max_i
        end

        Rails.cache.write(cache_key("processedData"), processedData)
      end

      processedData
    end

    def findWithAttr items, attr, key
      items.each_with_index do |item, index|
        if item[attr] === key
          return index
        end
      end
      nil
    end

    def sunburst_helper parent_node, current_node, ii, levels, measure, item, max_i
      return if ii == max_i

      existing_index = findWithAttr(parent_node[:children], :name, item[self.datum.as_json[:header_keys][levels[ii].to_s].to_s] )
      if existing_index.present?
        existing = parent_node[:children][existing_index]
        if existing[:size].present?
          if measure == "count"
            existing[:size] += 1
          else
            existing[:size] += item[self.datum.as_json[:header_keys][measure.to_s].to_s].to_f
          end
        end

        sunburst_helper existing, {name: nil, children: [], size: 0}, ii+1, levels, measure, item, max_i
        return
      else
        current_node[:name] = item[self.datum.as_json[:header_keys][levels[ii].to_s].to_s]
      end
      sunburst_helper current_node, {name: nil, children: [], size: 0}, ii+1, levels, measure, item, max_i

      if current_node[:children].size < 1
        current_node.delete(:children)
        if measure == "count"
          current_node[:size] += 1
        else
          current_node[:size] += item[self.datum.as_json[:header_keys][measure.to_s].to_s].to_f
        end
      end

      if current_node[:size] < 1
        current_node.delete(:size)   
      end

      parent_node[:children] << current_node
    end

    def stacked_bar_data
      processedData = Rails.cache.read(cache_key("processedData"))
      if processedData.nil? || processedData.blank?
        selections = eval(self.selections)
        selection_category = selections[:category]
        selection_stack = selections[:stack]
        selection_measure = selections[:measure]
        items = self.datum.as_json[:items]
        categories = self.datum.as_json[:values][self.datum.as_json[:header_keys][selection_category.to_s].to_s]
        stacks = self.datum.as_json[:values][self.datum.as_json[:header_keys][selection_stack.to_s].to_s].reverse
        processedData = []

        categories.each_with_index do |category, index|
          datum = {}
          category = "nil"+index.to_s if category.nil?
          datum[selection_category.to_s] = category
          stacks.each { |s| datum[s] = 0 }
          processedData << datum
        end

        items.each do |item|
          category_index = categories.index(item[self.datum.as_json[:header_keys][selection_category.to_s].to_s])
          stack_index = item[self.datum.as_json[:header_keys][selection_stack.to_s].to_s]
          if category_index.present? && stack_index.present?
            if selection_measure == 'count'
              processedData[category_index][stack_index.to_s] += 1 
            else
              processedData[category_index][stack_index.to_s] += item[self.datum.as_json[:header_keys][selection_measure.to_s].to_s].to_f
            end
          end
        end

        Rails.cache.write(cache_key("processedData"), processedData)
      end

      processedData
    end

    def cache_key name
      "visuzalization_"+self.id.to_s+"_"+name+"_"+self.type
    end

    def clear_cache
      Rails.cache.write(cache_key("processedData"), nil)
    end
end
