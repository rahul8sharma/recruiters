class Acdc::AssessmentsController < ApplicationController
  # before_action :set_acdc_assessment, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action { authorize_user!(params[:company_id]) }
  before_action :get_company

  layout 'acdc/acdc'

  def index
  end

  def edit
  end

  def create
  end

  def update
  end

  private
    #Return current company
    def get_company
      @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def acdc_assessment_params
      params.fetch(:acdc_assessment, {})
    end
end
