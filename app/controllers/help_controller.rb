class HelpController < ApplicationController
  layout "help"
  before_filter :authenticate_user!
  def adding_candidates
  end
  
  def download_sample_csv_for_candidate_bulk_upload
    file_path = Rails.application.assets['candidates_bulk_upload.csv'].pathname
    send_file(file_path,
      :filename => "bulk_upload_sample.csv")
  end
end
