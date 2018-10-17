class ServicePolicy < ApplicationPolicy
  def index?
    @user
  end

  def show?
    @user
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
    def user_roles
      joins_clause=["left join Roles r on r.mname='Service'",
                    "r.mid=Services.id",
                    "r.user_id #{user_criteria}"].join(" and ")
      scope.select("Services.*, r.role_name")
           .joins(joins_clause)
    end

    def resolve
       user_roles
    end
  end
end
