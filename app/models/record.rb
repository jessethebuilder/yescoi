class Record
  include Mongoid::Document

  attr_accessor :machine

  field :url, type: String
  field :parent_url, type: String
  field :base_url, type: String
  field :page_number, type: Integer
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
  field :land_assessment, type: String
  field :full_market_value, type: String
  field :total_assessment, type: String
  field :grid_east, type: Integer
  field :grid_north, type: Integer

  embeds_many :tax_summaries

  def parse
    goto_record_start
    parse_main_page
    goto_tax_info
    parse_tax_info
    self
  end

  private

  def parse_tax_info
    %w|tblSummary tblHistoricalSummary|.each do |tbl|
      rows = @machine.doc.css("##{tbl} tr")[1..-2]
      if rows
        rows.each do |row|
          ts = TaxSummary.new(:row => row).parse
          # puts ts.inspect
          self.tax_summaries << ts
        end
      end
    end
  end

  def goto_tax_info
    if(@machine.page.has_css?('#btnTaxInfo'))
      @machine.page.click_button 'btnTaxInfo'

      if @machine.page.has_link? 'Display Historical Tax Information'
        @machine.page.click_link 'Display Historical Tax Information'
      end
    end
  end

  def parse_main_page
    doc = @machine.doc

    %w|Status RollSection Address|.each do |attr|
      self.send("#{attr.underscore}=", doc.css("#lbl#{attr}").text.strip)
    end

    self.municipality = doc.css('#lblMunic').text.strip
    self.swis = doc.css('#lblSwis').text.strip.to_i
    self.school_district = doc.css('#lblSchoolDist').text.strip
    self.property_class = doc.css('#lblBasePropClass').text.strip
    self.property_description = doc.css('#lblLglPropDesc').text.strip

    self.land_assessment = doc.css('#lblLandAssess')
    self.total_assessment = doc.css('#lblTotalAssess')
    self.full_market_value = doc.css('#lblFullMarketValue')

    %w|GridEast GridNorth|.each do |attr|
      self.send("#{attr.underscore}=", doc.css("#lbl#{attr}").text.strip)
    end
  end

  def goto_record_start
    machine.goto self.url
  end
end
