<template>
  <div id="app">
    <h2>
      Wallet
    </h2>
    <h3 id="address"></h3>

      <div id="console" style="white-space: pre-line">
        <p style="white-space: pre-line"></p>
      </div>
      <div id="show" >
       
      </div>

    <div v-if="loggedin">
      <div class="flex-container">
        <div>
          <button class="card" @click="getUserInfo" style="cursor: pointer">
            Get User Info
          </button>
        </div>
        <div>
          <button
            class="card"
            @click="authenticateUser"
            style="cursor: pointer">
            Get ID Token
          </button>
        </div>
        <div>
          <button class="card" @click="getChainId" style="cursor: pointer">
            Get Chain ID
          </button>
        </div>
        <div>
          <button class="card" @click="addChain" style="cursor: pointer">
            Add Chain
          </button>
        </div>
        <div>
          <button class="card" @click="switchChain" style="cursor: pointer">
            Switch Chain
          </button>
        </div>
        <div>
          <button class="card" @click="getAccounts" style="cursor: pointer">
            Get Accounts
          </button>
        </div>
        <div>
          <button class="card" @click="getBalance" style="cursor: pointer">
            Get Balance
          </button>
        </div>
        <div>
          <button class="card" @click="sendTransaction" style="cursor: pointer">
            Send Transaction
          </button>
        </div>
        <div>
          <button class="card" @click="signMessage" style="cursor: pointer">
            Sign Message
          </button>
        </div>
        <div>
          <button class="card" @click="getPrivateKey" style="cursor: pointer">
            Get Private Key
          </button>
        </div>
        <div>
          <button class="card" @click="logout" style="cursor: pointer">
            Logout
          </button>
        </div>
      </div>
      <div id="console" style="white-space: pre-line">
        <p style="white-space: pre-line"></p>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { ref, onMounted } from "vue";
import { Web3Auth } from "@web3auth/modal";
import { CHAIN_NAMESPACES, SafeEventEmitterProvider } from "@web3auth/base";
import RPC from "../web3RPC";
import {EvmLink , EvmWallet} from "@evmlink/api"
// Plugins
import { TorusWalletConnectorPlugin } from "@web3auth/torus-wallet-connector-plugin";

// Adapters
import { WalletConnectV1Adapter } from "@web3auth/wallet-connect-v1-adapter";
import { MetamaskAdapter } from "@web3auth/metamask-adapter";
import { TorusWalletAdapter } from "@web3auth/torus-evm-adapter";
import Web3 from 'web3';

//Web3modal


declare var window: any
export default {
  // eslint-disable-next-line vue/multi-word-component-names
  name: "Home",
  props: {
    msg: String,
  },
 data() {
    return {
      connected: false,
      contractResult: '',
      _e:{},
      _provider:"https://poly-rpc.gateway.pokt.network"
    }
  },
  setup() {
    const axios = require('axios')
    const newLink = ref<boolean>(false);
    const loggedin = ref<boolean>(false);
    const loading = ref<boolean>(false);
    const loginButtonStatus = ref<string>("");
    const connecting = ref<boolean>(false);
    let provider = ref<SafeEventEmitterProvider | any>(false);
    const clientId =
      "BMeKXMBvhpRgxYWnPbnVQ_CmsH-z9sSNqyfYmrCsVMSQJ0ByCLRoPaXZ7hYCS0EBkgiqkMlaOLw5E0_L13DG99U"; // get from https://dashboard.web3auth.io

    const chainProvider = "https://poly-rpc.gateway.pokt.network";
    const web3auth = new Web3Auth({
      clientId,
      chainConfig: {
        chainNamespace: CHAIN_NAMESPACES.EIP155,
        chainId: "0x13881",
        rpcTarget: "https://matic-mumbai.chainstacklabs.com", // This is the public RPC we have added, please pass on your own endpoint while creating an app
      },
      uiConfig: {
        defaultLanguage: "en",
      },
      web3AuthNetwork: "cyan",
    });

    // plugins and adapters are optional and can be added as per your requirement
    // read more about plugins here: https://web3auth.io/docs/sdk/web/plugins/

    // adding torus wallet connector plugin

    const torusPlugin = new TorusWalletConnectorPlugin({
      torusWalletOpts: {},
      walletInitOptions: {
        whiteLabel: {
          theme: { isDark: true, colors: { primary: "#00a8ff" } },
          logoDark: "https://web3auth.io/images/w3a-L-Favicon-1.svg",
          logoLight: "https://web3auth.io/images/w3a-D-Favicon-1.svg",
        },
        useWalletConnect: true,
        enableLogging: true,
      },
    });

    // read more about adapters here: https://web3auth.io/docs/sdk/web/adapters/

    // adding wallet connect v1 adapter

    const walletConnectV1Adapter = new WalletConnectV1Adapter({
      adapterSettings: {
        bridge: "https://bridge.walletconnect.org",
      },
      clientId,
    });

    web3auth.configureAdapter(walletConnectV1Adapter);

    // adding metamask adapter

    const metamaskAdapter = new MetamaskAdapter({
      clientId,
      sessionTime: 3600, // 1 hour in seconds
      web3AuthNetwork: "cyan",
      chainConfig: {
        chainNamespace: CHAIN_NAMESPACES.EIP155,
        chainId: "0x1",
        rpcTarget: "https://rpc.ankr.com/eth", // This is the public RPC we have added, please pass on your own endpoint while creating an app
      },
    });
    // we can change the above settings using this function
    metamaskAdapter.setAdapterSettings({
      sessionTime: 86400, // 1 day in seconds
      chainConfig: {
        chainNamespace: CHAIN_NAMESPACES.EIP155,
        chainId: "0x89",
        rpcTarget: "https://rpc-mainnet.matic.network", // This is the public RPC we have added, please pass on your own endpoint while creating an app
      },
      web3AuthNetwork: "cyan",
    });

    // it will add/update  the metamask adapter in to web3auth class
    web3auth.configureAdapter(metamaskAdapter);

    const torusWalletAdapter = new TorusWalletAdapter({
      clientId,
    });

    // it will add/update  the torus-evm adapter in to web3auth class
    web3auth.configureAdapter(torusWalletAdapter);

    onMounted(async () => {
      try {
        var _e = await decodeUrl()
        uiSetAddress(_e.keypair.address,_e.keypair.privateKey)
        await getAccountBalance(_e)
        await getTokenListAmount(_e)
        loading.value = true;
        loggedin.value = false;
        await web3auth.initModal();
        await web3auth.addPlugin(torusPlugin);
        if (web3auth.provider) {
          provider = web3auth.provider;
          loggedin.value = true;
        }
      } catch (error) {
        uiConsole("error", error);
      } finally {
        loading.value = false;
      }
    });



    const createLink = async()=>{
      EvmLink.create("/","http://192.168.1.103:8080/",false,137,"Happy Birthday !").then(evmlink => {
        // console.log("link: ", evmlink.url.toString());
        // console.log("publicKey: ", evmlink.keypair.address);
        newLink.value = true;
        uiConsole(
          {
            link:evmlink.url.toString(),
            address:evmlink.keypair.address
          }
        )
        return evmlink;
      });
    };

    const createLinkEncrypt = async()=>{
      EvmLink.create("/","http://192.168.1.103:8080/",true,137,"Happy Birthday !").then(evmlink => {
        // console.log("link: ", evmlink.url.toString());
        // console.log("publicKey: ", evmlink.keypair.address);
        newLink.value = true;
        uiConsole(
          {
            link:evmlink.url.toString(),
            address:evmlink.keypair.address
          }
        )
        return evmlink;
      });
    };

    const decodeUrl = async()=>{
      var evmlink = await EvmLink.fromUrl(window.location);
      // console.log(evmlink)
      // document.getElementById('walletAddress').innerHTML=evmlink.address
      // document.getElementById('walletAddress').innerHTML = "hello";
      // console.log(document.getElementById('walletAddress'))
      return evmlink;
      uiConsole(evmlink)
    };

    const login = async () => {
      if (!web3auth) {
        uiConsole("web3auth not initialized yet");
        return;
      }
      provider = await web3auth.connect();
      loggedin.value = true;
      uiConsole("Logged in Successfully!");
    };

    const authenticateUser = async () => {
      if (!web3auth) {
        uiConsole("web3auth not initialized yet");
        return;
      }
      const idToken = await web3auth.authenticateUser();
      uiConsole(idToken);
    };

    const getUserInfo = async () => {
      if (!web3auth) {
        uiConsole("web3auth not initialized yet");
        return;
      }
      const user = await web3auth.getUserInfo();
      uiConsole(user);
    };

    const logout = async () => {
      if (!web3auth) {
        uiConsole("web3auth not initialized yet");
        return;
      }
      await web3auth.logout();
      provider = null;
      loggedin.value = false;
    };

    const getChainId = async () => {
      if (!provider) {
        uiConsole("provider not initialized yet");
        return;
      }
      const rpc = new RPC(provider);
      const chainId = await rpc.getChainId();
      uiConsole(chainId);
    };

    const addChain = async () => {
      if (!provider) {
        uiConsole("provider not initialized yet");
        return;
      }
      const newChain = {
        chainId: "0x5",
        displayName: "Goerli",
        chainNamespace: CHAIN_NAMESPACES.EIP155,
        tickerName: "Goerli",
        ticker: "ETH",
        decimals: 18,
        rpcTarget: "https://rpc.ankr.com/eth_goerli",
        blockExplorer: "https://goerli.etherscan.io",
      };
      await web3auth?.addChain(newChain);
      uiConsole("New Chain Added");
    };

    const switchChain = async () => {
      if (!provider) {
        uiConsole("provider not initialized yet");
        return;
      }
      const newChain = {
        chainId: "0x5",
        displayName: "Goerli",
        chainNamespace: CHAIN_NAMESPACES.EIP155,
        tickerName: "Goerli",
        ticker: "ETH",
        decimals: 18,
        rpcTarget: "https://rpc.ankr.com/eth_goerli",
        blockExplorer: "https://goerli.etherscan.io",
      };
      await web3auth?.switchChain({ chainId: "0x5" });
      uiConsole("Chain Switched");
    };

    const getAccounts = async () => {
      if (!provider) {
        uiConsole("provider not initialized yet");
        return;
      }
      const rpc = new RPC(provider);
      const address = await rpc.getAccounts();
      uiConsole(address);
    };

    const getBalance = async () => {
      if (!provider) {
        uiConsole("provider not initialized yet");
        return;
      }
      const rpc = new RPC(provider);
      const balance = await rpc.getBalance();
      uiConsole(balance);
    };

    const sendTransaction = async () => {
      if (!provider) {
        uiConsole("provider not initialized yet");
        return;
      }
      const rpc = new RPC(provider);
      const receipt = await rpc.sendTransaction();
      uiConsole(receipt);
    };

    const signMessage = async () => {
      if (!provider) {
        uiConsole("provider not initialized yet");
        return;
      }
      const rpc = new RPC(provider);
      const signedMessage = await rpc.signMessage();
      uiConsole(signedMessage);
    };

    const getPrivateKey = async () => {
      if (!provider) {
        uiConsole("provider not initialized yet");
        return;
      }
      const rpc = new RPC(provider);
      const privateKey = await rpc.getPrivateKey();
      uiConsole(privateKey);
    };

    function uiConsole(...args: any[]): void {
      const el = document.querySelector("#console>p");
      if (el) {
        el.innerHTML = JSON.stringify(args || {}, null, 2);
      }
    };


    function uiSetAddress(address:any,privateKey:any): void {
      const el = document.querySelector("#address");
      if (el) {
        el.innerHTML += '<p>Address : '+address+'</p>' +'<br>'+'<p>PrivateKey : '+privateKey+'</p>' ;
      }
    };

    function uiBalance(symbol:any,amount:any): void {
      const el = document.querySelector("#show");
      if (el) {
        el.innerHTML += '<p class="card"  style="cursor: pointer">'+symbol+' : '+amount+'</p>' +'<input id="address_'+symbol+'" placeholder="target address">'+'<input id="amount_'+symbol+'" placeholder="amount to transfer">'+ '<button @click="transferErc20">Transfer</button>';
      }
    };


    function uiErc20Balance(symbol:any,amount:any): void {
      const el = document.querySelector("#show");
      if (el) {
        el.innerHTML += '<p class="card"  style="cursor: pointer">'+symbol+' : '+amount+'</p>' +'<input id="address_'+symbol+'" placeholder="target address">'+'<input id="amount_'+symbol+'" placeholder="amount to transfer">'+ '<button @click="transferErc20('+symbol+')">Transfer</button>';
      }
    };

    const getAccountBalance = async (_e:EvmLink)=>{
      var balance = await EvmWallet.getBalance(
          _e.keypair.privateKey,
          "https://poly-rpc.gateway.pokt.network",
          _e.chainId
      )
      uiBalance(
        "Matic ",
        balance
      )
      console.log("My matic balance : "+balance)
    }

    const getTokenListAmount = async (_e:EvmLink)=>{
      // console.log(_e.keypair.privateKey)
      const TOKEN_LISTS = {
        eth:    'https://raw.githubusercontent.com/viaprotocol/tokenlists/main/tokenlists/ethereum.json',
        avax:    'https://raw.githubusercontent.com/viaprotocol/tokenlists/main/tokenlists/avax.json',
        bnb:    'https://raw.githubusercontent.com/viaprotocol/tokenlists/main/tokenlists/bsc.json',
        matic:    'https://raw.githubusercontent.com/maticnetwork/polygon-token-list/dev/src/tokens/popularTokens.json',
      }
      const erc20abiReq = await axios.get("https://gist.githubusercontent.com/veox/8800debbf56e24718f9f483e1e40c35c/raw/f853187315486225002ba56e5283c1dba0556e6f/erc20.abi.json");
      const erc20abi = erc20abiReq.data;
      const tokenSource = TOKEN_LISTS["matic"]
      const res = await axios.get(tokenSource)
      var ret = await getAllTokenBalances(res.data,_e,erc20abi)
      ret = JSON.parse(JSON.stringify(ret));
      for(var i = 0 ; i < ret.length ; i ++)
      {
        //Search for the token list that i have 
        if(Number(JSON.parse(JSON.stringify(ret[i].balance)).value)>0)
        {
            console.log(ret[i])
            uiErc20Balance(
              ret[i].symbol,
              Number(JSON.parse(JSON.stringify(ret[i].balance)).value)
            )
        }
      }
      // console.log(ret)
      return res.data
    }


    const getAllTokenBalances = async (tokenList:any, _e:any , erc20abi:any) => {
      // array to store all balance requests
      let proms = []
      // array to store balances
      let results = []
      for (const ele of tokenList) {
        proms.push(
        EvmWallet.readContract(
          _e.keypair.privateKey,
          "https://poly-rpc.gateway.pokt.network",
          _e.chainId,
          {
            abi:erc20abi,
            address:ele.address,
            functionName:"balanceOf",
            method:[_e.keypair.address],
            value:0
          }
        )
        )
      }
      const promiseResults = await Promise.allSettled(proms)
      for (let index = 0; index < promiseResults.length; index++) {
        const bal = promiseResults[index];
        results.push({
          name: tokenList[index].name,
          symbol: tokenList[index].symbol,
          balance: bal,
        })
      }
      return results
  }

    const transferErc20 = async (symbol : any)=>{
      console.log("🔥Click");
      var _e = await decodeUrl()
      console.log(_e)
      console.log(symbol);
      // console.log(globalE)
    }


    return {
      newLink,
      loggedin,
      loading,
      loginButtonStatus,
      connecting,
      provider,
      web3auth,
      login,
      authenticateUser,
      logout,
      getUserInfo,
      getChainId,
      addChain,
      switchChain,
      getAccounts,
      getBalance,
      sendTransaction,
      signMessage,
      getPrivateKey,
      createLink,
      createLinkEncrypt,
      getTokenListAmount,
      transferErc20
    };
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
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
