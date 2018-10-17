class ServicesController < ApplicationController
  include ActionController::Helpers
  helper ServicesHelper
  before_action :set_service, only: [:show, :update, :destroy]
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  wrap_parameters :service, include: ["name", "description", "notes"]
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: [:index]


  def index
    authorize Service
    @services = policy_scope(Service.all)
    # pp @services.map{|r|r.attributes}
    @services = ServicePolicy.merge(@services)

  end

  def show
    authorize @service
    services = policy_scope(Service.where(:id=>@service.id))
    # pp services.map{|r|r.attributes}
    @service = ServicePolicy.merge(services).first
  end

  def create
    authorize Service
    @service = Service.new(service_params)
    @service.creator_id=current_user.id

    User.transaction do
      if @service.save
        role=current_user.add_role(Role::ORGANIZER, @service)
        @service.user_roles << role.role_name
        role.save!
        render :show, status: :created, location: @service
      else
        render json: {errors:@service.errors.messages}, status: :unprocessable_entity
      end
    end
  end

  def update
    authorize @service

    if @service.update(service_params)
      head :no_content
    else
      render json: {errors:@service.errors.messages}, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @service
    @service.destroy

    head :no_content
  end

  private

    def set_service
      @service = Service.find(params[:id])
    end

    def service_params
      params.require(:service).tap {|p|
        p.require(:name) #throws ActionController::ParameterMissing
      }.permit(:name, :description, :notes)
    end
end
