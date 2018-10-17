module ServicesHelper
    # def is_member?
    #   @current_user && @current_user.is_member?
    # end
    # def restrict_notes? user_roles
    #   user_roles.empty? && !is_member?
    # end


    def is_admin?
      @current_user && @current_user.is_admin?
    end
    def restrict_notes? user_roles
      user_roles.empty? && !is_admin?
    end

  end 
  