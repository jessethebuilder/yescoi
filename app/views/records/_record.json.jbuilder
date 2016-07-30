json.extract! record, :id, :municipality, :tax_id, :owner, :street_number, :street_name, :swis, :created_at, :updated_at
json.url record_url(record, format: :json)