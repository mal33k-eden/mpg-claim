// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
contract Utils is Ownable {
  
  using SafeMath for uint256;
  struct iRecords{uint256 ido70;uint256 seed80;} // total investments records
  enum idoPeriod {june, july, august, september }
  enum seedPeriod {june, july, august, september,october,november }
  constructor() Ownable() {
  }

  function calcPercent(uint256 amount, uint256 percent) public pure returns (uint256){
    require((amount / 10000)*10000 == amount, 'amount too small');
    return (amount.mul(percent)).div(10000);
  }
}
