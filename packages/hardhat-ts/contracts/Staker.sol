pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import 'hardhat/console.sol';
import './ExampleExternalContract.sol';

contract Staker {
  ExampleExternalContract public exampleExternalContract;

  event Stake(address indexed sender, uint256 amount);
  mapping(address => uint256) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 30 seconds;
  bool openForWithdraw = false;

  constructor(address exampleExternalContractAddress) {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier notCompleted() {
    require(!exampleExternalContract.completed(), 'External contract already completed');
    _;
  }

  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }

  function withdraw(address ad) public notCompleted {
    require(openForWithdraw, 'Contract not open for withdraw');
    uint256 amountToWithdraw = balances[msg.sender];
    balances[msg.sender] = 0;
    (bool sent, ) = ad.call{value: amountToWithdraw}('');
    require(sent, 'Failed to withdraw Ether');
  }

  function stake() public payable notCompleted {
    balances[msg.sender] = balances[msg.sender] + msg.value;
    emit Stake(msg.sender, msg.value);
  }

  function execute() public notCompleted {
    if (address(this).balance > threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else if (deadline < block.timestamp) {
      openForWithdraw = true;
    }
  }

  receive() external payable {
    stake();
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  // Add the `receive()` special function that receives eth and calls stake()
}
