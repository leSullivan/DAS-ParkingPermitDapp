//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ParkingPermit is Ownable{

    event citizedRegistered(
      address
    );

    event citizenRegisteredGuest(
      address
    );

    uint256 priceForResidentRegistration = 1 ether;
    uint256 priceForGuestRegistrationPerDay = 0.1 ether;
		uint256 timeRegisteredForCitizen = 365 days;
    uint256 deadline;
    string licencePlate;
    string parkingZoneId;

    mapping(address => bool) private citizenIsResident;
    mapping(address => string)private cizizenToParkingZoneId;
    mapping(address => bool) private regulatorIsAuthorized;
    mapping(string => Permit) private carToPermit;

    struct Permit{
      uint256 deadline;
      string parkingZoneId;
    }


		/**
		@notice function to register an authorized citizen for parking permit
    @param _licensePlate licence plate string in format "(X)(X)X-XX-(X)(X)X"
    @param _citizen wallet address of citizen to verify guest registration
    @param _parkingZoneId id of registered parking zone
		*/
    function citizenRegistrationForResidency(address _citizen, string memory _licensePlate,  string memory _parkingZoneId) external payable onlyOwner{
      require(msg.value == priceForResidentRegistration, "Please send the exact ammount of ether");
      deadline = block.timestamp + timeRegisteredForCitizen;
      Permit memory permit = Permit(deadline, _parkingZoneId);
      carToPermit[_licensePlate] = permit;
      citizenIsResident[_citizen] = true;
      cizizenToParkingZoneId[_citizen] = _parkingZoneId;
      emit citizedRegistered(_citizen);
    }   
		
		/**
		@notice function to temporarily register guests for own parkingzone
    @param _periodInDays ammount of days to grant parking permit
    @param _licensePlate license plate in format "(X)(X)X-XX-(X)(X)X" for guest car
		*/
    function registerGuestParkingPermit(uint256 _periodInDays, string memory _licensePlate) external{
      require(citizenIsResident[msg.sender], "You are not an authorized citizen of this parking zone");
      deadline = block.timestamp + _periodInDays * 1 days;
      parkingZoneId = cizizenToParkingZoneId[msg.sender];
      Permit memory permit = Permit(deadline, parkingZoneId);
      carToPermit[_licensePlate] = permit;
      emit citizenRegisteredGuest(msg.sender);
    }
		
		// /**
		// @notice berechtigungs kann vorzeitig entfernt werden. evtl. refund
		// */
    // function berechtigungWegnehmen(adresse){
        
    // }
		
		// /**
		// @notice prüfung für Ordnungsamt
		// */
    // function hatPersonGueltigenZugang(kennzeichen)
		// public nurOrdnungsamt
		// returns(Genehmigung)
		// {
        
    // }

		// //lowLevelfunctions
		
}
