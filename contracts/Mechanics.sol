/*
author: Kirill Kuzin (https://github.com/kirillkuzin)

TODO:
1) Добавить рандом
2) Добавить формирование времени хода
3) Добавить комментарии
*/

pragma solidity ^0.4.21;

import "./Auction.sol";

contract Mechanics is Auction {

    uint256 public constant RANDOM_TIME_RANGE = 48;

    mapping(address => uint256) public lastStepTime;
    mapping(address => uint256) public pauseTime;
    mapping(address => uint256[]) public percentOwnershipArr;

    modifier correctStepTime(address _user) {
        require(now >= lastStepTime[_user] + pauseTime[_user]);
        _;
    }

    function Mechanics(uint256 _sellBuildingTaxPercent, uint256 _taxInPercent) public {
        sellBuildingTaxPercent = _sellBuildingTaxPercent;
        taxInPercent = _taxInPercent;
    }

    function step(address _user, uint256 _buildingId) public onlyOwner correctStepTime(_user) returns(bool) {
        BuildingStruct building = buildings[_buildingId];
        uint256 rent = building.rent;
        address[] owners = building.owners;
        mapping(address => uint256) percentOwnership = building.percentOwnership;
        uint256[] storage percentOwnershipArray;
        for (uint256 i; i < owners.length; i++) {
            percentOwnershipArray.push(percentOwnership[owners[i]]);
        }
        lastStepTime[_user] = now;
        pauseTime[_user] = randomTime(RANDOM_TIME_RANGE);
        stepTx(_user, rent, owners, percentOwnershipArray);
        return true;
    }

    function randomTime(uint256 _hours) private returns(uint256) {
        uint256 randomHours = uint(block.blockhash(block.number - 1)) % _hours;
        return randomHours;
    }

}
