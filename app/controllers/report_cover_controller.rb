class ReportCoverController < ApplicationController
  layout false

  def cover
    render template: "report_cover/suitability_competency_pdf.html.haml"
  end
  
  def oac_cover
    @report = Vger::Resources::Oac::UserExerciseReport.find(params[:report_id])
    cover_page_section = @report.report_configuration["pdf"]["sections"].find do |section|
      section['id'] == 'pdf_cover_page'
    end
    request.format = 'html' 
    @section_value = cover_page_section['children']
    respond_to do |format|
      format.html {
        render template: "report_cover/oac_cover", 
              formats: ['pdf'], handlers: ['haml'],
              layout: 'layouts/oac/reports'
      }
    end
  end

end
