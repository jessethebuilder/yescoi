class MultiWalker
  def initialize(pages_per = 20)
    h = hal
    @pages_per = pages_per
    #@pages_per = 1
    @urls = h.urls.keys
  end

  def parse
    # a url_hash is a base_url and an integer indicating the last
    # record captured.
    while url_hash = available_url_hash do
      url = url_hash.first[0]
      first_page = url_hash.first[1]

      #begin
        # parse returns a hash with single k/v. Key is url. Val is an
        # integer indicating the last page saved, or the symbol :complete
        url_hash = Walker.new(url, first_page: first_page, pages_per: @pages_per).parse
        key = url_hash.first[0]
        val = url_hash.first[1]
        if val == :complete
          mark_as_complete(key)
        elsif(val.class == Integer)
          h = Hal.first
          h.urls[key] = v
          h.save
        end
      # rescue => e
      #   puts e
      #   #puts e.stacktrace
      #   mark_as_error(url)
      # end
    end

    puts "MULTI_WALKER: All Records Saved"
  end

  private

  def available_url_hash
    h = hal
    key = h.urls.keys.sample
    if key
      first_page = h.busy_urls[key] + 1
      last_page = h.busy_urls[key]
      # h.busy_urls[key] = last_page + @pages_per
      h.save
      {key => first_page}
    else
      nil
    end
  end

  def mark_as_complete(url)
    h = hal
    # Save as complete and remove from current queue
    h.complete_urls << url
    h.urls.delete(url)
    h.save
  end

  def mark_as_error(url)
    h = hal
    h.error_urls << url
    h.save
  end

  def hal
    Hal.first
  end
end
