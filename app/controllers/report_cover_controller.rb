class ReportCoverController < ApplicationController
  layout false

  def cover
  	render template: "report_cover/suitability_competency_pdf.html.haml"
  end

end
