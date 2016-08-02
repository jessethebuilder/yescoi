class Hal
  include Mongoid::Document

  field :last_pages, type: Hash, default: {}
end
