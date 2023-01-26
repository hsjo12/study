// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
contract Q1NFT is ERC721("SimpleNFT","SNFT"){
    //Library
    using Strings for uint256;

    //Constant    
    uint256 constant public MAX = 10;

    //Error
    error ExceededMAX();

    //Variable
    uint8 public id = 1;      


    function mint(uint256 _amount) external {
        uint8 _id = id;

        if(_id+_amount > MAX) 
            revert ExceededMAX();
        
        for(uint i = 0; i<_amount; ++i){
            ++_id;
            _mint(msg.sender, _id);
        }
        id = _id;
    }


    function _baseURI() internal pure override(ERC721) returns (string memory) {
        return "ipfs://bafybeiea6y5zjmgrpw4pihkjhehmkqs43mfistpowylzysq75o7uara2fq/";
    }

    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
        _requireMinted(tokenId);
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(),".json")) : "";
    }
}
