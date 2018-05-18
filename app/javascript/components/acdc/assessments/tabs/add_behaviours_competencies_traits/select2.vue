<template>
    <select>
      <slot></slot>
  </select>
</template>
<style type="text/css" src="select2/dist/css/select2.min.css"></style>
<script>
  import select2 from 'select2'
  import $ from "jquery";

  export default {
    props: ['options', 'value', 'competencyData', 'initializeData'],
    data: function() {
      return {
        previousValue: ''
      }
    },
    mounted: function () {
      var vm = this
      $(this.$el)
        // init select2
        .select2({ 
          data: this.options,
        })

        .val(this.value)
        .trigger('change')
        // emit event on change.
        .on('change', function () {
            vm.$emit('options', this.options)
          vm.$emit('input', this.value)
        })
        .on('select2:select', function () {
          let currentTraitValue = this.value
          let tabData = vm.competencyData.tabData
          let currentCompetencyIndex = vm.competencyData.competencyIndex
          let currentTraitIndex = vm.competencyData.traitIndex
          let taritLength = tabData.competencies[vm.competencyData.competencyIndex].selectedFactors.length
          let competency = tabData.competencies[currentCompetencyIndex]

          let index = indexWhere(vm.competencyData.factors, item => item.name === currentTraitValue)
          if(index > -1) {
            let factor = vm.competencyData.factors[index]

            vm.competencyData.items[currentCompetencyIndex].competencySuggestion[currentTraitIndex] = currentTraitValue

            if(vm.competencyData.items[currentCompetencyIndex].factorNames[currentTraitIndex][0] == 'Select Trait') {
              vm.competencyData.items[currentCompetencyIndex].factorNames[currentTraitIndex].splice(0, 1);

              let currentTritId = 'trait_id_' + currentCompetencyIndex + '' + currentTraitIndex
              let currentTraitSelect = document.getElementById(currentTritId)
              currentTraitSelect.remove(0)
            }

            competency.selectedFactors[currentTraitIndex].factor_id = factor.id
            competency.selectedFactors[currentTraitIndex].name = factor.name
            competency.selectedFactors[currentTraitIndex].to_norm_bucket = vm.competencyData.options[(factor.to_norm_bucket_id - 1)]
            competency.selectedFactors[currentTraitIndex].from_norm_bucket = vm.competencyData.options[(factor.from_norm_bucket_id - 1)]
            competency.factor_ids[currentTraitIndex] = factor.id  
          }
          for (var i = 0; i < taritLength; i++) {
            if(i != currentTraitIndex && currentTraitValue != 'Select Trait') {
              let traitIndex = vm.competencyData.items[currentCompetencyIndex].factorNames[i].indexOf(currentTraitValue);
              if (traitIndex > -1) {
                 vm.competencyData.items[currentCompetencyIndex].factorNames[i].splice(traitIndex, 1);
              }
              let currentTritId = 'trait_id_' + currentCompetencyIndex + '' + i
              let currentTraitSelect = document.getElementById(currentTritId)
              for (var j=0; j<currentTraitSelect.length; j++){
                if (currentTraitSelect.options[j].value == currentTraitValue ) {
                   currentTraitSelect.remove(j);
                    break;
                }
              }
              if(this.previousValue != 'Select Trait') {
                vm.competencyData.items[currentCompetencyIndex].factorNames[i].push(this.previousValue)
                let currentTritId = 'trait_id_' + currentCompetencyIndex + '' + i
                let currentTraitSelect = document.getElementById(currentTritId)
                let option = ''
                option = document.createElement("option")
                option.text = this.previousValue
                currentTraitSelect.add(option);
              }
            }
          }
          vm.$emit('options', this.options)
          vm.$emit('input', this.value)
        })
        .on('select2:selecting', function () {
          this.previousValue = this.value
        })
    },
    watch: {
      value: function (value) {
        // update value
        $(this.$el)
          .val(value)
          .trigger('change')
      },
      options: function (options) {
        // update options
        $(this.$el).empty().select2({ data: options })
      },
      initializeData: function() {
        if(this.value != '') {
          $(this.$el)
          .val(this.value)
          .trigger('change')  
        } else {
          $(this.$el)
           .val('Select Trait')
           .trigger('change')  
        }
        
      }
    }, 
    destroyed: function () {
      $(this.$el).off().select2('destroy')
    }
  }

  function indexWhere(array, conditionFn) {
    const item = array.find(conditionFn)
    return array.indexOf(item)
  }
</script>
