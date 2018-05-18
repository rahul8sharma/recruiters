export const CustomActions = {
  meta_data: {method: 'GET', url: '/companies{/company_id}/acdc/meta_data'},
  languages: {method: 'GET', url: '/companies{/company_id}/acdc/languages'},
  products: {method: 'GET', url: '/companies{/company_id}/acdc/products'},
  defined_forms: {method: 'GET', url: '/companies{/company_id}/acdc/defined_forms'},
  defined_field: {method: 'GET', url: '/companies{/company_id}/acdc/defined_field{/defined_form_id}'},
  traits: {method: 'GET', url: '/companies{/company_id}/acdc/traits'},
  select_templates: {method: 'GET', url: '/companies{/company_id}/acdc/select_templates'},
  get_objective_and_subject_questions: {method: 'GET', url: '/companies{/company_id}/acdc/get_objective_and_subject_questions'}
};