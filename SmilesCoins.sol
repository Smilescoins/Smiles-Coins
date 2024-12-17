
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmilesCoins {
    string public name = "Smiles Coins";
    string public symbol = "SMIC";
    uint8 public decimals = 18;
    uint256 public totalSupply = 900000000000 * 10 ** uint256(decimals);
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public transactionFee = 1; // 1% de frais de transaction
    uint256 public feePool; // Réserve des frais collectés

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event FeesCollected(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Action réservée au propriétaire.");
        _;
    }

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Solde insuffisant.");
        uint256 fee = (_value * transactionFee) / 100;
        uint256 amountToTransfer = _value - fee;

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += amountToTransfer;
        feePool += fee;

        emit Transfer(msg.sender, _to, amountToTransfer);
        emit FeesCollected(fee);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Solde insuffisant.");
        require(allowance[_from][msg.sender] >= _value, "Allocation insuffisante.");
        uint256 fee = (_value * transactionFee) / 100;
        uint256 amountToTransfer = _value - fee;

        balanceOf[_from] -= _value;
        balanceOf[_to] += amountToTransfer;
        allowance[_from][msg.sender] -= _value;
        feePool += fee;

        emit Transfer(_from, _to, amountToTransfer);
        emit FeesCollected(fee);
        return true;
    }

    function adjustTransactionFee(uint256 _newFee) public onlyOwner {
        require(_newFee <= 10, "Le frais ne peut pas dépasser 10%.");
        transactionFee = _newFee;
    }

    function withdrawFees() public onlyOwner {
        uint256 amount = feePool;
        feePool = 0;
        balanceOf[owner] += amount;
    }
}
