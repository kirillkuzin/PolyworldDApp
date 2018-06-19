/*
author: Kirill Kuzin (https://github.com/kirillkuzin)

TODO:
1) Добавить токен
2) Добавить операции с токеном
3) Добавить комментарии
4) Добавить библиотеку SafeMath
5) Добавить кражу ренты
*/

pragma solidity ^0.4.21;

import "./Approves.sol";

contract Finance is Approves {

    mapping(address => uint256 => uint256) rentBalances; //user address => rent time => rent
    uint256 public sellBuildingTaxPercent;
    uint256 public taxInPercent;

    function Finance(uint256 _sellBuildingTaxPercent, uint256 _taxInPercent) public {
        sellBuildingTaxPercent = _sellBuildingTaxPercent;
        taxInPercent = _taxInPercent;
    }

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

    function getRentFromOutside() public {
        require(rentBalances[msg.sender] > 0);
        transferPwd(address(this), msg.sender, rentBalances[msg.sender]);
    }

    function getRentFromApp(address _account) public onlyOwner {
        require(rentBalances[_account] > 0);
        transferPwd(address(this), _account, rentBalances[_account]);
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
