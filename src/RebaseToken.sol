//SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
*@title RebaseToken
*@author Ciara Nightingale
*@notice This is a cross-chain rebase token that incentivises users to deposite into a vault
*@notice The interest rate in the smar contract can only decrease over time
*@notice Each user will have their own interest rate that is the global interest rate at the time of deposit
*/

contract  RebaseToken is ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error RebaseToken__InterestRateCanOnlyDecrease(uint256 oldInterestRate, uint256 newInterestRate);

    uint256 private s_interestRate = 5e10;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event InteresrRateSet(uint256 newInterestRate);


    constructor() ERC20("RebaseToken", "RBT") {
        
    }
    function setInterestRate(uint256 _newInterestRate) external {
        //Set the interest rate
        //I think this should be >= the current interest rate to keep interest rate decreases
        if(_newInterestRate < s_interestRate) {
            revert RebaseToken__InterestRateCanOnlyDecrease(s_interestRate, _newInterestRate);
            emit InteresrRateSet(_newInterestRate);
            
        }
    }
}