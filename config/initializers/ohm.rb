class Ohm::BasicSet
  def paginate (options)
    current_page = options[:page].to_i
    per_page = options[:per_page].to_i
    
    total_count = count
    sort_options = {
      :order => options[:sort_order] || "DESC",
      :limit => [
                 (current_page-1)*per_page,
                 per_page
                ]
    }
    results = sort_by(options[:sort_by] || :id, sort_options).to_a
    
    WillPaginate::Collection.create(current_page, per_page, total_count) do |pager|
      pager.replace(results)

      unless pager.total_entries
        # the pager didn't manage to guess the total count, do it manually
        pager.total_entries = total_count
      end
    end
  end
end
