// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "./IRewards.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "hardhat/console.sol";
contract Stake is ReentrancyGuard,IERC721Receiver { 
    uint256 constant public rewards = 10 ether; 
    uint256 constant public rewardTime = 1 days; 
    IRewards immutable public rewardToken;
    IERC721 immutable public targetNFT;

    error OnlyTargetNFT(address currentNFT, address targetNFT);
    error NotTokenStaker();


    struct tokenInfo {
        uint256 tokenId;
        uint256 stakingTime;
        uint256 totalClaimedRewards;
    }
    mapping(address=>tokenInfo[]) public userStakingInfo;
    mapping(uint256=>uint256) private _tokenIndex;

    constructor(address _rewardToken, address _targetNFT) {
        rewardToken = IRewards(_rewardToken);
        targetNFT = IERC721(_targetNFT);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        if(msg.sender != address(targetNFT)) 
            revert OnlyTargetNFT(msg.sender, address(targetNFT));
        tokenInfo[] storage _userStakingInfo = userStakingInfo[from];
        _tokenIndex[tokenId] = _userStakingInfo.length;
        _userStakingInfo.push(tokenInfo(tokenId,block.timestamp,0));

        return IERC721Receiver.onERC721Received.selector;
    }


    function stakingNfts(uint256[] calldata tokenIds) external{
        address _user = msg.sender;
        for(uint256 i = 0; i<tokenIds.length; ++i) {
            targetNFT.safeTransferFrom(_user, address(this), tokenIds[i]);
        }
    }

    function withdrawNFTs(uint256[] calldata tokenIds) external {
        address _user = msg.sender;
        tokenInfo[] storage _userStakingInfo = userStakingInfo[_user];
        if(_userStakingInfo.length == 0) {
            revert NotTokenStaker();
        }
        uint256 _lastIndex = _userStakingInfo.length - 1;
        uint256 tokenId;
        uint256 _targetIndex;
        for(uint256 i = 0; i<tokenIds.length; ++i) {
        tokenId = tokenIds[i]; 
        _targetIndex = _tokenIndex[tokenId];

        if(_lastIndex < _targetIndex && _userStakingInfo[_targetIndex].tokenId != tokenId) {
            revert NotTokenStaker();
        }


        uint256 _maximum_rewards = ((block.timestamp - _userStakingInfo[_targetIndex].stakingTime)/rewardTime) * rewards;
        
        if(_maximum_rewards > _userStakingInfo[_targetIndex].totalClaimedRewards) {
          rewardToken.mint(_user,  _maximum_rewards - _userStakingInfo[_targetIndex].totalClaimedRewards);
        }
        

        if(_lastIndex != _targetIndex) {
            userStakingInfo[_user][_targetIndex] = userStakingInfo[_user][_lastIndex]; 
            _tokenIndex[userStakingInfo[_user][_lastIndex].tokenId] = _targetIndex;
        }
        delete userStakingInfo[_user][_lastIndex];
        delete _tokenIndex[tokenId];
        targetNFT.safeTransferFrom(address(this), _user, tokenId);
        }

    }


    function withdrawNFT(uint256 tokenId) external {
        address _user = msg.sender;
        tokenInfo[] storage _userStakingInfo = userStakingInfo[_user];
        if(_userStakingInfo.length == 0) {
            revert NotTokenStaker();
        }
        uint256 _targetIndex = _tokenIndex[tokenId];
        uint256 _lastIndex = _userStakingInfo.length - 1;

        if(_lastIndex < _targetIndex && _userStakingInfo[_targetIndex].tokenId != tokenId) {
            revert NotTokenStaker();
        }
        uint256 _maximum_rewards = ((block.timestamp - _userStakingInfo[_targetIndex].stakingTime)/rewardTime) * rewards;
        
        if(_maximum_rewards > _userStakingInfo[_targetIndex].totalClaimedRewards) {
          rewardToken.mint(_user,  _maximum_rewards - _userStakingInfo[_targetIndex].totalClaimedRewards);
        }

       
        if(_lastIndex != _targetIndex) {
            userStakingInfo[_user][_targetIndex] = userStakingInfo[_user][_lastIndex]; 
            _tokenIndex[userStakingInfo[_user][_lastIndex].tokenId] = _targetIndex;
        }
        delete userStakingInfo[_user][_lastIndex];
        delete _tokenIndex[tokenId];
        targetNFT.safeTransferFrom(address(this), _user, tokenId);
    }

    function claimRewards() external nonReentrant() {
        address _user = msg.sender;
 
        tokenInfo[] storage _userStakingInfo = userStakingInfo[_user];
        uint256 total;
        uint256 _totalClaimedRewards;
        for(uint i = 0; i < _userStakingInfo.length; i++ ) {
            _totalClaimedRewards += _userStakingInfo[i].totalClaimedRewards;
            _userStakingInfo[i].totalClaimedRewards = ((block.timestamp - _userStakingInfo[i].stakingTime)/rewardTime) * rewards;
            total += _userStakingInfo[i].totalClaimedRewards;
        }
        rewardToken.mint(_user, total - _totalClaimedRewards);
    }

    function rewardsOf(address _user) external view returns(uint256) {
        tokenInfo[] storage _userStakingInfo = userStakingInfo[_user];
        uint256 total;
        uint256 _totalClaimedRewards;
        for(uint i = 0; i < _userStakingInfo.length; i++ ) {
            _totalClaimedRewards += _userStakingInfo[i].totalClaimedRewards;
            total += ((block.timestamp - _userStakingInfo[i].stakingTime)/rewardTime) * rewards;
        }
        return total - _totalClaimedRewards;
    } 

    function stakingNumberOf(address _user) external view returns(uint256) {
        return userStakingInfo[_user].length;
    }

}