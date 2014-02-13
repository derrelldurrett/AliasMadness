class Admin
  class << self
    def get
      @admin ||= User.where(role: :admin).first
    end
  end
end
