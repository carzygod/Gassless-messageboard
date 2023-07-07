<template>

    <div v-if="mainPage">
      <Home />
      <ConnectWallte/>
    </div>

</template>
<script>
import ConnectWallte from './components/ConnectWallteExample.vue';
import Home from "./Home.vue"
import walletLink from "./components/Link.vue"
export default {
   data() {
    return {
      mainPage: true,
      walletPage:false
    }
  },
    components: {
        Home,
  },
  mounted() {
    //Manully make a vue router (lol)
    if(window.location.pathname.split("/").length>2)
    {
      this.$data.mainPage = false
      this.$data.walletPage = true
    }
  },
}
</script>
<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
