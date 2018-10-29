/*
author: Kirill Kuzin (https://github.com/kirillkuzin)

TODO:
1) Добавить токен
2) Добавить операции с токеном
3) Добавить библиотеку SafeMath
4) Добавить кражу ренты
5) Добавить привязку адресов к id пользователей
*/

pragma solidity ^0.4.21;

import "./Approves.sol";

contract Finance is Approves {

    /*
    Балансы пользователей
    */
    mapping(uint256 => uint256) public rentBalances;
    /* Налоговый процент при продаже здания */
    uint256 public sellBuildingTaxPercent;
    /* Налоговый процент с игрового хода (ренты) */
    uint256 public taxInPercent;

    /* PUBLIC */

    /*
    description: забрать свой баланс из вне приложения
    */
    function getRentFromOutside() public {
    }

    /*
    description: забрать свой баланс из приложения (только от имени аккаунта государства)
    input: address - пользователь
    return: bool
    */
    function getRentFromApp(address _account) public onlyOwner returns(bool) {
    }

    /* INTERNAL */

    /*
    description: игровой ход
    input: address - пользователь; uint256 - рента; address[] - массив владельцев здания; uint256[] - проценты владения (пред. массива владельцев)
    */
    function stepTx(address _account, uint256 _rent, uint256[] _buildingOwners, uint256[] _percentOwnership) internal {
        uint256 rent = _rent * 1 ether;
        uint256 percentOfRent = rent / 100;
        uint256 tax = percentOfRent * taxInPercent;
        uint256 ownersProfit = rent - tax;
        for (uint256 i = 0; i < _buildingOwners.length; i++) {
            uint256 ownerProfit = percentOfRent * _percentOwnership[i];
            rentBalances[_buildingOwners[i]] += ownerProfit;
        }
    }

    /*
    description: транзакция покупки здания у государства
    input: address - новый владелец; uint256 - цена
    */
    function buyGovernmentBuildingTx(uint256 _newOwner, uint256 _price) internal {
        // transferPwd(_newOwner, address(this), _price * 1 ether);
    }

    /*
    description: транзакция продажи здания пользователю
    input: address - новый владелец; address - старый владелец; uint256 - цена
    */
    function sellBuildingTx(uint256 _newOwner, uint256 _oldOwner, uint256 _price) internal {
        uint256 price = _price * 1 ether;
        uint256 tax = price / 100 * sellBuildingTaxPercent;
        // transferPwd(_newOwner, _oldOwner, price - tax);
        // transferPwd(_newOwner, address(this), tax);
    }

    /*
    description: транзакция продажи здания государству
    input: address - старый владелец; uint256 - цена
    */
    function sellBuildingToGovernmentTx(uint256 _oldOwner, uint256 _price) internal {
        uint256 sellPrice = _price * 1 ether / 2;
        // transferPwd(address(this), _oldOwner, sellPrice);
    }

    /* PRIVATE */

    /*
    description: трансфер токенов
    input: address - откуда передать; address - кому передать; uint256 - количество
    */
    function transferPwd(address _from, address _to, uint256 _amount) private {

    }

}
