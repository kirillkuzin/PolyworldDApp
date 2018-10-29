/*
author: Kirill Kuzin (https://github.com/kirillkuzin)

TODO:
1) Добавить комментарии
*/

pragma solidity ^0.4.21;

library PolyworldLibrary {

    function findOwnerIndex(uint256[] _owners, uint256 _owner) internal returns(uint256) {
        for (uint256 i = 0; i < _owners.length; i++) {
            if (_owners[i] == _owner) {
                return i;
            }
        }
    }

    function removeFromOwners(uint256 _index, uint256[] storage _owners) internal returns(uint256[]) {
        require(_index <= _owners.length);
        for (uint256 i = _index; i < _owners.length - 1; i++) {
            _owners[i] = _owners[i + 1];
        }
        _owners.length--;
        return _owners;
    }

}
