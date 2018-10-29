/*
author: Kirill Kuzin (https://github.com/kirillkuzin)

TODO:
1) Добавить комментарии
2) Добавить забирание аппрува
*/

pragma solidity ^0.4.21;

import "./Ownable.sol";

contract Approves is Ownable {

    //User address => other user address => build ID => approve percent
    mapping(address => mapping(address => mapping(uint256 => uint256))) public purchasesApprove;

    modifier isPurchaseApprove(address _buyer, address _seller, uint256 _buildId, uint256 _percent) {
        require(purchasesApprove[_buyer][_seller][_buildId] >= _percent);
        _;
    }

    function setPurchaseApproveFromOutside(address _seller, uint256 _buildId, uint256 _percent) public {
        purchasesApprove[msg.sender][_seller][_buildId] = _percent;
    }

    function setPurchaseApproveFromApp(address _buyer, address _seller, uint256 _buildId, uint256 _percent) public onlyOwner returns(bool) {
        purchasesApprove[_buyer][_seller][_buildId] = _percent;
        return true;
    }

}
