require 'assets/walker.rb'

namespace :imo do
  desc "Gather Data"
  task :parse => :environment do
    puts "IMO Begin Parse"
    MultiWalker.new(['http://imo.schohariecounty-ny.gov/viewlist.aspx?sort=printkey&swis=all&advanced=true']).parse
    puts "IMO Parse Complete"
  end
end
