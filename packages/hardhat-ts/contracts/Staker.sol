pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import 'hardhat/console.sol';
import './ExampleExternalContract.sol';

contract Staker {
  ExampleExternalContract public exampleExternalContract;

  event Stake(address indexed sender, uint256 amount);
  mapping(address => uint256) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 deadline;

  constructor(address exampleExternalContractAddress) {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    deadline = block.timestamp + 1 minutes;
  }

  function timeLeft() public view returns (uint256) {
    return deadline - block.timestamp;
  }

  function withdraw(address ad) public {
    require(deadline < block.timestamp, 'Deadline to withdraw not reached yet');
    uint256 amountToWithdraw = balances[ad];
    (bool sent, ) = ad.call{value: amountToWithdraw}('');
    require(sent, 'Failed to withdraw Ether');
  }

  function stake() public payable {
    balances[msg.sender] = balances[msg.sender] + msg.value;
    emit Stake(msg.sender, msg.value);
  }

  function complete() public {}

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  // Add the `receive()` special function that receives eth and calls stake()
}
