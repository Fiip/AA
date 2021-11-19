// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;
import '@openzeppelin/contracts/access/AccessControl.sol';
import './IWarehouse.sol';

contract Warehouse is AccessControl, IWarehouse {
    bytes32 private constant MANAGER = keccak256('MANAGER');
    uint256 private constant PRICE = 1;
    
    uint256 currentStock;
    uint256 orderCounter;
    mapping(uint256 => Order) orders;

    struct Order {
        uint256 amount;
        string customer;
        bool shipped;
    }
   
    constructor()  
    {
        _setupRole(MANAGER, msg.sender);
        orderCounter = 1;
    }
    
    function getStockValue() override external view returns (uint256) {
        return currentStock;
    }
    
    function setStockValue(uint256 stock) override external {
        require(hasRole(MANAGER, msg.sender), 'Caller is not a warehouse manager!');
        
        currentStock = stock; //TODO spec ambiguous: not clear whether manager is allowed to increment stock only, or decrease it too
    }
    
    function getOrderCounter() external view returns (uint256) {
        return orderCounter;
    }
    
    function createOrder(uint256 amount, string calldata customerName) override payable external 
    {
        require(currentStock >= amount, 'Insufficient stock');
        uint256 orderValue = amount * PRICE; //TODO starting with solidity 0.8, SafeMath isn't needed here
        require(msg.value >=  orderValue, 'Insufficient payment');
       
        uint256 orderId = orderCounter++;
        orders[orderId] = Order(amount, customerName, false);
        
        emit OrderCreated(orderId);
    }
    
    function shipOrder(uint256 orderId) override external
    {
        require(hasRole(MANAGER, msg.sender), 'Caller is not a warehouse manager!');
        Order memory order = orders[orderId];
        require(!order.shipped, 'Order has been shipped already');
        require(currentStock >= order.amount, 'Insufficient stock');
        
        currentStock-= order.amount;
        orders[orderId].shipped = true;
       
        emit OrderShipped(orderId);
    }
    
    receive() external payable
    {
        //TODO handle payment
    }
}
