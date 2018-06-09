/*
author: Kirill Kuzin (https://github.com/kirillkuzin)

TODO:
1) Добавить рандом
2) Добавить формирование времени хода
*/

pragma solidity ^0.4.21;

import "./Auction.sol";

contract Mechanics is Auction {

    mapping(address => uint256) lastStepTime;
    mapping(address => uint256) pauseTime;

    function step(address _user, uint256 _buildingId) public onlyOwner returns(uint256) {
        BuildingStruct building = buildings[_buildingId];
        uint256 rent = building.rent;
        address[] owners = building.owners;
        mapping(address => uint256) percentOwnership = building.percentOwnership;
        uint256[] percentOwnershipArray;
        for(uint256 i; i < owners.length; i++) {
            percentOwnershipArray.push(percentOwnership[owners[i]]);
        }
        stepTx(_user, owners, percentOwnershipArray);
    }

    function randomTime() private returns(uint256) {

    }

}
