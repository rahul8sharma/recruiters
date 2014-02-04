class TrainingRequirementGroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_company
  
  layout "training_requirement_groups"
  
  def index
    @training_requirement_groups = Vger::Resources::Suitability::TrainingRequirementGroup.where(:query_options => {  
                            company_id: @company.id
                          },
                          methods: [:url],
                          page: params[:page],
                          per: 10
                        ).all
  end
  
  def show
  end
  
  protected
  
  def get_company
    methods = []
    if ["show","index", "training_requirements"].include? params[:action]
      if Rails.application.config.statistics[:load_assessmentwise_statistics]
        methods << :assessmentwise_statistics
      end
    end
    @company = Vger::Resources::Company.find(params[:company_id], :methods => methods)
  end
end
