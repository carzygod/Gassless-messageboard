<template>
  <div id="app">
    <h2>
      <a target="_blank" href="http://web3auth.io/" rel="noreferrer">
        Web3Auth
      </a>
      base message board
    </h2>

    <h2>
      <a>My Address : </a>
      <a id="myaddress"></a>
    </h2>

  <div>

  <div id="messageBox">
          
  </div>

</div>

    <button
      v-if="!loggedin"
      class="card"
      @click="login"
      style="cursor: pointer"
    >
      Login web3auth
    </button>


    <div v-if="loggedin">
      <div>

      <input type="text" placeholder="What do you want to say ?" v-model="inputVal" ref="getValue" @input="handleInput($event)">
      </div>

      <button       
            class="card"
            @click="leaveMsg"
            style="cursor: pointer">
            Leave Msg
      </button>

      <button       
            class="card"
            @click="login"
            style="cursor: pointer">
            Logout
      </button>


      <div class="flex-container">
        <div>

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
import RPC from "./web3RPC";
import {EvmLink , EvmWallet} from "@evmlink/api"
// Plugins
import { TorusWalletConnectorPlugin } from "@web3auth/torus-wallet-connector-plugin";

// Adapters
import { WalletConnectV1Adapter } from "@web3auth/wallet-connect-v1-adapter";
import { MetamaskAdapter } from "@web3auth/metamask-adapter";
import { TorusWalletAdapter } from "@web3auth/torus-evm-adapter";
import Web3 from 'web3';
import { AbiItem } from 'web3-utils'
import { ChainId } from "@biconomy/core-types";
import SmartAccount from "@biconomy/smart-account";
import HDWalletProvider from "@truffle/hdwallet-provider";
import { ethers } from "ethers";
//Web3modal

//Contract 

let myInput = "" ;
const dappKey = "";
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
     inputVal:'' ,
    }
  },
  methods: {
        handleInput: function(e:any){
            // console.log(e.target.value);
            myInput=e.target.value
        }
  },
  setup() {
    const newLink = ref<boolean>(false);
    const loggedin = ref<boolean>(false);
    const loading = ref<boolean>(false);
    const loginButtonStatus = ref<string>("");
    const connecting = ref<boolean>(false);
    let provider = ref<SafeEventEmitterProvider | any>(false);
    const clientId =
      ""; // get from https://dashboard.web3auth.io

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
        loading.value = true;
        loggedin.value = false;
        await web3auth.initModal();
        await web3auth.addPlugin(torusPlugin);
        if (web3auth.provider) {
          provider = web3auth.provider;
          loggedin.value = true;
        }
        await getData()
      } catch (error) {
        uiConsole("error", error);
      } finally {
        loading.value = false;
      }
    });

/**
*Interface list
**/

  interface typeMsg {
    owner:string,
    mid:number,
    tid:number
    data:string,
    time:number
  };

  interface typeTop {
    address:string,
    data:string,
    time:number,
    msgs:typeMsg[]
  };


    const login = async () => {
      if (!web3auth) {
        uiConsole("web3auth not initialized yet");
        return;
      }
      provider = await web3auth.connect();
      var address = await getAAaddress()
      if(address)
      {
              const el = document.querySelector("#myaddress");
              if(el)
              {
                  el.innerHTML = address
              }
              
      }

      // if (el) {
      //   el.innerHTML = JSON.stringify(args || {}, null, 2);
      // }
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

    const getEvmWalletBalance = async () => {
      if (!provider) {
        uiConsole("provider not initialized yet");
        return;
      }
      const rpc = new RPC(provider);
      const privateKey = await rpc.getPrivateKey();
      const balance = await EvmWallet.getBalance(
        privateKey,
        "https://poly-rpc.gateway.pokt.network",
        137
      )
      console.log(balance)
      uiConsole(balance);
    };

    const getAAaddress = async () => {
      console.log("get aa address");
            if (!provider) {
        uiConsole("provider not initialized yet");
        return;
      }
      // const rpc = new RPC(provider);
        let options = {
          activeNetworkId: ChainId.POLYGON_MUMBAI,
          supportedNetworksIds: [ChainId.POLYGON_MUMBAI],
          networkConfig: [
            {
              chainId: ChainId.POLYGON_MUMBAI,
              // Dapp API Key you will get from new Biconomy dashboard that will be live soon
              // Meanwhile you can use the test dapp api key mentioned above
              dappAPIKey: dappKey,// Replace your api key here
              providerUrl:  "https://rpc-mumbai.maticvigil.com"
            }
          ]
      }
      const rpc = new RPC(provider);
      const privateKey = await rpc.getPrivateKey();
      // var _p = new HDWalletProvider(privateKey, "https://rpc-mumbai.maticvigil.com");
      var p = new ethers.providers.Web3Provider(provider);
      let smartAccount = new SmartAccount(p, options);
      smartAccount = await smartAccount.init();
      uiConsole({"🔥 My AA address":smartAccount.address,"status":" 🔥Contract Deploying "});
      console.log("🔥My aa ",smartAccount.address);
      // const deployTx = await smartAccount.deployWalletUsingPaymaster()
      return smartAccount.address;
    }

    const deployAA = async () => {
      console.log("deploy aa");
      if (!provider) {
        uiConsole("provider not initialized yet");
        return;
      }
      // const rpc = new RPC(provider);
        let options = {
          activeNetworkId: ChainId.POLYGON_MUMBAI,
          supportedNetworksIds: [ChainId.POLYGON_MUMBAI],
          networkConfig: [
            {
              chainId: ChainId.POLYGON_MUMBAI,
              // Dapp API Key you will get from new Biconomy dashboard that will be live soon
              // Meanwhile you can use the test dapp api key mentioned above
              dappAPIKey:dappKey,//replace your Apikey here
              providerUrl:  "https://rpc-mumbai.maticvigil.com"
            }
          ]
      } 
      const rpc = new RPC(provider);
      const privateKey = await rpc.getPrivateKey();
      // var _p = new HDWalletProvider(privateKey, "https://rpc-mumbai.maticvigil.com");
      var p = new ethers.providers.Web3Provider(provider);
      let smartAccount = new SmartAccount(p, options);
      smartAccount = await smartAccount.init();
      uiConsole({"🔥 My AA address":smartAccount.address});
      console.log("🔥My aa ",smartAccount.address);
      return;
    }


    const leaveMsg = async () => {
      console.log("🔥leave msg")
      console.log(myInput)
      console.log("deploy aa");
      if (!provider) {
        uiConsole("provider not initialized yet");
        return;
      }
      // const rpc = new RPC(provider);
        let options = {
          activeNetworkId: ChainId.POLYGON_MUMBAI,
          supportedNetworksIds: [ChainId.POLYGON_MUMBAI],
          networkConfig: [
            {
              chainId: ChainId.POLYGON_MUMBAI,
              // Dapp API Key you will get from new Biconomy dashboard that will be live soon
              // Meanwhile you can use the test dapp api key mentioned above
              dappAPIKey: dappKey,//replace your Apikey here
              providerUrl:  "https://rpc-mumbai.maticvigil.com"
            }
          ]
      } 
      const rpc = new RPC(provider);
      const privateKey = await rpc.getPrivateKey();
      // var _p = new HDWalletProvider(privateKey, "https://rpc-mumbai.maticvigil.com");
      var p = new ethers.providers.Web3Provider(provider);
      let smartAccount = new SmartAccount(p, options);
      smartAccount = await smartAccount.init();
       
        const msgInterface = new ethers.utils.Interface([
          'function newMsg(uint256 tId ,uint256 mId,string memory data)'
        ])
        // Encode an ERC-20 token transfer to recipient of the specified amount\
        const usdcAddress = contractConfig.address
        const data = msgInterface.encodeFunctionData(
          'newMsg', [0,0,myInput]
        )
        const tx = {
          to: usdcAddress,
          data
        }

        // Transaction events subscription
        smartAccount.on('txHashGenerated', (response) => {
          console.log('txHashGenerated event received via emitter', response);
        });
        smartAccount.on('onHashChanged', (response) => {
          console.log('onHashChanged event received via emitter', response);
        });
        smartAccount.on('txMined', (response) => {
          console.log('txMined event received via emitter', response);
        });
        smartAccount.on('error', (response) => {
          console.log('error event received via emitter', response);
        });

        console.log(smartAccount.address)
        console.log(await smartAccount.getSmartAccountState())
        console.log(tx)
        uiConsole(tx);
        // // Sending gasless transaction
        const txResponse = await smartAccount.sendTransaction({ transaction: tx });
        console.log('userOp hash', txResponse.hash);
        // If you do not subscribe to listener, one can also get the receipt like shown below 
        const txReciept = await txResponse.wait();
        console.log('Tx hash', txReciept.transactionHash);
        uiConsole({"status":"🔥Transaction been minted","hash":txReciept.transactionHash})
      return;
    }

    const getData = async ()=>{
      console.log("🔥 Init the getdata function")
      var nonce = await getContractNonce();
      let nonceTopic =0;
      if(nonce!=undefined)
      {
        nonceTopic = Number(nonce[0])
      }
      console.log(nonce);
      var _topics = [

      ]
      var topics = [];
      for(var i = 0 ; i <nonceTopic+1 ;i++)
      {
        var _t = await getTopicById(i);
        topics.push(_t);
        if(_t&&_t[0]&&_t[1]&&_t[2]&&_t[3])
        {
          var _tt = {
            address:_t[0],
            data:_t[2],
            time:_t[3],
            msgs:[]
          }
          
          var _m = _t[1];
          for(var u = 0 ; u< Object.keys(_m).length ; u++)
          {
            var _msg = await getMsgById(_m[u]);
            if(_msg)
            {
              _tt.msgs.push(_msg)
            }
            
          }

          // console.log(_tt)
          await uiNewMsg(_tt);
          _topics.push(_tt);
        }
      }
      return _topics;
    }
    const uiNewMsg = async (topics:any)=>{
      console.log(topics)
      const el = document.querySelector("#messageBox");
      if(el)
      {
                  el.innerHTML += "<h3> Topic : "+topics.data+"</h3>"
          for(var u = 0 ; u< Object.keys(topics.msgs).length ; u++)
          {
                  el.innerHTML += "<p>"+topics.msgs[u]['owner']+" : <br>"+topics.msgs[u]['data']+"</p>"
          }
      }
      return 0 ;
    }

    const getContractNonce = async ()=>{
      console.log("🔥 Init the getdata function")
      var web3 = new Web3(new Web3.providers.HttpProvider("https://rpc-mumbai.maticvigil.com"))
      const  Ctr = new web3.eth.Contract(contractConfig.abi as AbiItem[],contractConfig.address);
      var ret ; 
      await Ctr.methods.getNonce().call()
                  .then(function(result:any){ 
                    ret = result;
              });
      return ret
    }

    const getTopicById = async (id:any)=>{
      console.log("🔥 Init the getdata function")
      var web3 = new Web3(new Web3.providers.HttpProvider("https://rpc-mumbai.maticvigil.com"))
      const  Ctr = new web3.eth.Contract(contractConfig.abi as AbiItem[],contractConfig.address);
      var ret ; 
      await Ctr.methods.getTopicById(id).call()
                  .then(function(result:any){ 
                    ret = result;
              });
      return ret
    }

    const getMsgById = async (id:any)=>{
      console.log("🔥 Init the getdata function")
      var web3 = new Web3(new Web3.providers.HttpProvider("https://rpc-mumbai.maticvigil.com"))
      const  Ctr = new web3.eth.Contract(contractConfig.abi as AbiItem[],contractConfig.address);
      var ret ; 
      await Ctr.methods.getMsgById(id).call()
                  .then(function(result:any){ 
                    ret = result;
              });
      return ret
    }
    const contractConfig = {
    "address":"0x5B965Cd3B8fD6f1166d4925646b59868e8972E60",
    "abi":[
        {
          "inputs": [],
          "stateMutability": "nonpayable",
          "type": "constructor"
        },
        {
          "inputs": [
            {
              "internalType": "uint256",
              "name": "mid",
              "type": "uint256"
            }
          ],
          "name": "getMsgById",
          "outputs": [
            {
              "components": [
                {
                  "internalType": "address",
                  "name": "owner",
                  "type": "address"
                },
                {
                  "internalType": "uint256",
                  "name": "tid",
                  "type": "uint256"
                },
                {
                  "internalType": "uint256",
                  "name": "mid",
                  "type": "uint256"
                },
                {
                  "internalType": "string",
                  "name": "data",
                  "type": "string"
                },
                {
                  "internalType": "uint256",
                  "name": "timestamp",
                  "type": "uint256"
                }
              ],
              "internalType": "struct messageBoard.message",
              "name": "",
              "type": "tuple"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "getNonce",
          "outputs": [
            {
              "internalType": "uint256[2]",
              "name": "",
              "type": "uint256[2]"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "uint256",
              "name": "tid",
              "type": "uint256"
            }
          ],
          "name": "getTopicById",
          "outputs": [
            {
              "components": [
                {
                  "internalType": "address",
                  "name": "owner",
                  "type": "address"
                },
                {
                  "internalType": "uint256[]",
                  "name": "msgs",
                  "type": "uint256[]"
                },
                {
                  "internalType": "string",
                  "name": "data",
                  "type": "string"
                },
                {
                  "internalType": "uint256",
                  "name": "timestamp",
                  "type": "uint256"
                }
              ],
              "internalType": "struct messageBoard.topic",
              "name": "",
              "type": "tuple"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "uint256",
              "name": "tId",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "mId",
              "type": "uint256"
            },
            {
              "internalType": "string",
              "name": "data",
              "type": "string"
            }
          ],
          "name": "newMsg",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "string",
              "name": "data",
              "type": "string"
            }
          ],
          "name": "newTopic",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "uint256",
              "name": "mid",
              "type": "uint256"
            }
          ],
          "name": "verfiMessage",
          "outputs": [
            {
              "internalType": "bool",
              "name": "",
              "type": "bool"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "uint256",
              "name": "tid",
              "type": "uint256"
            }
          ],
          "name": "verfiTopic",
          "outputs": [
            {
              "internalType": "bool",
              "name": "",
              "type": "bool"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        }
      ]
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
      getEvmWalletBalance,
      getAAaddress,
      deployAA,
      leaveMsg
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
