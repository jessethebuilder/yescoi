class Walker
  def initialize(url, first_page, pages_per)
    puts 'WALKER: Starting...'
    @first_page = first_page
    @records_per = pages_per
    @start_url = url

    set_machine
    goto_first_index

    @index_url_base = @machine.page.current_url
    @base_url = @index_url_base.match(/\A(https?:\/\/.+?)\/viewlist/)[1]

    set_row_indexes
  end

  def parse
    puts "WALKER: Parsing - #{@start_url}"
    error_count = 0
    count = 0
    page_count = 0
    current_page = @first_page

    parent_url = goto_index(@first_page)

    while  record_rows = get_record_rows
      record_rows.each do |row|

        begin
          url = "#{@base_url}/#{row.css('td')[@row_indexes[:tax_id]].css('a')[0]['href']}"
          ghost_step do
             r = Record.new({url: url, machine: @machine}.merge(index_vars(row))).parse
             r.parent_url = parent_url
             r.base_url = @start_url
             r.save
          end

          count += 1
# break
        rescue => e
          error_count += 1
          @machine.page.save_and_open_page if Rails.env.development?
          h = hal
          h.error_urls << url
          h.save
        end

      end #each record

      return page_count + current_page if page_count == @per_page
# break
      page_count += 1
      current_page += 1
      goto_index(current_page)
    end
    puts "WALKER: Complete!"

    return :complete
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
    url = "#{@index_url_base}&page=#{page_num}"
    ghost_step{ @machine.goto url }
    puts "WALKER: Preparing to parse page #{page_num} as #{url}"
    url
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
      @machine.page.click_link 'Click Here for Public Access'
      puts 'access'
      true
    else
      false
    end
  end

  def agree
    if @machine.page.has_css?('#chkAgree')
      @machine.page.check 'chkAgree'
      @machine.page.click_button 'Continue'
      puts 'agree'
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
    @machine = JsScrape.new(timeout: 120, :proxy => false, :debug => false)
  end

  def hal
    Hal.first
  end
end
