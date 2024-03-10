// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./PetNFT.sol";

contract PetToken is ERC20 {
    PetNFT public petNFT;
    address public taxRecipient;
    uint256 public taxRate = 10; 
    uint256 public nftCount = 0;
    mapping(address => bool) public hasReceivedEgg;
    uint256 totalTax;
    bool private locked;

    modifier noReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    //hook as a modifier
    modifier taxHook(address sender, address recipient, uint256 amount) {
        uint256 taxAmount = (amount * taxRate) / 1000;
        uint256 transferAmount = amount - taxAmount;
        _;
        totalTax += taxAmount;
        super._update(sender, address(this), taxAmount);
        super._update(sender, recipient, transferAmount);
    }
    

    constructor(address _taxRecipient, address _petNFTAddress) ERC20("Pet Token", "PET") {
        taxRecipient = _taxRecipient;
        petNFT = PetNFT(_petNFTAddress);
        _mint(msg.sender, 1000000 * (10**decimals()));

    }

    function _update(address sender, address recipient, uint256 amount) internal taxHook(sender, recipient, amount) virtual override  {
        if (!hasReceivedEgg[recipient]) {
            petNFT.mint(recipient, nftCount);
            hasReceivedEgg[recipient] = true;
            nftCount += 1;
        }
    }


    function setTaxRecipient(address newRecipient) external {
        require(msg.sender == taxRecipient, "Only the tax recipient can change the recipient address");
        taxRecipient = newRecipient;
    }

    function setTaxRate(uint256 newRate) external {
        require(msg.sender == taxRecipient, "Only the tax recipient can change the tax rate");
        taxRate = newRate;
    }

    function sendTotalTaxToRecipient() external noReentrant {
        require(totalTax > 0, "No tax to send");
        uint256 amount = totalTax;
        totalTax = 0;
        super._update(address(this), taxRecipient, amount);
    }
}
