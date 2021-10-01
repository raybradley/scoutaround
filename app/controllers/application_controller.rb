# frozen_string_literal: true

# base Controller class
class ApplicationController < ActionController::Base
  include Pundit
  before_action :authenticate_user!
  before_action :process_query_string
  after_action  :clear_session_view

  def new_session_path(_scope)
    new_user_session_path
  end

  def set_cors_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
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

  def authenticate_user!
    return if user_signed_in? # <- do we really want this?

    if (magic_link = MagicLink.find_by(token: params[:r]))
      sign_in magic_link.user
      session[:via_magic_link] = true
      flash[:notice] = t('magic_links.login_success', name: current_user.full_name)
      # redirect_to request.base_url
      return
    end

    super
  end
end
