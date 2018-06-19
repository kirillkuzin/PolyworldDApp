/*
author: Kirill Kuzin (https://github.com/kirillkuzin)

TODO:
1) Добавить рандом
2) Добавить формирование времени хода
*/

pragma solidity ^0.4.21;

import "./Auction.sol";

contract Mechanics is Auction {

    uint256 constant RANDOM_TIME_RANGE = 48;

    mapping(address => uint256) lastStepTime;
    mapping(address => uint256) pauseTime;

    modifier correctStepTime(address _user) {
        require(now >= lastStepTime[_user] + pauseTime[_user]);
    }

    function step(address _user, uint256 _buildingId) public onlyOwner correctStepTime(_user) returns(uint256) {
        BuildingStruct building = buildings[_buildingId];
        uint256 rent = building.rent;
        address[] owners = building.owners;
        mapping(address => uint256) percentOwnership = building.percentOwnership;
        uint256[] percentOwnershipArray;
        for (uint256 i; i < owners.length; i++) {
            percentOwnershipArray.push(percentOwnership[owners[i]]);
        }
        lastStepTime[_user] = now;
        pauseTime[_user] = randomTime(RANDOM_TIME_RANGE);
        stepTx(_user, owners, percentOwnershipArray);
    }

    function randomTime(uint256 _hours) private returns(uint256) {
        uint256 randomHours = uint(block.blockhash(block.number - 1)) % _hours;
    }

}
