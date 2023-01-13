//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import './ParkingPermit.sol';
// Chainlink Imports

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

contract FutureImplementaions is ParkingPermit, KeeperCompatibleInterface, VRFConsumerBaseV2{

    AggregatorV3Interface public aggregatorV3Interface;
    uint intervalSeconds; 
    uint64 subscriptionId;
    uint256 currentPrice;
    uint256 lastPrice;
    uint256 lastTimeStamp;

    constructor(uint _intervalSeconds, address _pricefeed, uint _subscriptionId) 
    {
        intervalSeconds = _intervalSeconds;
        lastTimeStamp = block.timestamp;
        subscriptionId = _subscriptionId;

        //set to a pricefeed on goerli network. currently set to BTC/USD goerli
        pricefeed = AggregatorV3Interface(_pricefeed);

        // set the price for the chosen currency pair.
        currentPrice = getLatestPrice();
    }

    function checkUpkeep(bytes calldata /*checkData*/)external view override returns(bool upkeepNeeded, bytes memory /*performData*/){
        upkeepNeeded = (block.timestamp - lastTimeStamp) > intervalSeconds;
    }

    function performUpkeep(bytes calldata /*performData*/) external override{
        require((block.timestamp - lastTimeStamp) > intervalSeconds); 
        console.log("Upkeep Started");
        lastTimeStamp = block.timestamp;
        int latestPrice = getLatestPrice();
        uint256 priceRatio = latestPrice / currentPrice;
        ParkingPermit.setPriceForResidentRegistration(ParkingPermit.priceForResidentRegistration * priceRatio);
        ParkingPermit.setPriceForGuestRegistrationPerDay(ParkingPermit.priceForGuestRegistrationPerDay * priceRatio);
        currentPrice = latestPrice;
        
    }
}


    

