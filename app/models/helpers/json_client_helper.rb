module Helpers
  module JsonClientHelper
    def as_json_client_data
      r = Hash.new
      self.class.json_client_ids.each do |i|
        r[i] = (self.respond_to?(i, true) ? self.send(i) : '')
      end
      r
    end

    def to_json
      { self.class.name.to_sym => self }.to_json
    end
  end
end
