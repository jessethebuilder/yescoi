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
    set_machine
    # @index_url_base = "#{@base_url}/viewlist.aspx?sort=printkey&swis=all&advanced=true"
    goto_first_index
    @index_url_base = @machine.page.current_url
    @base_url = @index_url_base.match(/\A(https?:\/\/.+?)\/viewlist/)[1]

# sleep 2
    # goto_first_index
    set_row_indexes
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
          url = "#{@base_url}/#{row.css('td')[@row_indexes[:tax_id]].css('a')[0]['href']}"
          ghost_step do
             r = Record.new({url: url, machine: @machine}.merge(index_vars(row))).parse.save
           end

          count += 1
          #dbg
          return if count == 10
        rescue => e
          puts e.inspect
          puts e.backtrace.join("\n\n")
          puts url
          #@machine.page.save_and_open_page
          error_count += 1
          exit
        end
      end

      page_count += 1
      goto_index(page_count)
    end
    @machine.page.save_and_open_page
    puts "WALKER: Complete in #{(Time.now.to_i - @started_at) / 1000} Seconds with
         #{error_count} Record Saving Errors!"
    {:count => count, :errors => error_count}
  end

  private

  def index_vars(row)
    h = {}
    cells = row.css('td')

    @row_indexes.each do |k, v|
      h[k] = cells[v].text.strip
    end

    h
  end

  def set_row_indexes
    attrs = {tax_id: 'Tax ID', owner: 'Owner', street_num: 'Street #', street_name: 'Street Name'}
    @row_indexes = {}

    table = @machine.doc.css('#tblList')
    row = table.css('tr').first
    cols = row.css('td')

    attrs.each do |k, v|
      cols.each_with_index do |col, i|
        if col.text.strip == v
          @row_indexes[k] = i
        end
      end
    end
  end

  def get_record_rows
    if table = @machine.doc.css('#tblList')
      rows = table.css('tr')[1..-1]
    else
      nil
    end
  end

  def goto_index(page_num)
    url = "#{@index_url_base}?page=#{page_num}"
    ghost_step{ @machine.goto url }
    puts "WALKER: Preparing to parse page #{page_num}"
  end

  def goto_first_index
    ghost_step do
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

  def ghost_step(retry_count = 10, &block)
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

  def set_machine
    @machine = JsScrape.new(timeout: 30, :proxy => false, :debug => false)
  end
end

class MultiWalker
  include WalkersHelper

  def initialize
    h = prepare_hal
    @urls = h.urls - h.complete_urls
    # @urls = ['http://74.39.247.67/imo/search.aspx?advanced=true']
    #@urls = ['http://ocfintax.ongov.net/imate/search.aspx?advanced=true']
    # original
      # @urls = ['http://imo.schohariecounty-ny.gov/viewlist.aspx?sort=printkey&swis=all&advanced=true']


    #@urls = ['http://yates.sdgnys.com/search.aspx?advanced=true']

    #@urls = ['https://www.madisoncounty.ny.gov/ImateWeb/search.aspx?advanced=true']
  end

  def parse
    count = 0
    error_count = 0
    while url = available_url do
      # saved_hash broken
      begin
        saved_hash = Walker.new(url).parse
        mark_as_complete(url)
      rescue => e
        puts e
        puts e.stacktrace
        mark_as_error(url)
      end
      #count += saved_hash[:count].to_i
      #error_count += saved_hash[:error_count].to_i
    end

    puts "MULTI_WALKER: All Records Saved for Total of: #{count} with #{error_count}
          Record Saving Errors!!!!!!"
  end

  private

  def available_url
    h = hal
     url = (@urls - h.busy_urls).sample
    #  url = @urls.sample
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

  def mark_as_error(url)
    h = hal
    h.error_urls << url
    h.save
  end

  def prepare_hal
    puts 'waking hal...'
    h = hal
    h.busy_urls = []
    h.save
    h
  end
end
