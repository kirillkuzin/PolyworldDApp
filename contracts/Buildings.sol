pragma solidity ^0.4.21;

import "./Finance.sol";

contract Buildings is Finance {

    struct BuildingStruct {
        address owner;
        bool forSale;
        uint256 governmentPrice;
        uint256 auctionPrice;
    }
    mapping(uint256 => BuildingStruct) public buildings;
    uint256 public buildingId;

    modifier isBuildOwner(address _sender, uint256 _buildingId) {
        require(_sender == buildings[_buildingId].owner);
        _;
    }

    modifier isCorrectPrice(uint256 _price) {
        require(_price > 0);
        _;
    }

    modifier isBuildingForGovernmentSale(uint256 _buildingId) {
        require(buildings[_buildingId].forSale);
        _;
    }

    modifier isBuildingForAuctionSale(uint256 _buildingId) {
        require(buildings[_buildingId].auctionPrice > 0);
        _;
    }

    function addBuild(uint256 _sellPrice) public onlyOwner returns(bool result) {
        buildings[buildingId].owner = address(this);
        buildings[buildingId].forSale = true;
        buildings[buildingId].governmentPrice = _sellPrice;
        buildingId++;
        return true;
    }

    function buyGovernmentBuildingFromOutside(uint256 _buildingId) public isBuildingForGovernmentSale(_buildingId) {
        //TODO: transfer PWD
        buyGovernmentBuilding(_buildingId, msg.sender);
    }

    function buyGovernmentBuildingFromApp(uint256 _buildingId, address _newOwner) public onlyOwner isBuildingForGovernmentSale(_buildingId) returns(bool result) {
        //TODO: transfer PWD
        buyGovernmentBuilding(_buildingId, _newOwner);
        return true;
    }

    function sellBuilding(uint256 _buildingId, uint256 _sellPrice, address _newOwner) public isBuildOwner(msg.sender, _buildingId) isCorrectPrice(_sellPrice) isPurchaseApprove(_newOwner, msg.sender, _buildingId) {
        //TODO: transfer PWD
        setBuildingOwner(_buildingId, _newOwner);
    }

    function sellBuildingFromApp(uint256 _buildingId, uint256 _sellPrice, address _newOwner) public onlyOwner isCorrectPrice(_sellPrice) returns(bool result) {
        //TODO: transfer PWD
        setBuildingOwner(_buildingId, _newOwner);
        return true;
    }

    function sellBuildingToGovernmentFromOutside(uint256 _buildingId) public isBuildOwner(msg.sender, _buildingId) {
        //TODO: transfer PWD
        sellBuildingToGovernment(_buildingId);
    }

    function sellBuildingToGovernmentFromApp(uint256 _buildingId) public onlyOwner returns(bool result) {
        //TODO: transfer PWD
        sellBuildingToGovernment(_buildingId);
        return true;
    }

    function buyGovernmentBuilding(uint256 _buildingId, address _newOwner) private {
        setBuildingOwner(_buildingId, _newOwner);
        setBuildingGovernmentSaleState(_buildingId, false);
    }

    function sellBuildingToGovernment(uint256 _buildingId) private {
        setBuildingOwner(_buildingId, address(this));
        setBuildingGovernmentSaleState(_buildingId, true);
    }

    function setBuildingOwner(uint256 _buildingId, address _newOwner) private {
        buildings[_buildingId].owner = _newOwner;
    }

    function setBuildingGovernmentSaleState(uint256 _buildingId, bool _state) private {
        buildings[_buildingId].forSale = _state;
    }

    function setBuildingAuctionPrice(uint256 _buildingId, uint256 _price) private {
        buildings[_buildingId].auctionPrice = _price;
    }

}
