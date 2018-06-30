/*
author: Kirill Kuzin (https://github.com/kirillkuzin)

TODO:
1) Добавить токен
2) Добавить операции с токеном
3) Добавить библиотеку SafeMath
4) Добавить кражу ренты
*/

pragma solidity ^0.4.21;

import "./Approves.sol";

contract Finance is Approves {

    /*
    Балансы пользователей
    */
    mapping(address => uint256) rentBalances;
    /* Налоговый процент при продаже здания */
    uint256 public sellBuildingTaxPercent;
    /* Налоговый процент с игрового хода (ренты) */
    uint256 public taxInPercent;

    /* PUBLIC */

    /*
    description: конструктор
    input: uint256 - налоговый процент при продаже здания; uint256 - налоговый процент с игрового хода (ренты)
    */
    function Finance(uint256 _sellBuildingTaxPercent, uint256 _taxInPercent) public {
        sellBuildingTaxPercent = _sellBuildingTaxPercent;
        taxInPercent = _taxInPercent;
    }

    /*
    description: забрать свой баланс из вне приложения
    */    
    function getRentFromOutside() public {
        require(rentBalances[msg.sender] > 0);
        transferPwd(address(this), msg.sender, rentBalances[msg.sender]);
    }

    /*
    description: забрать свой баланс из приложения (только от имени аккаунта государства)
    input: address - пользователь
    return: bool
    */
    function getRentFromApp(address _account) public onlyOwner {
        require(rentBalances[_account] > 0);
        transferPwd(address(this), _account, rentBalances[_account]);
        return true;
    }

    /* INTERNAL */

    /*
    description: игровой ход
    input: address - пользователь; uint256 - рента; address[] - массив владельцев здания; uint256[] - проценты владения (пред. массива владельцев)
    */
    function stepTx(address _account, uint256 _rent, address[] _buildingOwners, uint256[] _percentOwnership) internal {
        transferPwd(_account, address(this), _rent);
        percentOfRent = _rent / 100;
        tax = percentOfRent * taxInPercent;
        ownersProfit = _rent - tax;
        for (uint256 i = 0; i < _buildingOwners.length; i++) {
            ownerProfit = percentOfRent * _percentOwnership[i];
            rentBalances[_buildingOwners[i]] += ownerProfit;
        }
    }

    /*
    description: транзакция покупки здания у государства
    input: address - новый владелец; uint256 - цена
    */
    function buyGovernmentBuildingTx(address _newOwner, uint256 _price) internal {
        transferPwd(_newOwner, address(this), _price);
    }

    /*
    description: транзакция продажи здания пользователю
    input: address - новый владелец; address - старый владелец; uint256 - цена
    */
    function sellBuildingTx(address _newOwner, address _oldOwner, uint256 _price) internal {
        uint256 tax = _price / 100 * sellBuildingTaxPercent;
        transferPwd(_newOwner, _oldOwner, _price - tax);
        transferPwd(_newOwner, address(this), tax)
    }

    /*
    description: транзакция продажи здания государству
    input: address - старый владелец; uint256 - цена
    */
    function sellBuildingToGovernmentTx(address _oldOwner, uint256 _price) internal {
        uint256 sellPrice = _price / 2;
        transferPwd(address(this), _oldOwner, sellPrice);
    }

    /* PRIVATE */

    /*
    description: трансфер токенов
    input: address - откуда передать; address - кому передать; uint256 - количество
    */
    function transferPwd(address _from, address _to, uint256 _amount) private {

    }

}
