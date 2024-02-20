# frozen_string_literal: true

class LabelLookup < Hash
  class << self
    def load(serialized_data)
      JSON.parse(serialized_data).each_with_object(new) do |kv, hsh|
        hsh[kv[0]] = build(kv[1])
      end
    end

    private def build(hsh)
      hsh.values.first.each_with_object(hsh.keys.first.constantize.new) do |kv, o|
        m = "#{kv.first}=".to_sym
        o.send(m) if o.respond_to?(m, true)
      end
    end
  end

  def dump
    to_json
  end
end
