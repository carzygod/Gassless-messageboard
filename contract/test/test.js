const { expect } = require("chai");
const { ethers } = require("hardhat");

const bytes32 = require('bytes32');

const baseSize = 1000000;

describe("Message Board ", function () {
  it("bad news", async function () {
    const [owner, addr1 ,addr2,addr3,addr4,addr5,addr6] = await ethers.getSigners();
    console.log("begian")

    const Data = await ethers.getContractFactory("messageBoard");
    const data = await Data.connect(addr2).deploy();
    await data.deployed();
    console.log("🍺Message Core Contract Deployed : " , data.address)

    console.log(
      await data.getNonce()
    )
    console.log(
      await data.getTopicById(0)
    )
    console.log(
      await data.getMsgById(0)
    )

    await data.newTopic("How this fucking shit working without gas ? ")
    
    await data.newMsg(
      1,
      0,
      "Infact , it using AA to pay gas by our paymaster , so the user will not require to pay for it's gas fee ."
    ) 

    await data.newMsg(
      1,
      1,
      "That sound's cool . but how you guys aviod being attack by randomly , endless , message attack . "
    ) 

    await data.newMsg(
      1,
      2,
      "Well . amigo , it is easy . We don't ...... "
    ) 

    var newTopic =  await data.getTopicById(1);
    console.log(
      newTopic
    )
    for(var i = 0 ; i < newTopic.msgs.length ; i ++)
    {
      console.log(
        (await data.getMsgById(newTopic.msgs[i])).data
      )
    }



  });
});
