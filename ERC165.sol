pragma solidity ^0.8.7;

import "./IERC165.sol";

contract ERC165 is IERC165 {
    /// @dev You must not set element 0xffffffff to true
    mapping(bytes4 => bool)  supportedInterfaces;

    constructor()  {
        supportedInterfaces[IERC165.supportsInterface.selector] = true;
    }

    function supportsInterface(bytes4 interfaceID) override external view returns (bool) {
        return supportedInterfaces[interfaceID];
    }
}

interface Simpson {
    function is2D() external returns (bool);
    function skinColor() external returns (string memory);
}

contract Lisa is ERC165, Simpson {
    constructor() {
        supportedInterfaces[Simpson.is2D.selector ^ Simpson.skinColor.selector] = true;
    }
    
    function getID() public pure returns (bytes4) {
        return Simpson.is2D.selector ^ Simpson.skinColor.selector;
    }

    function is2D() override external returns (bool){}
    function skinColor() override external returns (string memory){}
}