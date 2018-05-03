export const CustomActions = {
  meta_data: {method: 'GET', url: '/companies{/company_id}/acdc/meta_data'},
  languages: {method: 'GET', url: '/companies{/company_id}/acdc/languages'},
  products: {method: 'GET', url: '/companies{/company_id}/acdc/products'},
  defined_forms: {method: 'GET', url: '/companies{/company_id}/acdc/defined_forms'},
  defined_field: {method: 'GET', url: '/companies{/company_id}/acdc/defined_field{/defined_form_id}'},
  competencies: {method: 'GET', url: '/companies{/company_id}/acdc/competencies'},
  select_templates: {method: 'GET', url: '/companies{/company_id}/acdc/select_templates'}
};