// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;
import "remix_tests.sol"; 
import "remix_accounts.sol";
import "../contracts/Warehouse.sol";

contract WarehouseTest {
   
    Warehouse warehouseToTest;
    
    function beforeAll () public {
        warehouseToTest = new Warehouse();
    }
    
    function checkSetStockValueOK () public {
        uint256 newValue = warehouseToTest.getStockValue() + 10;
        warehouseToTest.setStockValue(newValue);
        
        Assert.equal(newValue, warehouseToTest.getStockValue(),'Stock value not updated');
    }
    
    function checkOrderInsufficientStock() public {
        warehouseToTest.setStockValue(1);
        
        try warehouseToTest.createOrder(10,"Cust") {
            Assert.ok(false, 'Order was created despite missing stock');
        } catch Error(string memory reason) {
            Assert.equal(reason, 'Insufficient stock', 'Failed with unexpected reason');
        } catch (bytes memory ) {
            Assert.ok(false, 'Failed unexpectedly');
        }
    }
    
    function checkOrderInsufficientPayment() public {
        warehouseToTest.setStockValue(10);
        
        try warehouseToTest.createOrder(10,"Cust") {
            Assert.ok(false, 'Order was created despite insufficient payment');
        } catch Error(string memory reason) {
            Assert.equal(reason, 'Insufficient payment', 'Failed with unexpected reason');
        } catch (bytes memory ) {
            Assert.ok(false, 'Failed unexpectedly');
        }
    }
    
    /// #value: 10
    function checkOrderOK() public payable {
        warehouseToTest.setStockValue(10);
        
        uint256 orderBefore = warehouseToTest.getOrderCounter();
        warehouseToTest.createOrder{value: msg.value}(10,"Cust");
        uint256 orderAfter = warehouseToTest.getOrderCounter();
        
        Assert.equal(orderBefore+1, orderAfter, 'Order counter not incremented');
    }
    
    /// #value: 10
    function checkShipOrderInsufficientStock() public payable {
        warehouseToTest.setStockValue(10);
        warehouseToTest.createOrder{value: msg.value}(10,"Cust");
        uint256 lastOrder = warehouseToTest.getOrderCounter() - 1;
        warehouseToTest.setStockValue(1);
        
        
        try warehouseToTest.shipOrder(lastOrder) {
            Assert.ok(false, 'Order was shipped despite missing stock');
        } catch Error(string memory reason) {
            Assert.equal(reason, 'Insufficient stock', 'Failed with unexpected reason');
        } catch (bytes memory ) {
            Assert.ok(false, 'Failed unexpectedly');
        }
    }
    
    /// #value: 10
    function checkShipOrderAlreadyShipped() public payable {
        warehouseToTest.setStockValue(100);
        warehouseToTest.createOrder{value: msg.value}(10,"Cust");
        uint256 lastOrder = warehouseToTest.getOrderCounter() - 1;
        
        warehouseToTest.shipOrder(lastOrder);
        
        try warehouseToTest.shipOrder(lastOrder) {
            Assert.ok(false, 'Order was shipped twice');
        } catch Error(string memory reason) {
            Assert.equal(reason, 'Order has been shipped already', 'Failed with unexpected reason');
        } catch (bytes memory ) {
            Assert.ok(false, 'Failed unexpectedly');
        }
    }
    
    /// #value: 10
    function checkShipOrderOK() public payable {
        warehouseToTest.setStockValue(100);
        warehouseToTest.createOrder{value: msg.value}(10,"Cust");
        uint256 lastOrder = warehouseToTest.getOrderCounter() - 1;
        
        warehouseToTest.shipOrder(lastOrder);
        uint256 stockAfter = warehouseToTest.getStockValue();
        
        Assert.equal(stockAfter, 90, 'Order amount not deducted from stock');
    }
 
}
