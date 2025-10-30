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
*@notice The interest rate in the smart contract can only decrease over time
*@notice Each user will have their own interest rate that is the global interest rate at the time of deposit
*/

contract  RebaseToken is ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error RebaseToken__InterestRateCanOnlyDecrease(uint256 oldInterestRate, uint256 newInterestRate);

    uint256 private constant PRECISION_FACTOR = 1e18;
    uint256 private s_interestRate = 5e10;
    mapping ( address => uint256) private s_userInterestRate;
    mapping ( address => uint256) private s_userLastUpdatedTimestamp;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event InteresrRateSet(uint256 newInterestRate);


    constructor() ERC20("RebaseToken", "RBT") {
        
    }

    /*
    *@notice Sets a new interest rate constant
    *@param _newInterestRate The new interest rate to be set
    *@dev The interest rate can only decrease
    */
    function setInterestRate(uint256 _newInterestRate) external {
        //Set the interest rate
        //I think this should be >= the current interest rate to keep interest rate decreases
        if(_newInterestRate < s_interestRate) {
            revert RebaseToken__InterestRateCanOnlyDecrease(s_interestRate, _newInterestRate);
            emit InteresrRateSet(_newInterestRate);
            
        }
    }


    /*
    *@notice Mints the user tokens when they deposit into the vault
    *@param _to The address to mint tokens to
    *@param _amount The amount of tokens to mint
    */
    function mint(address _to, uint256 _amount) external{
        _mintAccruedInterest(_to);
        s_userInterestRate[_to] = s_interestRate;
        _mint(_to, _amount);
    }
    /*
    *@notice Burns the user tokens when they withdraw from the vault
    *@param _from The address to burn tokens from
    *@param _amount The amount of tokens to burn
    */
    function burn(address _from, uint256 _amount) external {
        if(_amount == type(uint256).max){
            _amount = balanceOf(_from);
        }
        _mintAccruedInterest(_from);
        _burn(_from, _amount);
    }

    /*
    *calculate the balance for the user including the interest that has ccumulated since the last update
    *(principle balance) + interest that has accrued
    *@param _user The user to calculate the balance for
    *@return The balance of the user including accrued interest
    */

    function balanceOf(address _user) public view override returns (uint256){
        //get current principle balance of the user (the number of tokens has been minted to ther user))
        //Muiltiply the principle balance by the interest that has accumulated in the time that the balance has been updated
        return super.balanceOf(_user) * _calculateUserAccruedInterestSinceLastUpdate(_user)/PRECISION_FACTOR;
    }

    /*
    *@notice Calculates the interest that has accumulated since the last update
    *@param _user The user to calculate the interest accumulated
    *@return The interest that has accumulated since the last update
     */

    function _calculateUserAccruedInterestSinceLastUpdate(address _user) internal view returns (uint256 linearInterest){
        //we need to calculate the interet that has accumulated since the last update
        //this is going to be liner growth with time
        //1. calculate the time since the last update
        //2. calculate the amount of linear growth
        uint256 timeElapsed = block.timestamp - s_userLastUpdatedTimestamp[_user];
        linearInterest = PRECISION_FACTOR + (s_userInterestRate[_user] * timeElapsed) ;
    }
    /*
    *@notice Mints the accrued interest to the user since the last time they interacted with the protocal.
    *@param _user The user to mint the accrued interest to
    */
    function _mintAccruedInterest(address _user) internal {
        //(1) find the cuurent balance of rebase tokens thant have been minted to the user
        uint256 previousPrincipleBalance = super.balanceOf(_user);
        //(2) calcualte their current balance including any interest -> balanceOf
        uint256 currentBalance = balanceOf(_user);
        //calculate the number of tokens that need to be minted to the user -> (2) - (1)
        uint256 balanceIncrease = currentBalance - previousPrincipleBalance;
        //set the users last updated timestamp
        s_userLastUpdatedTimestamp[_user] = block.timestamp;
        //call _mint function to mint the tokens to the user
        _mint(_user,balanceIncrease);
    }

    /*
    *@notice Gets the interest rate of user
    *@param _user The user to get the interest rate for
    *@return The interest rate of the user
    */

    function getUserInterestRate(address _user) external view returns(uint256){
        return s_userInterestRate[_user];
    }
}