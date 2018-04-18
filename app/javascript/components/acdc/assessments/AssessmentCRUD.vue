<template>
	<div>
		<hr>
      <span>
        <button @click='create_assessment'>Create Default Assessment</button>
        <button @click='update_assessment'>Update Default Assessment</button>
        <button @click='show_assessment'>Show Default Assessment</button>
        <button @click='get_meta_data'>Fetch Functional Areas, Job Experiences, Industries</button>
      </span>
    <hr>
	</div>	
</template>

<script type="text/javascript">
	export default {
		methods: {
			create_assessment: function () {
			 this.$store.dispatch('create_acdc_assessment', {
          acdc_assessment: {
            name: "raw_data",
            company_id: 2,
            user_id: 176698,
            raw_data: {test: 'example'}
          } //TODO need to change
        })
			},
			update_assessment: function () {
			 this.$store.dispatch('update_acdc_assessment', {
	      	acdc_assessment: {
	          raw_data: {test: 'example2'}
	        } //TODO need to change
	      })
			},
			show_assessment: function () {
			 this.$store.dispatch('show_acdc_assessment')
			},
			get_meta_data: function () {
			 this.$store.dispatch('fetch_meta_data')
			}
    }
	}
</script>