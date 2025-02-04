// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ConquerNFT is ERC721, Ownable{
    error ConquerNFTNonExistentToken();
    
    uint256 _tokenId;

    mapping(uint256 tokenId => string) private _tokenURIs;

    constructor() ERC721("Conquer NFT Collection", "CNFT") Ownable(msg.sender){
        _tokenId = 0;
    }

    function mintConquerNFT(address to, string memory _tokenURI) external onlyOwner returns(uint256) {
        _tokenId = _tokenId+1;
        _safeMint(to, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
        return _tokenId;
    }

    function currentTokenId() external view returns (uint256){
        return _tokenId;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        if(tokenId > _tokenId) {
            revert ConquerNFTNonExistentToken();
        }
        _tokenURIs[tokenId] = _tokenURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if(tokenId > _tokenId) {
            revert ConquerNFTNonExistentToken();
        }
        return _tokenURIs[tokenId];
    }

}