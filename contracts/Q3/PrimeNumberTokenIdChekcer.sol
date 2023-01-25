//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
contract PrimeNumberTokenIdChekcer {

    IERC721Enumerable immutable public targetNFT;

    constructor(address _targetNFT) {
        targetNFT = IERC721Enumerable(_targetNFT);
    }

    function checkPrimeNumberTokenIds(address _user) external view returns(uint256[] memory totalTokenPrimeIds) {
        uint256 _length = targetNFT.balanceOf(_user);
        uint256 _tokenId;
        uint256 _totalPrimeNum;
        bool _isNotPrime;
        uint256[] memory  ownedPrimeTokenList = new uint256[](_length);
        for(uint256 i; i<_length; ++i) {
            _tokenId = targetNFT.tokenOfOwnerByIndex(_user,i);
            if(_tokenId == 1) {
                continue;
            }
            if(_tokenId == 2) {
                ownedPrimeTokenList[_totalPrimeNum]=_tokenId;
                ++_totalPrimeNum;
            }
            else{
                for(uint p = 2; p < _tokenId; ++p)
                    {
                        if(_tokenId % p == 0) {
                            _isNotPrime = true;
                            break;        
                        }
                    }
                    if(!_isNotPrime) {
                        ownedPrimeTokenList[_totalPrimeNum]=_tokenId;
                        ++_totalPrimeNum;
                    }
                 _isNotPrime = false;
            }
            
        }
        totalTokenPrimeIds = new uint256[](_totalPrimeNum);
        for(uint256 i; i<_totalPrimeNum; i++) {
            totalTokenPrimeIds[i] = ownedPrimeTokenList[i];
        }
    }
}