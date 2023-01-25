// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
contract Rewards is ERC20, AccessControl{
    bytes32 constant public MANAGER = 0xaf290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c;
    
    constructor() ERC20("Rewards","RWD") {
        _grantRole(DEFAULT_ADMIN_ROLE,msg.sender);
        _grantRole(MANAGER, msg.sender);
    }

    function mint(address _to, uint256 _amount) external onlyRole(MANAGER) {
        _mint(_to, _amount);
    }

}
