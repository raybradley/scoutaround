# frozen_string_literal: true

# base Controller class
class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :authenticate_user!
  before_action :process_query_string
  after_action :clear_session_view
  after_action :track_action
  before_action do
    Rack::MiniProfiler.authorize_request if current_user&.super_admin?
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized 

  def new_session_path(_scope)
    new_user_session_path
  end

  def set_cors_headers
    headers["Access-Control-Allow-Origin"] = "*"
    headers["Access-Control-Request-Method"] = "*"
  end

  # if a ?view=NNNN querystring is present, stuff the value
  # into the session and then redirect to the base URL, thus
  # stripping the querystring off
  # DANGER: this might interfere with other querystrings in the future
  def process_query_string
    session[:view] ||= params[:view]
    redirect_to request.path if params[:view]
  end

  def clear_session_view
    session[:view] = nil
  end

  def page_title(*args)
    @page_title = if args.is_a?(Array)
                    args
                  elsif args[0].is_a?(String)
                    [args[0]]
                  else
                    []
                  end
  end

  # devise redirect after signout
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def current_member; end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(root_path)
  end

  def mobile_device?
    return false unless request&.headers.present?

    request.headers["User-Agent"]&.match?(/iPhone/)
  end

  protected

  def track_action
    ahoy.track tracking_description, request.path_parameters
  end

  def tracking_description
    "#{controller_name}##{action_name}"
  end
end
