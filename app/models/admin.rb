class Admin
  class << self
    def get
      @admin = @admin ? @admin.reload : User.where(role: :admin).first
    end
  end
end
