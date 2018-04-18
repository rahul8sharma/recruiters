<template>
	<div>
		<hr>
      <span>
        <button @click='create_assessment'>Create Default Assessment</button>
        <button @click='update_assessment'>Update Default Assessment</button>
        <button @click='show_assessment'>Show Default Assessment</button>
        <button @click='get_meta_data'>fetch fucntion area, exprinces, Industry</button>
      </span>
    <hr>
	</div>	
</template>

<script type="text/javascript">
	export default {
		methods: {
			create_assessment: function () {
			 this.$store.dispatch('update_acdc_assessment')
			},
			update_assessment: function () {
			 this.$store.dispatch('update_acdc_assessment')
			},
			show_assessment: function () {
			 this.$store.dispatch('update_acdc_assessment')
			},
			get_meta_data: function () {
			 this.$store.dispatch('fetch_meta_data')
			}
    }
	}
</script>