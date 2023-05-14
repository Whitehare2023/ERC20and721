// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./IERC165.sol";
import "./IERC721.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/utils/Address.sol";

/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface ERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);
}

contract ERC721 is IERC165, IERC721 {
    // ERC - 165 
    mapping(bytes4=>bool) supportsInterfaces;
    bytes4 invalidID = 0xffffffff;
    //0x80ac58cd erc721 
    //0x01ffc9a7 erc165 
    bytes4 constant ERC165_InterfaceID = 0x01ffc9a7;
    bytes4 constant ERC721_InterfaceID = 0x80ac58cd;
    /// struct for erc - 721 
    mapping(address=>uint256) ercTokenCount;  //  user's token count
    mapping(uint256=>address) ercTokenOwner;
    mapping(uint256=>address) ercTokenApproved;
    mapping(address=>mapping(address=>bool)) ercOperatorForAll;
    
    using Address for address;
    
    constructor() {
        _registerInterface(ERC165_InterfaceID);
        _registerInterface(ERC721_InterfaceID);
    }
    
    // 授权 
    modifier canOperator(uint256 _tokenId) {
        address owner = ercTokenOwner[_tokenId];
        require(msg.sender == owner ||
                ercOperatorForAll[owner][msg.sender]
                );
        _;
    }
    //转账 
    modifier canTransfer(uint256 _tokenId, address _from) {
        address owner = ercTokenOwner[_tokenId];
        require(owner == _from, "token's owner is not _from");
        require(msg.sender == owner || 
                ercTokenApproved[_tokenId] == msg.sender ||
                ercOperatorForAll[owner][msg.sender]
                );
        _;
    }
    
    function _registerInterface(bytes4 interfaceID) internal {
        
        supportsInterfaces[interfaceID] = true;
    }
    function supportsInterface(bytes4 interfaceID) override external view returns (bool) {
        require(invalidID != interfaceID, "invalid interfaceID");
        return supportsInterfaces[interfaceID];
    }
    
    /// **** IERC- 721 *** //// 
    function balanceOf(address _owner) override external view returns (uint256) {
        return ercTokenCount[_owner];
    }
    function ownerOf(uint256 _tokenId) override external view returns (address) {
        return ercTokenOwner[_tokenId];
    }
    function getApproved(uint256 _tokenId) override external view returns (address) {
        return ercTokenApproved[_tokenId];
    }
    function isApprovedForAll(address _owner, address _operator) override external view returns (bool) {
        return ercOperatorForAll[_owner][_operator];
    }
    // shou quan 
    function approve(address _approved, uint256 _tokenId) override canOperator(_tokenId) external payable {
        ercTokenApproved[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }
    function setApprovalForAll(address _operator, bool _approved) override external {
        ercOperatorForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }
    
    function transferFrom(address _from, address _to, uint256 _tokenId) override external payable {
        _transferFrom(_from, _to, _tokenId);
    }
    
    function _transferFrom(address _from, address _to, uint256 _tokenId)  internal canTransfer(_tokenId, _from)  {
        ercTokenOwner[_tokenId] = _to; // 更改属主 
        ercTokenCount[_from] -= 1;
        ercTokenCount[_to]   += 1;
        //取消授权 
        ercTokenApproved[_tokenId] = address(0);
        
        emit Transfer(_from, _to, _tokenId);
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) override external payable {
        _safeTransferFrom(_from, _to, _tokenId, data);
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) override external payable {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }
    
    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data)  internal {
        _transferFrom(_from, _to, _tokenId);
        
        // add safe code 
        if(_to.isContract()) {
            //address _operator, address _from, uint256 _tokenId, bytes memory _data
            bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data);
            require(retval == ERC721TokenReceiver.onERC721Received.selector, "retval not equal onERC721Received's interfaceID");
        }
    }
    
    function mint(address _to, uint256 _tokenId, bytes memory data) external {
        require(_to != address(0), "_to is a zero address");
        require(ercTokenOwner[_tokenId] == address(0), "_tokenId already exists");
        
        ercTokenOwner[_tokenId] = _to;
        ercTokenCount[_to] += 1;
        
        // add safe code 
        if(_to.isContract()) {
            //address _operator, address _from, uint256 _tokenId, bytes memory _data
            bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, address(0), _tokenId, data);
            require(retval == ERC721TokenReceiver.onERC721Received.selector, "retval not equal onERC721Received's interfaceID");
        }
        
        emit Transfer(address(0), _to, _tokenId);
    }
    
}