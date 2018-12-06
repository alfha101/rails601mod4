class ServicePolicy < ApplicationPolicy

  def index?
    @user
  end

  def show?
    true
  end
  
  def create?
    originator?
  end
  
  def update?
    organizer?
  end
  
  def destroy?
    organizer_or_admin?
  end

  def get_businesses?
    true
  end


class Scope < Scope

def user_roles members_only=true, allow_admin=true
      include_admin=allow_admin && @user && @user.is_admin?
      member_join = members_only && !include_admin ? "join" : "left join"
      joins_clause="LEFT JOIN business_services ON business_services.service_id = services.id left join roles on roles.mid=business_services.business_id and roles.mname='Business' and roles.user_id #{user_criteria} OR roles.mid=services.id  and services.creator_id #{user_criteria}"


    scope.select("services.*, roles.role_name")
          .joins("#{joins_clause}")
          .tap {|s|
            if members_only
              s.where("roles.role_name"=>[Role::ORGANIZER, Role::MEMBER])
            end}
  end  

  def resolve
      user_roles
  end
end
end
