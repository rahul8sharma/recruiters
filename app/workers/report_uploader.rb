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
end
