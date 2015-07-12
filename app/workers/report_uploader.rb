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

  def protect_against_forgery?
    false
  end
end
