class ApplicationController < ActionController::Base
  respond_to :json
  protect_from_forgery with: :exception, unless: :json_request?
  protect_from_forgery with: :null_session, if: :json_request?
  skip_before_action :verify_authenticity_token, if: :json_request?

  def render_resource(resource)
    if resource.errors.empty?
      render json: resource
    else
      validation_error(resource)
    end
  end

  def validation_error(resource)
    render json: {
      errors: [
        {
          status: "400",
          title: "Bad Request",
          detail: resource.errors,
          code: "100",
        },
      ],
    }, status: :bad_request
  end

  protected

  def authenticate_admin!
    puts current_user
    puts current_user.admin?
    authenticate_user!
    redirect_to "http://www.rubyonrails.org", status: :forbidden unless current_user.admin?
  end

  private

  def json_request?
    request.format.json?
  end
end
