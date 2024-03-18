# module ApplicationCable
#   class Connection < ActionCable::Connection::Base
#     include SessionsHelper
#     identified_by :current_user
#
#     def connect
#       self.current_user = find_verified_user
#     end
#
#     protected
#     def find_verified_user
#       current_user = User.find_by_remember_token request.cookies['remember_token']
#       return current_user unless current_user.nil?
#       reject_unauthorized_connection
#     end
#   end
# end
