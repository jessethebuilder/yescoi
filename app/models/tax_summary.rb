class TaxSummary
  include Mongoid::Document

  embedded_in :record

  attr_accessor :row

  field :tax_year, type: Integer
  field :tax_type, type: String
  field :original_bill, type: Float
  field :total_assessed_value, type: Float
  field :full_market_value, type: Float
  field :uniform_percentage, type: Integer
  field :roll_section, type: Integer

  def parse
    cols = row.css('td')
    self.tax_year = cols[0].text.strip.gsub(/\A[[:space:]]/, '')
    self.tax_type = cols[1].text.strip.gsub(/\A[[:space:]]/, '')
    self.original_bill = cols[2].text.strip.gsub(/[$, ]/, '').gsub(/\A[[:space:]]/, '')
    self.total_assessed_value = cols[3].text.strip.gsub(/[$,]/, '').gsub(/\A[[:space:]]/, '')
    self.full_market_value = cols[4].text.strip.gsub(/[$,]/, '').gsub(/\A[[:space:]]/, '')
    self.uniform_percentage = cols[5].text.strip.gsub(/\A[[:space:]]/, '')
    self.roll_section = cols[6].text.strip.gsub(/\A[[:space:]]/, '')
    self
  end
end
