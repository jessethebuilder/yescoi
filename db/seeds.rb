Hal.destroy_all

h = Hal.new
urls = ['http://24.213.254.86/imo/search.aspx?advanced=true',
'http://64.132.212.35/imate/search.aspx?advanced=true',
'http://74.39.247.67/imo/search.aspx?advanced=true',
'http://allegany.sdgnys.com/search.aspx?advanced=true',
'http://chemung.sdgnys.com/search.aspx?advanced=true',
'http://clinton.sdgnys.com/search.aspx?advanced=true',
'http://columbia.sdgnys.com/index.aspx',
'http://franklin.sdgnys.com/search.aspx?advanced=true',
'http://greene.sdgnys.com/search.aspx?advanced=true',
'http://herkimercounty.sdgnys.com/search.aspx?advanced=true',
'http://imo.co.seneca.ny.us/search.aspx?advanced=true',
'http://imo.co.tioga.ny.us/search.aspx?advanced=true',
'http://imo.co.washington.ny.us/search.aspx?advanced=true',
'http://imo.otsegocounty.com/search.aspx?advanced=true',
'http://imo.schohariecounty-ny.gov/search.aspx?advanced=true',
'http://imo.yonkersny.gov/search.aspx?advanced=true',
'http://maps.cattco.org/imate/search.aspx?advanced=true',
'http://ocfintax.ongov.net/imate/search.aspx?advanced=true',
'http://orleans.sdgnys.com/search.aspx?advanced=true',
'http://property.tompkins-co.org/IMO/search.aspx?advanced=true',
'http://propertydata.orangecountygov.com/imate/search.aspx?advanced=true',
'http://putnam.sdgnys.com/search.aspx?advanced=true',
'http://ranger.co.montgomery.ny.us/IMO/search.aspx',
'http://rpts-imo.co.essex.ny.us/IMO/search.aspx?advanced=true',
#'http://rptsweb.oswegocounty.com/search.aspx?advanced=true',
'http://saratoga.sdgnys.com/search.aspx?advanced=true',
'http://schuyler.sdgnys.com/search.aspx?advanced=true',
'http://webapps.co.sullivan.ny.us/IMO/search.aspx?advanced=true',
'http://yates.sdgnys.com/search.aspx?advanced=true',
'https://www.madisoncounty.ny.gov/ImateWeb/search.aspx?advanced=true']

urls.each do |url|
  h.urls[url.gsub('.', '_')] = 0
  h.busy_urls[url.gsub('.', '_')] = 0
end

h.save

Record.destroy_all
