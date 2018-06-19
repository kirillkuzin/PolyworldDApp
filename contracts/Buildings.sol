/*
author: Kirill Kuzin (https://github.com/kirillkuzin)

TODO:
1) Добавить координаты в структуру здания
2) Добавить комментарии
3) Добавить библиотеку SafeMath
*/

pragma solidity ^0.4.21;

import "./Finance.sol";
import "./PolyworldLib.sol";

contract Buildings is Finance {

    using PolyworldLibrary;

    struct BuildingStruct {
        mapping(address => uint256) percentOwnership;
        address[] owners;
        uint256 percentForSale;
        uint256 governmentPrice;
        uint256 rent;
    }
    mapping(uint256 => BuildingStruct) public buildings;
    uint256 public buildingId;

    modifier isBuildingOwner(uint256 _buildingId, address _sender, uint256 _percent) {
        require(buildings[_buildingId].percentOwnership[_sender] >= _percent);
        _;
    }

    modifier isCorrectPrice(uint256 _price) {
        require(_price > 0);
        _;
    }

    modifier isCorrectPercentForSale(uint256 _percentForSale) {
        require(_percentForSale <= 100);
        _;
    }

    modifier isBuildingForGovernmentSale(uint256 _buildingId, uint256 _percentForSale) {
        require(buildings[_buildingId].percentForSale >= _percentForSale);
        _;
    }

    function addBuild(uint256 _percentForSale, uint256 _sellPrice, uint256 _rent) public onlyOwner isCorrectPercentForSale(_percentForSale) returns(bool result) {
        addBuildingPercentForSale(_buildingId, _percentForSale);
        setBuildingGovernmentPrice(buildingId, _sellPrice);
        setBuildingRent(buildingId, _rent);
        buildingId++;
        return true;
    }

    function buyGovernmentBuildingFromOutside(uint256 _buildingId, uint256 _percent) public isBuildingForGovernmentSale(_buildingId, _percent) {
        buyGovernmentBuilding(_buildingId, msg.sender, _percent);
    }

    function buyGovernmentBuildingFromApp(uint256 _buildingId, address _newOwner, uint256 _percent) public onlyOwner isBuildingForGovernmentSale(_buildingId, _percent) returns(bool result) {
        buyGovernmentBuilding(_buildingId, _newOwner, _percent);
        return true;
    }

    function sellBuildingFromOutside(uint256 _buildingId, uint256 _sellPrice, address _newOwner, uint256 _percent) public isBuildingOwner(msg.sender, _buildingId, _percent) isCorrectPrice(_sellPrice) isPurchaseApprove(_newOwner, msg.sender, _buildingId, _percent) {
        sellBuildingTx(_newOwner, msg.sender, _sellPrice);
        addBuildingPercentOwnership(_buildingId, _newOwner, _percent);
        subBuildingPercentOwnership(_buildingId, msg.sender, _percent);
    }

    function sellBuildingFromApp(uint256 _buildingId, uint256 _sellPrice, address _newOwner, address _oldOwner, uint256 _percent) public onlyOwner isCorrectPrice(_sellPrice) returns(bool result) {
        sellBuildingTx(_newOwner, _oldOwner, _sellPrice);
        addBuildingPercentOwnership(_buildingId, _newOwner, _percent);
        subBuildingPercentOwnership(_buildingId, _oldOwner, _percent);
        return true;
    }

    function sellBuildingToGovernmentFromOutside(uint256 _buildingId, uint256 _percent) public isBuildingOwner(msg.sender, _buildingId, _percent) {
        sellBuildingToGovernment(_buildingId, msg.sender, _percent);
    }

    function sellBuildingToGovernmentFromApp(uint256 _buildingId, address _oldOwner, uint256 _percent) public onlyOwner returns(bool result) {
        sellBuildingToGovernment(_buildingId, _oldOwner, _percent);
        return true;
    }

    function buyGovernmentBuilding(uint256 _buildingId, address _newOwner, uint256 _percent) private {
        buyGovernmentBuildingTx(buildings[_buildingId].governmentPrice);
        subBuildingPercentForSale(_buildingId, _percent);
        addBuildingPercentOwnership(_buildingId, _newOwner, _percent);
    }

    function sellBuildingToGovernment(uint256 _buildingId, address _oldOwner, uint256 _percent) private {
        sellBuildingToGovernmentTx(_oldOwner, buildings[_buildingId].governmentPrice / 100 * buildings[_buildingId].percentOwnership[_oldOwner]);
        addBuildingPercentForSale(_buildingId, _percent);
        subBuildingPercentOwnership(_buildingId, _oldOwner, _percent);
    }

    function setBuildingGovernmentPrice(uint256 _buildingId, uint256 _price) private {
        buildings[_buildingId].governmentPrice = _price;
    }

    function setBuildingRent(uint256 _buildingId, uint256 _rent) private {
        buildings[_buildingId].rent = _rent;
    }

    function addBuildingPercentForSale(uint256 _buildingId, uint256 _percentForSale) private {
        buildings[_buildingId].percentForSale += _percentForSale;
    }

    function subBuildingPercentForSale(uint256 _buildingId, uint256 _percentForSale) private {
        buildings[_buildingId].percentForSale -= _percentForSale;
    }

    function addBuildingPercentOwnership(uint256 _buildingId, address _owner, uint256 _percentOwnership) private {
        BuildingStruct building = buildings[_buildingId];
        if (building.percentOwnership[_owner] == 0) {
            building.owners.push(_owner);
        }
        building.percentOwnership[_owner] += _percentOwnership;
    }

    function subBuildingPercentOwnership(uint256 _buildingId, address _owner, uint256 _percentOwnership) private {
        BuildingStruct building = buildings[_buildingId];
        building.percentOwnership[_owner] -= _percentOwnership;
        if (building.percentOwnership[_owner] == 0) {
            building.owners = removeFromOwners(findOwnerIndex(building.owners, _owner), building.owners);
        }
    }

}
