class BusinessesController < ApplicationController
  include ActionController::Helpers
  helper BusinessesHelper
  before_action :set_business, only: [:show, :update, :destroy]
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  wrap_parameters :business, include: ["name", "description", "notes"]
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: [:index]

  def index
    authorize Business
    businesses = policy_scope(Business.all)
    @businesses = BusinessPolicy.merge(businesses)
  end

  def show
    authorize @business
    businesses = BusinessPolicy::Scope.new(current_user,
                                    Business.where(:id=>@business.id))
                                    .user_roles(false)
    @business = BusinessPolicy.merge(businesses).first  
  end

  def create
    authorize Business
    @business = Business.new(business_params)

    User.transaction do
      if @business.save
        role=current_user.add_role(Role::ORGANIZER,@business)
        @business.user_roles << role.role_name
        # - byebug
        # binding.pry
        role.save!
        render :show, status: :created, location: @business
      else
        render json: {errors:@business.errors.messages}, status: :unprocessable_entity
      end
    end
  end

  def update
    authorize @business

    if @business.update(business_params)
      head :no_content
    else
      render json: {errors:@business.errors.messages}, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @business
    @business.destroy

    head :no_content
  end

  private

    def set_business
      @business = Business.find(params[:id])
    end

    def business_params
      params.require(:business).tap {|p|
        p.require(:name) #throws ActionController::ParameterMissing
      }.permit(:name, :description, :notes)
    end
end
