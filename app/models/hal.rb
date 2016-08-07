class Hal
  include Mongoid::Document

  field :urls, type: Array, default: []
  field :busy_urls, type: Array, default: []
  field :complete_urls, type: Array, default: []
  field :error_urls, type: Array, default: []
end
