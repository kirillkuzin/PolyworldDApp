/*
author: Kirill Kuzin (https://github.com/kirillkuzin)

TODO:
1) Добавить комментарии
*/

pragma solidity ^0.4.21;

library PolyworldLibrary {

    function findOwnerIndex(address[] _owners, address _owner) internal constant returns(uint256) {
        for (uint i = 0; i < _owners.length; i++) {
            if (_owners[i] == _owner) {
                return i;
            }
        }
    }

    function removeFromOwners(uint256 _index, address[] storage _owners) internal constant returns(address[]) {
        require(_index <= _owners.length);
        for (uint256 i = _index; i < _owners.length - 1; i++) {
            _owners[i] = _owners[i + 1];
        }
        _owners.length--;
        return _owners;
    }

}
