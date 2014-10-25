module JSONClientHelper
  def as_json_client_data
    r=Hash.new
    self.class.json_client_ids.each do |i|
      r[i]= (self.respond_to?(i,true) ? self.send(i) : '')
    end
    r
  end
end
