// SPDX-License-Identifier: Apache-2.0
pragma solidity^0.8.7; 

import "./IERC20.sol";
import "./SafeMath.sol";

contract ERC20 is IERC20 {
    
    string ercName;
    string ercSymbol;
    uint8  ercDecimal;
    uint256 ercTotalSupply;
    using SafeMath for uint256;
    mapping(address=>uint256) ercBalances; // 自定义账本 
    mapping(address=>mapping(address=>uint256)) ercAllowance; // 委托
    
    address public owner;
    
    constructor(string memory _name, string memory _sym, uint8 _decimals) {
        ercName = _name;
        ercSymbol = _sym;
        ercDecimal = _decimals;
        owner  = msg.sender;
        ercTotalSupply = 21000000;
        ercBalances[owner] = ercTotalSupply;
    }
    
    function name() override external view returns (string memory) {
        return ercName;
    }
    function symbol() override external view returns (string memory) {
        return ercSymbol;
    }
    function decimals() override external view returns (uint8) {
        return ercDecimal;
    }
    function totalSupply() override external view returns (uint256) {
        return ercTotalSupply;
    }
    function balanceOf(address _owner) override external view returns (uint256 balance) {
        return ercBalances[_owner];
    }
    function transfer(address _to, uint256 _value) override external returns (bool success) {
        require(_value > 0, "_value must > 0");
        require(address(0) != _to, "to address is zero");
        require(ercBalances[msg.sender] >= _value, "user's balance not enough");
        
        //ercBalances[msg.sender] -= _value;
        ercBalances[msg.sender] = ercBalances[msg.sender].sub(_value);
        //ercBalances[_to] += _value;
        ercBalances[_to] = ercBalances[_to].add(_value);
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) override external returns (bool success) {
        require(ercBalances[_from] >= _value, "user's balance not enough");
        require(ercAllowance[_from][msg.sender] >= _value, "approve's balance not enough");
        require(_value > 0, "value must > 0");
        require(address(0) != _to, "_to is a zero address");
        
        ercBalances[_from] -= _value;
        ercBalances[_to]   += _value;
        ercAllowance[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) override external returns (bool success) {
        // 委托人 -> 被委托人 -> value 
        require(_value > 0, "value must > 0"); // 这一句注释上等于收回授权
        require(address(0)  != _spender, "_spender is a zero address");
        require(ercBalances[msg.sender] >= _value, "user's balance not enough");
        
        ercAllowance[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) override external view returns (uint256 remaining) {
        remaining = ercAllowance[_owner][_spender]; 
    }
    
    function mint(address _to, uint256 _value) public {
        require(msg.sender == owner, "only owner can do");
        require(address(0) != _to, "to is a zero address");
        require(_value > 0, "value must > 0");
        
        ercBalances[_to] += _value;
        ercTotalSupply   += _value;
        
        emit Transfer(address(0), _to, _value);
        
    }
}