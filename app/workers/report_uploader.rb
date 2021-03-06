class ReportUploader < AbstractController::Base
  include Sidekiq::Worker
  include AbstractController::Rendering
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths
  include Vger::Helpers::AuthenticationHelper
  include Rails.application.routes.url_helpers
  include UploadHelper
  helper ApplicationHelper
  helper ReportsHelper
  helper_method :protect_against_forgery?
  self.view_paths = "app/views"
  
  Recruiters::Application.routes.default_url_options = { :host => ActionController::Base.asset_host }
  self.asset_host = ActionController::Base.asset_host

  def protect_against_forgery?
    false
  end
  
  def perform(report_attributes, auth_token, patch={})
    tries = 0
    begin
      @report_attributes = report_attributes.with_indifferent_access
      @patch = patch
      Rails.logger.debug "************* #{report_attributes} ******************"
      get_token({ auth_token: auth_token }).token
      upload_report
    rescue Faraday::Unauthorized => exception
      Rails.logger.debug exception.class
      Rails.logger.debug exception.message
      get_token({ auth_token: auth_token }).token
      retry  
    rescue SocketError, Faraday::ConnectionFailed => exception
      Rails.logger.debug exception.class
      Rails.logger.debug exception.message
      sleep(10)
      retry  
    rescue Exception => exception
      Rails.logger.debug exception.class
      Rails.logger.debug exception.message
      tries = tries + 1
      if tries < 5
        retry
      else
        upload_failed(exception)
      end
    end 
  end
end
