<template>
    <select>
      <slot></slot>
  </select>
</template>
<script>
  import select2 from 'select2'
  import $ from "jquery";

  export default {
    props: ['options', 'value', 'initializeData', 'traitData'],
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
          let tabData = vm.traitData.tabData
          let currentTraitIndex = vm.traitData.traitIndex
          let taritLength = tabData.length
          

          let index = indexWhere(vm.traitData.factors, item => item.name === currentTraitValue)
          if(index > -1) {
            let factor = vm.traitData.factors[index]

            vm.traitData.selectedtraits[currentTraitIndex] = currentTraitValue

            if(vm.traitData.items[currentTraitIndex][0] == 'Select Trait') {
              vm.traitData.items[currentTraitIndex].splice(0, 1);

              let currentTritId = 'trait_id_' + currentTraitIndex
              let currentTraitSelect = document.getElementById(currentTritId)
              currentTraitSelect.remove(0)
            }

            tabData[currentTraitIndex].factor_id = factor.id
            tabData[currentTraitIndex].name = factor.name
            tabData[currentTraitIndex].to_norm_bucket = vm.traitData.options[(factor.to_norm_bucket_id - 1)]
            tabData[currentTraitIndex].from_norm_bucket = vm.traitData.options[(factor.from_norm_bucket_id - 1)]
          }
          for (var i = 0; i < taritLength; i++) {
            if(i != currentTraitIndex && currentTraitValue != 'Select Trait') {
              let traitIndex = vm.traitData.items[i].indexOf(currentTraitValue);
              if (traitIndex > -1) {
                 vm.traitData.items[i].splice(traitIndex, 1);
              }
              let currentTritId = 'trait_id_' + i
              let currentTraitSelect = document.getElementById(currentTritId)
              for (var j=0; j<currentTraitSelect.length; j++){
                if (currentTraitSelect.options[j].value == currentTraitValue ) {
                   currentTraitSelect.remove(j);
                    break;
                }
              }
              if(this.previousValue != 'Select Trait') {
                vm.traitData.items[i].push(this.previousValue)
                let currentTritId = 'trait_id_' + i
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
