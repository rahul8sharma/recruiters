class Oac::AssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_user!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_tools, :only => [:select_tools]
  layout 'oac/oac'

  def home  
  end

  def select_tools
    @exercise = Vger::Resources::Oac::Exercise.new
  end

  def select_competencies
  end

  def set_weightage
  end

  def customize_assessment
  end

  def add_candidates
  end

  def send_assessment
  end

  def assign_assessor
  end

  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end
  
  def get_tools
    @tools = Vger::Resources::Oac::Tool.all
  end

end
