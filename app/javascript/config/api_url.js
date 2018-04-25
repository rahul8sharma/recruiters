export const CustomActions = {
  meta_data: {method: 'GET', url: '/companies{/company_id}/acdc/meta_data'},
  languages: {method: 'GET', url: '/companies{/company_id}/acdc/languages'},
  products: {method: 'GET', url: '/companies{/company_id}/acdc/products'}
};