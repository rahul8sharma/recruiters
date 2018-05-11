module TemplatesHelper
  def get_templates_for_company(query_options, company_id)
    return Vger::Resources::Template\
      .where(
        query_options: query_options, 
        joins: :template_category,
        scopes: { global_or_for_company_id: company_id }
      ).all.to_a
  end
  
  def get_global_templates(query_options)
    return Vger::Resources::Template\
      .where(
        query_options: query_options, 
        joins: :template_category,
        scopes: { global: nil }
      ).all.to_a
  end

  def get_templates_for_company_specific(query_options, company_id)
    return Vger::Resources::Template\
      .where(
        query_options: query_options,
        joins: :template_category,
        scopes: { for_company_id: company_id }
      ).all.to_a
  end
end
