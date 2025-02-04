// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "./Tokens/ConquerNFT.sol";
import "./Tokens/ConquerERC20.sol";

contract Marketplace is Ownable, ERC721Holder{
    error ConquerNFTMintingError();
    error ConquerMarketplaceInsufficientFunds();
    error ConquerNFTNonAvailable();

    event NFTAddedToMarketplace(uint256 tokenId);
    event NFTPurchased(address to, uint256 tokenId);

    ConquerERC20 public erc20Contract;
    ConquerNFT public nftContract;

    mapping(uint256 tokeId => bool) availableNFTs;

    uint256 public nftPrice = 0.01 ether;
    uint256 public rewardTokens = 20 * 10**18;

   constructor() Ownable(msg.sender) {
    nftContract = new ConquerNFT();
    erc20Contract = new ConquerERC20();
   }

   function addNFTToMarketplace(string memory tokenURI) external onlyOwner {
    uint256 tokenId = nftContract.mintConquerNFT(address(this), tokenURI);
    if (tokenId == 0){
        revert ConquerNFTMintingError();
    }
    availableNFTs[tokenId] = true;
    emit NFTAddedToMarketplace(tokenId);

   }

   function buyConquerNFT(uint256 tokenId) external payable {
    if (msg.value<nftPrice) {
        revert ConquerMarketplaceInsufficientFunds();
    }

    if(!availableNFTs[tokenId]){
        revert ConquerNFTNonAvailable();
    }

    availableNFTs[tokenId] = false;
    nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

    uint256 excessAmount = msg.value - nftPrice;
    if(excessAmount>0){
        (bool success, ) = msg.sender.call{value: excessAmount}("");
        require(success, "Refund failed");
    }

    erc20Contract.mintConquerERC20(msg.sender, rewardTokens);

    emit NFTPurchased(msg.sender, tokenId);

   }

   function setNftPrice(uint256 _nftPrice) external onlyOwner {
    nftPrice = _nftPrice;
   }

   function setRewardTokens(uint256 _rewardTokens) external onlyOwner {
    rewardTokens = _rewardTokens;
   }

   function withdraw() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
   }

   function getERC20Address() external view returns (address) {
    return address(erc20Contract);
   }

    function getNFTAddress() external view returns (address) {
    return address(nftContract);
   }

    function getAvailableNFTs() external view returns(uint256[] memory) {
        uint256 totalSupply = nftContract.currentTokenId();
        uint256 count = 0;

        for(uint i = 1; i<= totalSupply; i++){
            if(availableNFTs[i]){
                count= count +1;
            }
        }

        uint256[] memory tokenIds = new uint256[](count);
        uint256 index = 0;
        for(uint i = 1; i<= totalSupply; i++){
            if(availableNFTs[i]){
                tokenIds[index] = i;
                index++;
            }
        }
        return tokenIds;
    }

}