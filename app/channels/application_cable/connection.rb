module ApplicationCable
  class Connection < ActionCable::Connection::Base
    # include SessionsHelper
    # identified_by :current_user
    #
    # def connect
    #   self.current_user = find_verified_user
    # end
    #
    # private
    #
    # def find_verified_user
    #   verified_user = User.find_by_remember_token request.cookies['remember_token']
    #   # maybe we need more than the token? Certainly for real security we do.
    # end
    #
    # def noop; end
  end
end
