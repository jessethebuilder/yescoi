class Record
  include Mongoid::Document

  attr_accessor :machine, :row

  field :record_url, type: String
  field :municipality, type: String
  field :tax_id, type: String
  field :owner, type: String
  field :street_num, type: String
  field :street_name, type: String
  field :swis, type: Integer
  field :status, type: String
  field :roll_section, type: String
  field :address, type: String
  field :property_class, type: String
  field :school_district, type: String
  field :property_description, type: String
  field :land_assessment, type: Hash
  field :full_market_value, type: Hash
  field :total_assessment, type: Hash
  field :grid_east, type: Integer
  field :grid_north, type: Integer

  embeds_many :tax_summaries

  def parse
    parse_index_row
    goto_record_start
    parse_main_page
    goto_tax_info
    parse_tax_info
    self
  end
  def t
    tax_summaries
  end
  private

  def parse_tax_info
    %w|tblSummary tblHistoricalSummary|.each do |tbl|
      rows = @machine.doc.css("##{tbl} tr")[1..-2]
      rows.each do |row|
        self.tax_summaries << TaxSummary.new(:row => row).parse
      end
    end
  end

  def goto_tax_info
    @machine.page.click_button 'btnTaxInfo'
    @machine.page.click_link 'lnkHistorical'
  end

  def parse_index_row
    cols = self.row.css('td')
    self.municipality = cols[0].text.strip.split(' - ')[1]
    self.tax_id = cols[1].text.strip
    self.owner = cols[2].text.strip
    self.street_num = cols[3].text.strip
    self.street_name = cols[4].text.strip
  end

  def parse_main_page
    doc = @machine.doc

    %w|Status RollSection Address|.each do |attr|
      self.send("#{attr.underscore}=", doc.css("#lbl#{attr}").text.strip)
    end

    self.swis = doc.css('#lblSwis').text.strip.to_i
    self.school_district = doc.css('#lblSchoolDist').text.strip
    self.property_class = doc.css('#lblBasePropClass').text.strip
    self.property_description = doc.css('#lblLglPropDesc').text.strip


    self.land_assessment = parse_assessment(doc.css('#lblLandAssess'))
    self.total_assessment = parse_assessment(doc.css('#lblTotalAssess'))
    self.full_market_value = parse_assessment(doc.css('#lblFullMarketValue'))

    %w|GridEast GridNorth|.each do |attr|
      self.send("#{attr.underscore}=", doc.css("#lbl#{attr}").text.strip)
    end
  end

  def parse_assessment(element)
    tentative = element.css('font')[0].text
    current = element.text.gsub(tentative, '')
    h = {}
    r = /(\d{4}).+?([\d,]+)/

    current =~ r
    h[:year] = $1.to_i
    h[:value] = $2.gsub(',', '').to_f

    tentative =~ r
    h[:tentative_year] = $1.to_i
    h[:tentative_value] = $2.gsub(',', '').to_f

    h
  end

  def goto_record_start
    machine.goto self.record_url
  end
end
