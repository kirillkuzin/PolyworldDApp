pragma solidity ^0.4.21;

import "./Ownable.sol";

contract Approves is Ownable {

    //User address => other user address => build ID => approve state
    mapping(address => mapping(address => mapping(uint256 => bool))) public purchasesApprove;

    modifier isPurchaseApprove(address _buyer, address _seller, uint256 _buildId) {
        require(purchasesApprove[_buyer][_seller][_buildId]);
        _;
    }

    function setPurchaseApprove(address _buyer, address _seller, uint256 _buildId) public onlyOwner {
        purchasesApprove[_buyer][_seller][_buildId] = true;
    }

}
