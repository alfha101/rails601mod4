class BusinessServicesController < ApplicationController
    include ActionController::Helpers
    helper BusinessesHelper  
    wrap_parameters :business_service, include: ["service_id", "business_id", "priority"]
    before_action :get_business, only: [:index, :update, :destroy]
    before_action :get_service, only: [:service_businesses]
    before_action :get_business_service, only: [:update, :destroy]
    before_action :authenticate_user!, only: [:create, :update, :destroy]
    after_action :verify_authorized
    #after_action :verify_policy_scoped, only: [:linkable_businesses]

  def index
    authorize @business, :get_services?
    @business_services = @business.business_services.prioritized.with_sname
  end

  def service_businesses
    authorize @service, :get_businesses?
    @business_services=@service.business_services.prioritized.with_name
    render :index 
  end

  def linkable_businesses
    authorize Business, :get_linkables?
    service = Service.find(params[:service_id])
    #@businesses=policy_scope(Business.not_linked(service))
    #need to exclude admins from seeing businesses they cannot link
    @businesses=Business.not_linked(service)
    @businesses=BusinessPolicy::Scope.new(current_user,@businesses).user_roles(true,false)
    @businesses=BusinessPolicy.merge(@businesses)
    render "businesses/index"
  end

  def create
    business_service = BusinessService.new(business_service_create_params.merge({
                                  :service_id=>params[:service_id],
                                  :business_id=>params[:business_id],
                                  }))
    business=Business.where(id:business_service.business_id).first
    if !business
      full_message_error "cannot find business[#{params[:business_id]}]", :bad_request
      skip_authorization
    elsif !Service.where(id:business_service.service_id).exists?
      full_message_error "cannot find service[#{params[:service_id]}]", :bad_request
      skip_authorization
    else
      authorize business, :add_service?
      business_service.creator_id=current_user.id
      if business_service.save
        head :no_content
      else
        render json: {errors:@business_service.errors.messages}, status: :unprocessable_entity
      end
    end
  end

  def update
    authorize @business, :update_service?
    if @business_service.update(business_service_update_params)
      head :no_content
    else
      render json: {errors:@business_service.errors.messages}, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @business, :remove_service?
    @business_service.destroy
    head :no_content
  end

  private
    def get_business
        @business ||= Business.find(params[:business_id])
    end
    def get_service
        @service ||= Service.find(params[:service_id])
    end
    def get_business_service
        @business_service ||= BusinessService.find(params[:id])
    end
    
    def business_service_create_params
        params.require(:business_service).tap {|p|
            #_ids only required in payload when not part of URI
            p.require(:service_id) if !params[:service_id]
            p.require(:business_id) if !params[:business_id]
        }.permit(:priority, :service_id, :business_id)
    end
    def business_service_update_params
        params.require(:business_service).permit(:priority)
    end
end
