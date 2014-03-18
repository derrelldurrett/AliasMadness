module HashHelper
  PRIME = 31

  def hash
    h=0
    HashHelper.hash_vars.each do |s|
      if self.respond_to? s
        unless self.method(s).call.nil?
          if self.method(s).call.respond_to? :id
            h=h*PRIME+self.method(s).call.id.hash
          else
            h=h*PRIME+self.method(s).call.hash
          end
        end
      end
    end
    h
  end

  class << self
            def hash_vars
              @hash_vars
            end

            def hash_vars=(vars)
              @hash_vars=vars
            end
  end
end
