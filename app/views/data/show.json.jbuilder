json.headers @headers

json.set! :values do
  @headers.each do |h|
    json.set! h do
      json.array! @csv[h].uniq
    end
  end
end

json.count @items.count

json.items @items