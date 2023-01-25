// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Q3NFT is ERC721Enumerable{
    //Library
    using Strings for uint256;

    //Constant
    uint256 constant public MAX = 20;
    
    //Error
    error ExceededMAX();
    
    //Variable
    uint8 public id = 1;      

    constructor() ERC721("SimpleNFT","SNFT") {

    }

    function mint(uint256 _amount) external payable {
        uint8 _id = id;
        address _user = msg.sender;
        if(_id > MAX) 
            revert ExceededMAX();

        for(uint i = 0; i<_amount; ++i){
            _mint(_user, _id);
            ++_id;
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
