module Suitability::FitmentGradesHelper
  def get_job_fit_grade(candidate_fit_scores)
    candidate_fit_scores.select{ |fit_score| ["job","role"].any?{|fit_name| fit_score.fit.name.downcase =~ /#{fit_name}/ } }.first.fitment_grade.name
  end
  
  def get_company_fit_grade(candidate_fit_scores)
    candidate_fit_scores.select{ |fit_score| ["organization","company"].any?{|fit_name| fit_score.fit.name.downcase =~ /#{fit_name}/ } }.first.fitment_grade.name
  end
  
  def get_team_fit_grade(candidate_fit_scores)
    candidate_fit_scores.select{ |fit_score| ["team","people"].any?{|fit_name| fit_score.fit.name.downcase =~ /#{fit_name}/ } }.first.fitment_grade.name
  end
  
  def get_job_fit(fits)
    fits.select{|fit| ["job","role"].any?{|fit_name| fit.name.downcase =~ /#{fit_name}/ }  }.first
  end
  
  def get_company_fit(fits)
    fits.select{|fit| ["organization","company"].any?{|fit_name| fit.name.downcase =~ /#{fit_name}/ }  }.first
  end
  
  def get_team_fit(fits)
    fits.select{|fit| ["team","people"].any?{|fit_name| fit.name.downcase =~ /#{fit_name}/ }  }.first
  end
end
