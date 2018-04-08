class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :store_user_location!, :unless => :devise_controller?
  
  private
  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent)
  # - The request is handled by a Devise controller such as Devise::SessionsController as that could cause an 
  #    infinite redirect loop.
  # - The request is an Ajax request as this can lead to very unexpected behaviour.
  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr? 
  end

  def store_user_location!
    # :user is the scope we are authenticating
    if request.get? && is_navigational_format? && !devise_controller? && !request.xhr? 
      store_location_for(:user, request.fullpath)
    end
  end

  def params_not_enough
    raise '選單皆為必填'
  end
end
