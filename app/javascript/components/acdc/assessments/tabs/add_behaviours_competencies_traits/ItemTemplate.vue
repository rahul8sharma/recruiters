<template>
  <div>
    <p>{{ item }}</p>
  </div>
</template>
<script>
export default {
  props: {
    item: { required: true }
  }
}
</script>
