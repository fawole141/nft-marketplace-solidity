// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _itemSold;
    uint listingPrice = 0.0015 ether;
    address payable owner;
    mapping(uint => MarketItem) private idMarketItem;

    struct MarketItem{
        uint tokenId;
        address payable seller;
        address payable owner;
        uint price;
        bool sold;
    }

    event idMarketItemCreated(
        uint indexed tokenId,
        address seller,
        address owner,
        uint price,
        bool sold
    );

modifier onlyOwner{
    require(msg.sender == owner, "only owner of the marketplace can change the listing price");
_;
}
    constructor() ERC721("nft metaverse token","mntf"){
        owner == payable(msg.sender);
    }

function updateListingPrice(uint _listingPrice) public payable onlyOwner{
  listingPrice = _listingPrice;
}

function getListingPrice() public view returns(uint){
    return listingPrice;
}

//let create nft token function
function createToken(string memory tokenURI, uint price) public payable returns(uint){
    _tokenIds.increment();
    uint newTokenId = _tokenIds.current();
    _mint(msg.sender, newTokenId);
    _setTokenURI(newTokenId, tokenURI);
   
   createMarketItem(newTokenId, price);

   return newTokenId;
}
//creating market items
function createMarketItem(uint tokenId, uint price) private{
require(price >0 , "price must be at least 1");
require(msg.value == listingPrice , "price must be equal to listing price");

idMarketItem[tokenId] = MarketItem(
    tokenId,
    payable(msg.sender),
    payable(address(this)),
    price,
    false
);
_transfer(msg.sender, address(this), tokenId);
emit idMarketItemCreated(tokenId, msg.sender, address(this), price, false);
}

//function for resale token
function reSellToken(uint tokenId, uint price) public payable {
require(idMarketItem[tokenId].owner == msg.sender, "only item owner can perform this resale");
require(msg.value == listingPrice, "price must be equal to listing price");

idMarketItem[tokenId].sold = false;
idMarketItem[tokenId].price = price;
idMarketItem[tokenId].seller = payable(msg.sender);
idMarketItem[tokenId].owner = payable(address(this));

_itemSold.decrement();
_transfer(msg.sender, address(this), tokenId);
}

//function create market sales

function createMarketSale(uint tokenId) public payable{
uint price = idMarketItem[tokenId].price;
require(msg.value == price, "please submit the asking price in order to complete the purchase");
idMarketItem[tokenId].owner = payable(msg.sender);
idMarketItem[tokenId].sold = true;
idMarketItem[tokenId].owner = payable(address(0));
_itemSold.increment();
_transfer(address(this), msg.sender, tokenId);
payable(owner).transfer(listingPrice);
payable(idMarketItem[tokenId].seller).transfer(msg.value);
}

//getting unsold nft data
function fetchMarketItem() public view returns(MarketItem[] memory){
uint itemCount = _tokenIds.current();
uint unSoldItemCount = _tokenIds.current() - _itemSold.current();
uint currentIndex = 0;
MarketItem[] memory items = new MarketItem[](unSoldItemCount);
for(uint i = 0; i < itemCount; i++){
if(idMarketItem[i+1].owner == address(this)){
    uint currentId = i +1;
    MarketItem storage currentItem = idMarketItem[currentId];
    items[currentIndex] = currentItem;
    currentIndex += 1;
}

}
return items;

}
//purchase item
function fetchMyNFT() public view returns(MarketItem[] memory){
 uint totalCount =_tokenIds.current();
 uint itemCount = 0;
 uint currentIndex = 0;
 for(uint i =0; i< totalCount; i++){
    if(idMarketItem[i +1].owner == msg.sender){
        itemCount += 1;

    }
 }
  MarketItem[] memory items = new MarketItem[](itemCount);

  for(uint i=0; i< totalCount; i++){
      if(idMarketItem[i + 1].owner == msg.sender){
    uint currentId = i +1;
    MarketItem storage currentItem = idMarketItem[currentId];
    items[currentIndex] = currentItem;
    currentIndex += 1;

  }
}
return items;
}

//single user items
function fetchItemsListed() public view returns(MarketItem[] memory){
    uint totalCount = _tokenIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for(uint i=0; i< totalCount; i++){
        if(idMarketItem[i+1].seller == msg.sender){
            itemCount += 1;
        }
    }
    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i= 0; i < totalCount; i++) {
       if(idMarketItem[i+ 1].seller == msg.sender){
            uint currentId = i +1;
            MarketItem storage currentItem = idMarketItem[currentId];
            items[currentIndex] = currentItem;
            currentIndex += 1;
       }
    }
    return items;
}


}