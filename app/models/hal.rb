class Hal
  include Mongoid::Document

  field :urls, type: Array, default: []
  field :busy_urls, type: Array, default: []
end
