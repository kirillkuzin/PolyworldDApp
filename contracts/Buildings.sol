/*
author: Kirill Kuzin (https://github.com/kirillkuzin)

TODO:
1) Добавить библиотеку SafeMath
*/

pragma solidity ^0.4.25;

import "./Finance.sol";
import "./PolyworldLibrary.sol";

contract Buildings is Ownable {

    /* Структура здания */
    struct BuildingStruct {
        mapping(uint256 => uint256) percentOwnership; // Процент владения
        uint256[] owners; // Массив владельцев
        uint256 percentForSale; // Доступный к покупке процент
        uint256 governmentPrice; // Государственная цена здания
        uint256 rent; // Рента здания
        uint256 latitude; // Широта
        uint256 longitude; // Долгота
    }
    mapping(uint256 => BuildingStruct) public buildings;
    /* ID последнего здания + 1 */
    uint256 public buildingId;
    Finance public financeContract; // Address of finance contract

    /* MODIFIERS */

    /*
    description: проверка владельца здания
    input: uint256 - id здания; address - пользователь; uint256 - процент владения
    */
    modifier isBuildingOwner(uint256 _userId, uint256 _buildingId, uint256 _percent) {
        require(buildings[_buildingId].percentOwnership[_userId] >= _percent);
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

    /*
    description: проверка принадлежности пользователю продаваемого процента
    input: uint256 - id здания; address - владелец здания; uint256 - процент здания
    */
    modifier isAvailablePercent(uint256 _buildingId, uint256 _userId, uint256 _percent) {
        require(buildings[_buildingId].percentOwnership[_userId] >= _percent);
        _;
    }

    /* PUBLIC */

    constructor(Finance _financeContract) public {
        setFinanceContract(_financeContract);
    }

    /*
    description: добавление нового здания в игру
    input: string - название здания; uint256 - цена продажи; uint256 - штраф; uint256 - долгота; uint256 - широта
    return: bool
    */
    function addBuilding(uint256 _percentForSale, uint256 _sellPrice, uint256 _rent, uint256 _latitude, uint256 _longitude) public onlyOwner returns(bool) {
        addBuildingPercentForSale(buildingId, _percentForSale);
        buildings[buildingId].governmentPrice = _sellPrice;
        buildings[buildingId].rent = _rent;
        buildings[buildingId].latitude = _latitude;
        buildings[buildingId].longitude = _longitude;
        buildingId++;
        return true;
    }

    /*
    description: покупка здания у государства через приложение (только от имени аккаунта государства)
    input: uint256 - id здания; address - новый владелец; uint256 - покупаемый процент
    return: bool
    */
    function buyGovernmentBuildingFromApp(uint256 _buildingId, uint256 _buyerId, uint256 _percent) public onlyOwner returns(bool) {
        financeContract.buyGovernmentBuildingTx(_buyerId, buildings[_buildingId].governmentPrice);
        subBuildingPercentForSale(_buildingId, _percent);
        addBuildingPercentOwnership(_buildingId, _buyerId, _percent);
        return true;
    }

    /*
    description: продажа здания из приложения (только от имени аккаунта государства)
    input: uint256 - id здания; uint256 - цена продажи; address - новый владелец; address - старый владелец; uint256 - продаваемый процент
    return: bool
    */
    function sellBuildingFromApp(uint256 _buildingId, uint256 _buyerId, uint256 _sellerId, uint256 _sellPrice, uint256 _percent) public onlyOwner returns(bool) {
        financeContract.sellBuildingTx(_buyerId, _sellerId, _sellPrice);
        addBuildingPercentOwnership(_buildingId, _buyerId, _percent);
        subBuildingPercentOwnership(_buildingId, _sellerId, _percent);
        return true;
    }

    /*
    description: продажа здания государству из приложения (только от имени аккаунта государства)
    input: uint256 - id здания; address - старый владелец; uint256 - продаваемый процент
    return: bool
    */
    function sellBuildingToGovernmentFromApp(uint256 _buildingId, uint256 _sellerId, uint256 _percent) public onlyOwner returns(bool) {
        financeContract.sellBuildingToGovernmentTx(_sellerId, buildings[_buildingId].governmentPrice / 100 * _percent);
        addBuildingPercentForSale(_buildingId, _percent);
        subBuildingPercentOwnership(_buildingId, _sellerId, _percent);
        return true;
    }

    function setFinanceContract(Finance _financeContract) public onlyOwner {
        financeContract = _financeContract;
    }

    /*
    description: возвращает процент владения по переданным id и адресу
    input: uint256 - id здания; address - владелец
    return: uint256
    */
    function getPercentOwnership(uint256 _buildingId, uint256 _userId) public constant returns(uint256) {
        return buildings[_buildingId].percentOwnership[_userId];
    }

    /*
    description: возвращает массив владельцев здания по переданному id
    input: uint256 - id здания
    return: address[]
    */
    function getBuildingOwners(uint256 _buildingId) public constant returns(uint256[]) {
        return buildings[_buildingId].owners;
    }

    /* PRIVATE */

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
    function addBuildingPercentOwnership(uint256 _buildingId, uint256 _userId, uint256 _percentOwnership) private {
        BuildingStruct storage building = buildings[_buildingId];
        if (building.percentOwnership[_userId] == 0) {
            building.owners.push(_userId);
        }
        building.percentOwnership[_userId] += _percentOwnership;
    }

    /*
    description: уменьшение процента владения
    input: uint256 - id здания; address - владелец; uint256 - процент
    */
    function subBuildingPercentOwnership(uint256 _buildingId, uint256 _userId, uint256 _percentOwnership) private {
        BuildingStruct storage building = buildings[_buildingId];
        building.percentOwnership[_userId] -= _percentOwnership;
        if (building.percentOwnership[_userId] == 0) {
            building.owners = PolyworldLibrary.removeFromOwners(PolyworldLibrary.findOwnerIndex(building.owners, _userId), building.owners);
        }
    }

    /* ADMIN FUNCTIONS */

    function setPercentForSale(uint256 _buildingId, uint256 _percentForSale) public onlyOwner {
        buildings[_buildingId].percentForSale = _percentForSale;
    }

    function addBuildingPercentOwnershipAdmin(uint256 _buildingId, uint256 _userId, uint256 _percentOwnership) public onlyOwner {
        addBuildingPercentOwnership(_buildingId, _userId, _percentOwnership);
    }

    function subBuildingPercentOwnershipAdmin(uint256 _buildingId, uint256 _userId, uint256 _percentOwnership) public onlyOwner {
        subBuildingPercentOwnership(_buildingId, _userId, _percentOwnership);
    }

}
