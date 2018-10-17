module Protectable
  extend ActiveSupport::Concern
  # It extends active support concern, and it's telling Ruby
  # that anyone who includes me, should get this method of user roles. 

  included do
    def user_roles
      @user_roles ||= []
    end
  end
end
