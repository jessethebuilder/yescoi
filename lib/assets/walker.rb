module WalkersHelper
  def hal
    Hal.first
  end
end

class Walker
  include WalkersHelper

  def initialize(url)
    puts 'WALKER: Starting...'
    @started_at = Time.now.to_i

    @start_url = url
    @base_url = @start_url.match(/\A(https?:\/\/.+?)\//)[1]
    @index_url_base = "#{@base_url}/viewlist.aspx?sort=printkey&swis=all&advanced=true"
    puts @index_url_base
    set_machine
    goto_first_index
  end

  def parse
    puts "WALKER: Parsing - #{@start_url}"
    error_count = 0
    count = 0
    page_count = 1

    goto_index(page_count)

    #goto_index(page_count) if begin_search

    @machine.page.save_and_open_page
    while  record_rows = get_record_rows
      record_rows[0].css('td').each_with_index do |td, i|
        if td.css('a') && td.css('a').text == 'Tax ID'
          @index_col = i
          break
        end
      end

      record_rows[1..-1].each do |row|
        begin
          protected_step do
            url = "#{@base_url}/#{row.css('td')[@index_col].css('a')[0]['href']}"
            r = Record.new(record_url: url, row: row, machine: @machine).parse.save
            count += 1
          end
        rescue => e
          puts e
          @machine.page.save_and_open_page
          error_count += 1
          exit
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

  def tax_id_cell_index
    if table = @machine.doc.css('#tblList')
      header_cells = table.search('tbody tr').first.css('td')
      header_cells.each_with_index do |cell, i|
        if cell.has_css?('a') && cell.css('a').text == 'Tax ID'
          return i
        end
      end
    end
  end

  def get_record_rows
    if table = @machine.doc.css('#tblList')
      rows = table.css('tr')
    else
      nil
    end
  end

  def set_machine
    @machine = JsScrape.new(timeout: 180, :proxy => false, :debug => false)
  end

  def goto_index(page_num)
    url = "#{@index_url_base}?page=#{page_num}"
    protected_step{ @machine.goto url }
    puts "WALKER: Preparing to parse page #{page_num}"
  end

  def goto_first_index
    protected_step do
      @machine.goto @start_url
      access && agree
      begin_search
    end
  end

  def access
    if @machine.page.has_link?('Click Here for Public Access')
      puts 'access'
      @machine.page.click_link 'Click Here for Public Access'
      true
    else
      false
    end
  end

  def agree
    if @machine.page.has_css?('#chkAgree')
      puts 'agree'
      @machine.page.check 'chkAgree'
      @machine.page.click_button 'Continue'
      true
    else
      false
    end
  end

  def begin_search
    if @machine.page.has_css?('#tblSearch')
      puts 'search'
      @machine.page.find('#btnSearch').click
      true
    else
      false
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
end

class MultiWalker
  include WalkersHelper

  def initialize
    h = prepare_hal
    @urls = h.urls - h.complete_urls

    # original
    @urls = ['http://imo.schohariecounty-ny.gov/viewlist.aspx?sort=printkey&swis=all&advanced=true']


    @urls = ['http://yates.sdgnys.com/search.aspx?advanced=true']
  end

  def parse
    count = 0
    error_count = 0
    while url = available_url do
      saved_hash = Walker.new(url).parse
      count += saved_hash[:count].to_i
      error_count += saved_hash[:error_count].to_i
      mark_as_complete(url)
    end
    puts "MULTI_WALKER: All Records Saved for Total of: #{count} with #{error_count}
          Record Saving Errors!!!!!!"
  end

  private

  def available_url
    h = hal
    url = (@urls - h.busy_urls).sample
    if url
      h.busy_urls << url
      h.save
      url
    else
      nil
    end
  end

  def mark_as_complete(url)
    h = hal
    h.complete_urls << url
    h.save
  end

  def prepare_hal
    puts 'waking hal'
    h = hal
    h.busy_urls = []
    h.save
    h
  end
end
