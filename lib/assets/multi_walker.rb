class MultiWalker
  # debug
  def initialize(pages_per = 1)
    h = hal
    @pages_per = pages_per
    @urls = h.urls.keys
  #  @urls = ["http://franklin.sdgnys.com/search.aspx?advanced=true"]
  end

  def parse
    # a url_hash is a base_url and an integer indicating the last
    # record captured.
    while url_hash = available_url_hash do
      # The key/url distiction is necessary because Mongo does not allow
      # us to save Hash keys with '.' in them. :(
      key = url_hash.first[0]
      url = key.gsub('_', '.')
      first_page = url_hash.first[1]

      begin
        # parse returns a hash with single k/v. Key is url. Val is an
        # integer indicating the last page saved, or the symbol :complete
        last_page = Walker.new(url, first_page: first_page, pages_per: @pages_per).parse

        if last_page == :complete
          mark_as_complete(key)
        elsif(last_page.class == Integer)
          h = Hal.first
          h.urls[key] = v
          h.save
        end
       rescue => e
         puts e
         puts e.stacktrace
         mark_as_error(url)
       end
    end

    puts "MULTI_WALKER: All Records Saved"
  end

  private

  def available_url_hash
    h = hal
    key = h.urls.keys.sample
    if key
      last_page = h.busy_urls[key]
      h.busy_urls[key] = last_page + @pages_per
      h.save
      {key => last_page + 1}
    else
      nil
    end
  end

  def mark_as_complete(key)
    h = hal
    # Save as complete and remove from current queue
    h.complete_urls << key
    h.urls.delete(key)
    h.save
  end

  def mark_as_error(url)
    # Wants URL instead of key, so it's easier to parse, as we have to fix these anyway
    h = hal
    h.error_urls << url
    h.save
  end

  def hal
    Hal.first
  end
end
