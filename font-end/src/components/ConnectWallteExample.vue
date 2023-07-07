<template>
  <div>
    <div>
      <button @click="handleWalletConnect" class="card"  style="cursor: pointer">Connect wallet</button>
    </div>
    <div id="console" style="white-space: pre-line"><p id = "consoleui" style="white-space: pre-line"></p></div>
  </div>
</template>
<script setup>
import { computed } from 'vue';
import { utils } from 'web3';
import useWallet from '../hooks/useWallte';
import { USDT_API } from '../web3/abis';
import { USDT_ADDRESS } from '../web3/config';

const {
  onConnect,
  connected,
  web3,
  userAddress,
  chainId,
  networkId,
  resetApp,
  assets,
  getAccountAssets,
} = useWallet();

const handleWalletConnect = async () => {
  var address = await onConnect();
  if (connected) {
    console.log('afterConnectdWallet', connected);
  }
  console.log(address)
  document.getElementById('consoleui').outerHTML=address
};
const contract = computed(
  () => new web3.value.eth.Contract(USDT_API, USDT_ADDRESS),
);
function approve() {
  return contract.value.methods
    .approve(USDT_ADDRESS, utils.toHex(utils.toWei('1000000000000000000000000000', 'gwei')))
    .send({ from: userAddress.value });
}

// .....

</script>


<style scoped>
#app {
  width: 80%;
  margin: auto;
  padding: 0 2rem;
}
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
.card {
  margin: 0.5rem;
  padding: 0.7rem;
  text-align: center;
  color: #0070f3;
  background-color: #fafafa;
  text-decoration: none;
  border: 1px solid #0070f3;
  border-radius: 10px;
  transition: color 0.15s ease, border-color 0.15s ease;
  width: 100%;
}

.card:hover,
.card:focus,
.card:active {
  cursor: pointer;
  background-color: #f1f1f1;
}

.flex-container {
  display: flex;
  flex-flow: row wrap;
}

.flex-container > div {
  width: 100px;
  margin: 10px;
  text-align: center;
  line-height: 75px;
  font-size: 30px;
}

#console {
  width: 100%;
  height: 100%;
  overflow: auto;
  word-wrap: break-word;
  font-size: 16px;
  font-family: monospace;
  text-align: left;
}
</style>
