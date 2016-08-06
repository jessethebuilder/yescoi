class Walker
  def initialize(url)
    puts 'WALKER: Starting...'
    @started_at = Time.now.to_i

    @start_url = url
    @base_url = url.match(/\A(https?:\/\/.+?)\//)[1]
    set_machine
    goto_first_index
  end

  def parse
    puts "WALKER: Parsing - #{@start_url}"
    error_count = 0
    count = 0
    page_count = 1

    goto_index(page_count)

    while  record_rows = get_record_rows
      record_rows.each do |row|
        begin
          protected_step do
            url = "#{@base_url}/#{row.css('td')[1].css('a')[0]['href']}"
            r = Record.new(record_url: url, row: row, machine: @machine).parse.save
            count += 1
          end
        rescue => e
          puts 'WALKER: Unknown Error on Record Save!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
          error_count += 1
        end
      end

      page_count += 1
      goto_index(page_count)
    end
    puts "WALKER: Complete in #{(Time.now.to_i - @started_at) / 1000} Seconds with
         #{error_count} Record Saving Errors!"
    {:count => count, :errors => error_count}
  end

  private

  def get_record_rows
    if table = @machine.doc.css('#tblList')
      rows = table.css('tr')[1..-1]
    else
      nil
    end
  end

  def set_machine
    @machine = JsScrape.new(timeout: 180, :proxy => false, :debug => false)
  end

  def goto_index(page_num)
    url = "#{@start_url}?page=#{page_num}"
    protected_step{ @machine.goto url }
    puts "WALKER: Preparing to parse page #{page_num}"
  end

  def goto_first_index
    protected_step do
      @machine.goto @start_url

      @machine.page.click_link 'Click Here for Public Access' if @machine.page.has_link?('Click Here for Public Access')

      if @machine.page.has_css?('#chkAgree')
        @machine.page.check 'chkAgree'
        @machine.page.click_button 'Continue'
      end

      @machine.page.click_button 'Serch' if @machine.page.has_css?('#tblSearch')
    end
  end

  def protected_step(retry_count = 10, &block)
    begin
      begin
        block.call
        incomplete = false
      rescue Capybara::Poltergeist::Error => cap_err
        puts "WALKER ERROR (Poltergeist): #{cap_err.message}"
        @machine.page.driver.quit
        set_machine
        retry_count -= 1
      end
    end while retry_count == 0
  end

  def get_next_page
    page = hal.last_pages[@base_url]
    ret = page ? page + 1 : 1
    hal.last_pages[@base_url] = ret
    hal.save
    ret
  end

  def hal
    Hal.first
  end
end

class MultiWalker
  def initialize
    @urls = ['http://imo.schohariecounty-ny.gov/viewlist.aspx?sort=printkey&swis=all&advanced=true']
  end

  def parse
    count = 0
    error_count = 0
    @urls.each do |url|
      saved_hash = Walker.new(url).parse
      count += saved_hash[:count].to_i
      error_count += saved_hash[:error_count].to_i
    end

    puts "MULTI_WALKER: All Records Saved for Total of: #{count} with #{error_count}
          Record Saving Errors!!!!!!"
  end
end
