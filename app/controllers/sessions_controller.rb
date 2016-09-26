class SessionsController < DeviseController
  
  before_filter :ensure_params_exist
  skip_before_filter :verify_authenticity_token

  respond_to :json
  
  def create
    build_resource

    userDetails= User.find_by_login(:login=>params[:user_login][:login])
    providerId = userDetails.provider_id

    logger.debug "Provider ID: " + providerId

    if (providerId) 
      store_location_for(resource, "/#providers/" + providerId) 

      resource = User.find_for_database_authentication(:login=>params[:username])
      return invalid_login_attempt unless resource

      if resource.valid_password?(params[:password])
        sign_in("user", resource)  
      end
      invalid_login_attempt
    else
      render :json=>{:success=>false, :message=>"user is missing provider id"}, :status=>422
    end

  end
  
  def destroy
    sign_out(resource_name)
  end

  protected
  def ensure_params_exist
    return unless params[:username].blank?
    render :json=>{:success=>false, :message=>"missing user_login parameter"}, :status=>422
  end

  def invalid_login_attempt
    render :json=> {:success=>false, :message=>"Error with your login or password"}, :status=>401
  end
end