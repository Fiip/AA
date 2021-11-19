// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

interface IWarehouse {
    function getStockValue() external view returns (uint256);
    function setStockValue(uint256 stock) external;
    function createOrder(uint256 amount, string calldata customerName) payable external;
    function shipOrder(uint256 orderId) external;
    
    event OrderCreated(uint256 orderId);
    event OrderShipped(uint256 orderId);
}