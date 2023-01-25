// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
contract Q2NFT is ERC721("Rewards","RWD"), Ownable{
    //Library
    using Strings for uint256;

    //Constant
    bytes32 constant public MANAGER = 0xaf290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c;
    uint256 constant public PRICE = 0.01 ether;
    uint256 constant public MAX = 10;

    //Error
    error ExceededMAX();
    error InsuficientPrice(uint256 correctPrice, uint256 receivedAmount);

    //Vairable
    uint8 public id = 1;      

    function mint(uint256 _amount) external payable {
        uint8 _id = id;
        if(_id+_amount > MAX) 
            revert ExceededMAX();
        
        if(PRICE*_amount != msg.value)
            revert  InsuficientPrice(PRICE*_amount,msg.value);

        for(uint i = 0; i<_amount; ++i){
            _mint(msg.sender, _id);
            ++_id;
        }
        id = _id;
    }

    function owerMint(uint256 _amount) external onlyOwner {
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
        return "ipfs://bafybeiarzfz5skwlsvnzuwswtnbo3kqgblbb2pjasw4bb24eleykolhnhq/";
    }

    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
        _requireMinted(tokenId);
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(),".json")) : "";
    }

}
