/*
author: Kirill Kuzin (https://github.com/kirillkuzin)

TODO:
1) Добавить библиотеку SafeMath
*/

pragma solidity ^0.4.21;

import "./Finance.sol";
import "./PolyworldLib.sol";

contract Buildings is Finance {

    using PolyworldLibrary;

    /* Структура здания */
    struct BuildingStruct {
        mapping(address => uint256) percentOwnership; // Процент владения
        address[] owners; // Массив владельцев
        uint256 percentForSale; // Доступный к покупке процент
        uint256 governmentPrice; // Государственная цена здания
        uint256 rent; // Рента здания
        uint256 latitude; // Широта
        uint256 longitude; // Долгота
    }
    mapping(uint256 => BuildingStruct) public buildings;
    /* ID последнего здания + 1 */
    uint256 public buildingId;

    /* MODIFIERS */

    /*
    description: проверка владельца здания
    input: uint256 - id здания; address - пользователь; uint256 - процент владения
    */
    modifier isBuildingOwner(uint256 _buildingId, address _sender, uint256 _percent) {
        require(buildings[_buildingId].percentOwnership[_sender] >= _percent);
        _;
    }

    /*
    description: проверка свободного процента здания
    input: uint256 - id здания; uint256 - процент здания
    */
    modifier isBuildingForGovernmentSale(uint256 _buildingId, uint256 _percentForSale) {
        require(buildings[_buildingId].percentForSale >= _percentForSale);
        _;
    }

    /* PUBLIC */

    /*
    description: добавление нового здания в игру
    input: uint256 - цена продажи; uint256 - штраф; uint256 - долгота; uint256 - широта
    return: bool
    */
    function addBuild(uint256 _sellPrice, uint256 _rent, uint256 _latitude, uint256 _longitude) public onlyOwner returns(bool result) {
        addBuildingPercentForSale(_buildingId, 100);
        buildings[_buildingId].governmentPrice = _sellPrice;
        buildings[_buildingId].rent = _rent;
        buildings[_buildingId].latitude = _latitude;
        buildings[_buildingId].longitude = _longitude;
        buildingId++;
        return true;
    }

    /*
    description: покупка здания у государства вне приложения
    input: uint256 - id здания; uint256 - покупаемый процент
    */
    function buyGovernmentBuildingFromOutside(uint256 _buildingId, uint256 _percent) public isBuildingForGovernmentSale(_buildingId, _percent) {
        buyGovernmentBuilding(_buildingId, msg.sender, _percent);
    }

    /*
    description: покупка здания у государства через приложение (только от имени аккаунта государства)
    input: uint256 - id здания; address - новый владелец; uint256 - покупаемый процент
    return: bool
    */
    function buyGovernmentBuildingFromApp(uint256 _buildingId, address _newOwner, uint256 _percent) public onlyOwner isBuildingForGovernmentSale(_buildingId, _percent) returns(bool result) {
        buyGovernmentBuilding(_buildingId, _newOwner, _percent);
        return true;
    }

    /*
    description: продажа здания игроку вне приложения (только от имени владельца здания; только если есть подтверждение покупателя)
    input: uint256 - id здания; uint256 - цена продажи; address - новый владелец; uint256 - продаваемый процент
    */
    function sellBuildingFromOutside(uint256 _buildingId, uint256 _sellPrice, address _newOwner, uint256 _percent) public isBuildingOwner(msg.sender, _buildingId, _percent) isPurchaseApprove(_newOwner, msg.sender, _buildingId, _percent) {
        sellBuildingTx(_newOwner, msg.sender, _sellPrice);
        addBuildingPercentOwnership(_buildingId, _newOwner, _percent);
        subBuildingPercentOwnership(_buildingId, msg.sender, _percent);
    }

    /*
    description: продажа здания из приложения (только от имени аккаунта государства)
    input: uint256 - id здания; uint256 - цена продажи; address - новый владелец; address - старый владелец; uint256 - продаваемый процент
    return: bool
    */
    function sellBuildingFromApp(uint256 _buildingId, uint256 _sellPrice, address _newOwner, address _oldOwner, uint256 _percent) public onlyOwner returns(bool result) {
        sellBuildingTx(_newOwner, _oldOwner, _sellPrice);
        addBuildingPercentOwnership(_buildingId, _newOwner, _percent);
        subBuildingPercentOwnership(_buildingId, _oldOwner, _percent);
        return true;
    }

    /*
    description: продажа здания государству вне приложения (только от имени владельца здания)
    input: uint256 - id здания; uint256 - продаваемый процент
    */
    function sellBuildingToGovernmentFromOutside(uint256 _buildingId, uint256 _percent) public isBuildingOwner(msg.sender, _buildingId, _percent) {
        sellBuildingToGovernment(_buildingId, msg.sender, _percent);
    }

    /*
    description: продажа здания государству из приложения (только от имени аккаунта государства)
    input: uint256 - id здания; address - старый владелец; uint256 - продаваемый процент
    return: bool
    */
    function sellBuildingToGovernmentFromApp(uint256 _buildingId, address _oldOwner, uint256 _percent) public onlyOwner returns(bool result) {
        sellBuildingToGovernment(_buildingId, _oldOwner, _percent);
        return true;
    }

    /* PRIVATE */

    /*
    description: покупка здания у государства
    input: uint256 - id здания; address - новый владелец; uint256 - покупаемый процент
    */
    function buyGovernmentBuilding(uint256 _buildingId, address _newOwner, uint256 _percent) private {
        buyGovernmentBuildingTx(buildings[_buildingId].governmentPrice);
        subBuildingPercentForSale(_buildingId, _percent);
        addBuildingPercentOwnership(_buildingId, _newOwner, _percent);
    }

    /*
    description: продажа здания государству
    input: uint256 - id здания; address - старый владелец; uint256 - продаваемый процент
    */
    function sellBuildingToGovernment(uint256 _buildingId, address _oldOwner, uint256 _percent) private {
        sellBuildingToGovernmentTx(_oldOwner, buildings[_buildingId].governmentPrice / 100 * buildings[_buildingId].percentOwnership[_oldOwner]);
        addBuildingPercentForSale(_buildingId, _percent);
        subBuildingPercentOwnership(_buildingId, _oldOwner, _percent);
    }

    /*
    description: увеличение свободного процента здания
    input: uint256 - id здания; uint256 - процент
    */
    function addBuildingPercentForSale(uint256 _buildingId, uint256 _percentForSale) private {
        buildings[_buildingId].percentForSale += _percentForSale;
    }

    /*
    description: уменьшение свободного процента здания
    input: uint256 - id здания; uint256 - процент
    */
    function subBuildingPercentForSale(uint256 _buildingId, uint256 _percentForSale) private {
        buildings[_buildingId].percentForSale -= _percentForSale;
    }

    /*
    description: добавление процента владения
    input: uint256 - id здания; address - владелец; uint256 - процент
    */
    function addBuildingPercentOwnership(uint256 _buildingId, address _owner, uint256 _percentOwnership) private {
        BuildingStruct building = buildings[_buildingId];
        if (building.percentOwnership[_owner] == 0) {
            building.owners.push(_owner);
        }
        building.percentOwnership[_owner] += _percentOwnership;
    }

    /*
    description: уменьшение процента владения
    input: uint256 - id здания; address - владелец; uint256 - процент
    */
    function subBuildingPercentOwnership(uint256 _buildingId, address _owner, uint256 _percentOwnership) private {
        BuildingStruct building = buildings[_buildingId];
        building.percentOwnership[_owner] -= _percentOwnership;
        if (building.percentOwnership[_owner] == 0) {
            building.owners = removeFromOwners(findOwnerIndex(building.owners, _owner), building.owners);
        }
    }

}
