// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract PetNFT is ERC721 {

    mapping (uint256 => Stage) public stages;

    enum Stage {
        Unknow,
        Egg,
        Childhood,
        Children,
        Adolescent,
        Adult
    }

    constructor() ERC721("PetNFT", "PETNFT") {

    }

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
        stages[tokenId] = Stage.Adult;
    }

    function mockStageChanged(uint tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "not owner");
        Stage storage stage = stages[tokenId];
        require(uint(stage) != 0, "don't exist");
        stages[msg.sender] = Stage(uint(currentStage) + 1);
    }
    
}