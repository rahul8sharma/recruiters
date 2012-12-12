class JobsController < ApplicationController
  before_filter :init_section, :only => [:edit, :update]
  before_filter :init_status, :only => [:status]

  # GET /jobs/<id>
  def show
  end

  # GET /jobs/<id>/preview
  def preview
  end

  # GET /<job-id>/edit/<section:(job_details | company_details | additional_details | hiring_preferences | job_requirements | logistics)>
  def edit
  end

  # GET /<status:(open | pending | closed | incomplete)>
  def status
  end

  private

  # Extract status from url
  def init_status
    @status = params[:status]
  end

  # Extract section name from url
  def init_section
    @section = params[:section].underscore
  end
end
