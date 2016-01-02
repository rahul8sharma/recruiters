module Oac::ExerciseHelper
  def landing_page_for_oac_exercise(exercise)
    send "landing_page_for_#{exercise.workflow_status}_oac_exercise", exercise
  end
  
  def landing_page_for_new_oac_exercise(exercise)
    select_tools_company_oac_exercise_path(exercise.company_id, exercise.id)
  end
  
  def landing_page_for_creating_oac_exercise(exercise)
    "#"
  end
  
  def landing_page_for_marked_for_creation_oac_exercise(exercise)
    candidates_company_oac_exercise_path(exercise.company_id, exercise.id)
  end
  
  def landing_page_for_ready_oac_exercise(exercise)
    candidates_company_oac_exercise_path(exercise.company_id, exercise.id)
  end
  
  def landing_page_for_failed_oac_exercise(exercise)
    select_tools_company_oac_exercise_path(exercise.company_id, exercise.id)
  end
end
