class HelpController < ApplicationController
  layout "help"
  before_action :authenticate_user!
  def adding_users
  end

  def process_explanation
  end
  
  def download_sample_csv_for_user_bulk_upload
    file_path = Rails.application.assets['users_bulk_upload.xls'].pathname
    send_file(file_path,
      :filename => "bulk_upload_sample.xls")
  end
end
