class Hal
  include Mongoid::Document

  field :urls, type: Hash, default: {}
  field :busy_urls, type: Hash, default: {}
  field :complete_urls, type: Array, default: []
  field :error_urls, type: Array, default: []
end
