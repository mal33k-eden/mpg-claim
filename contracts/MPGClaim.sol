// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '../contracts/MPGInterface.sol';
import '../contracts/Utils.sol';

contract  MPGClaim is Utils{
  
  mapping(address=>bool) private investors;
  mapping(address=>iRecords) private investments;
  mapping(address=>mapping(idoPeriod=>bool)) private idoWithdrawal;
  mapping(address=>mapping(seedPeriod=>bool)) private seedWithdrawal;
  
  address public mpg;
  
  constructor(address _mpg) {
    mpg = _mpg;
  }
  event addressRecorded(address investor, uint256 idoInvestment, uint256 seedInvestments);

  function recordAddress(uint256 _ido70Investment, uint256 _seed80Investments) public returns (bool) {
    //check if address is in imported contract 
    bool isInvestor = MPGInterface(mpg).isEarlyInvestor(msg.sender);
    require(isInvestor, 'your address is not marked as an investor.');
    //check investor has been recorded 
    bool recordedInvestor = investors[msg.sender];
    require(!recordedInvestor, 'your adddress has already been recorded.');
    
    iRecords memory i = iRecords(_ido70Investment,_seed80Investments);
    investments[msg.sender]= i;
    emit addressRecorded(msg.sender, _ido70Investment, _seed80Investments);

    return isInvestor;
  }

  function withrawIdo(idoPeriod period, address receiver) public returns(bool){
    
    bool check = idoWithdrawal[msg.sender][period]; //check if invstor is eligible for that period
    bool isEarlyInvestor = MPGInterface(mpg).isEarlyInvestor(receiver);  
    
    require(!isEarlyInvestor, 'your address is marked as an investor on MPG. Please use another wallet address');
    require(investors[msg.sender], 'your address has not been recorded as an investor.');
    require(!check, 'you have taken your allocations for specified period');
    
    //calculate 10% of investment
    iRecords memory i = investments[msg.sender] ;
    uint256 idoTotal = i.ido70;
    uint256 canWithdraw = calcPercent(idoTotal, 1000); //1000 (10 * 100) using Base points

    MPGInterface(mpg).transfer(receiver, canWithdraw);
    idoWithdrawal[msg.sender][period]= true; // update withdrawal stage
    return true;
  }

  function withrawSeed(seedPeriod period, address receiver) public returns(bool){
    
    bool check = seedWithdrawal[msg.sender][period]; //check if invstor is eligible for that period
    bool isEarlyInvestor = MPGInterface(mpg).isEarlyInvestor(receiver);  
    
    require(!isEarlyInvestor, 'your address is marked as an investor on MPG. Please use another wallet address');
    require(investors[msg.sender], 'your address has not been recorded as an investor.');
    require(!check, 'you have taken your allocations for specified period');
    
    //calculate 10% of investment
    iRecords memory i = investments[msg.sender] ;
    uint256 seedTotal = i.seed80;
    uint256 canWithdraw = calcPercent(seedTotal, 1000); //1000 (10 * 100) using Base points

    MPGInterface(mpg).transfer(receiver, canWithdraw);
    seedWithdrawal[msg.sender][period]= true; // update withdrawal stage
    return true;
  }

  function safePull (address receiver) public onlyOwner returns (bool){
    uint256 bal = MPGInterface(mpg).balanceOf(address(this));
    MPGInterface(mpg).transfer(receiver, bal);
    return true;
  }
}
