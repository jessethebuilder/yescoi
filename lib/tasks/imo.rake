require 'assets/walker.rb'

namespace :imo do
  desc "Gather Data"
  task :parse => :environment do
    puts "IMO Begin Parse"
    MultiWalker.new.parse
    puts "IMO Parse Complete"
  end
end
