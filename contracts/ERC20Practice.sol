// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ERC20 {
    function totalSupply() external view returns (uint256 _totalSupply);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint value);
    event Approval(address indexed _owner, address indexed _spender, uint value);
}


contract ERC20Practice is ERC20 {
    error InvalidAddress(address _addr);
    error NotEnoughAllowance(uint remainingAlowance);
    error NotEnoughBalance(uint balance, uint amount);

    string private __symbol;
    string private __name;
    uint8 private constant __decimals = 18;

    uint256 private constant __totalSupply = 1000000000000000000000000;

    mapping(address => uint256) private __balances;

    mapping(address => mapping(address => uint256)) private __allowances;


    /**
     * @dev Sets the initial balance for 
     * the owner of the contract and 
     * value for {__symbol} and {__name}
     * 
     * {__symbol} and {__name} are immutable 
     */
    constructor(string memory _symbol, string memory _name) {
        __balances[msg.sender] = __totalSupply;
        __symbol = _symbol;
        __name = _name;
    }

    /**
     * @dev Checks if provided address is a zero address
     * and if so, throws an InvalidAddress error
     */
    modifier noZeroAddress(address _addr) {
        if(_addr == address(0))
            revert InvalidAddress(_addr);
        _;
    }

    /**
     * @dev Returns the current balance of the address
     */
    function balanceOf(address _addr) public view override returns(uint256) {
        return __balances[_addr];
    }

    function transfer(address _to, uint256 _value) public override noZeroAddress(_to) returns(bool) {
        if (__balances[msg.sender] < _value)         
            return false;

        unchecked {
            // Underflow not possible:  did an if check before ^^^^
        __balances[msg.sender] -= _value;
            // Overflow not possible: balance + value <= totalSupply and totalSupply < uint256
        __balances[_to] += _value;
        }
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Returns the symbol of the token
     */
    function symbol() public view returns(string memory) {
        return __symbol;
    }

    /**
     * @dev Returns the name of the token
     */
    function name() public view returns(string memory) {
        return __name;
    }

    /**
     * @dev Returns the total supply of the token
     */
    function totalSupply() public pure returns(uint256) {
        return __totalSupply;
    }

    /**
     * @dev Returns the number of decimal places the token has
     */
    function decimals() public pure returns(uint8) {
        return __decimals;
    }

    /**
     * @dev This function can be used by a 3rd user only if {_from} address
     * approved {_to} address to use it's tokens.
     */
    function transferFrom(address _from, address _to, uint256 _value) public override noZeroAddress(_from) noZeroAddress(_to) returns(bool) {
        if (__allowances[_from][_to] < _value)
            revert NotEnoughAllowance(allowance(_from, _to));
        
        // Underflow not possible: Did an if check before whether _allowances[_from][_to] < value ^^^
        unchecked { __allowances[_from][_to] -= _value; }
        transfer(_to, _value);

        return true;
    }

    /**
     * @dev One addres can approve other address to use 
     * a certain amount of it's funds
     */
    function approve(address _addr, uint256 _amount) public override noZeroAddress(_addr) returns(bool) {
        if (__balances[msg.sender] < _amount)
            revert NotEnoughBalance(__balances[msg.sender], _amount);

        __allowances[msg.sender][_addr] = _amount;

        emit Approval(msg.sender, _addr, _amount);
        return true;
    }

    /**
     * @dev Returns the amount _spender has left to spend
     */
    function allowance(address _owner, address _spender) public view override returns(uint256 remaining) {
        return __allowances[_owner][_spender];
    }

}