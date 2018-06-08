/*
author: Kirill Kuzin (https://github.com/kirillkuzin)

TODO:
1) Добавить токен
2) Добавить операции с токеном
3) Добавить комментарии
4) Добавить библиотеку SafeMath
*/

pragma solidity ^0.4.21;

import "./Approves.sol";

contract Finance is Approves {

    mapping(address => uint256) rentBalances;
    uint256 public sellBuildingTaxPercent;

    function Finance(uint256 _sellBuildingTaxPercent) public {
        sellBuildingTaxPercent = _sellBuildingTaxPercent;
    }

    function stepTx() internal {

    }

    function buyGovernmentBuildingTx(address _newOwner, uint256 _price) internal {
        transferPwd(_newOwner, address(this), _price);
    }

    function sellBuildingTx(address _newOwner, address _oldOwner, uint256 _price) internal {
        uint256 tax = _price / 100 * sellBuildingTaxPercent;
        transferPwd(_newOwner, _oldOwner, _price - tax);
        transferPwd(_newOwner, address(this), tax)
    }

    function sellBuildingToGovernmentTx(address _oldOwner, uint256 _price) internal {
        uint256 sellPrice = _price / 2;
        transferPwd(address(this), _oldOwner, sellPrice);
    }

    function transferPwd(address _from, address _to, uint256 _amount) private {

    }

}
