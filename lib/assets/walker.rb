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
    puts 'WALKER: Parsing...'
    count = 1
    while record_rows = get_record_rows
      record_rows.each do |row|
        protected_step do
          url = "#{@base_url}/#{row.css('td')[1].css('a')[0]['href']}"
          r = Record.new(record_url: url, row: row, machine: @machine).parse.save
        end
      end

      count += 1
      goto_index(count)
    end
    puts "WALKER: Complete in #{(Time.now.to_i - @started_at) / 1000} Seconds"
    count
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
      @machine.page.click_link 'Click Here for Public Access'
      @machine.page.check 'chkAgree'
      @machine.page.click_button 'Continue'
    end
  end

  def protected_step(insist = true, &block)
    incomplete = insist
    begin
      begin
        block.call
        incomplete = false
      rescue Capybara::Poltergeist::StatusFailError => cap_err
        puts "WALKER ERROR: #{cap_err.message}"
        @machine.driver.quit
        set_machine
      end
    end while incomplete
  end

end

class MultiWalker
  def initialize(urls)
    @urls = urls
    @count = 0
  end

  def parse
    @urls.each do |url|
      saved_count = Walker.new(url).parse
      @count += saved_count
      puts "WALKER: #{saved_count} Records Saved for a Total of: #{@count}"
    end

    puts "WALKER: All Records Saved for Total of: #{@count}!!"
  end
end
