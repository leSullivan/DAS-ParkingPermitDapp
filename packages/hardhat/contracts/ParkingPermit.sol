//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ParkingPermit is Ownable{

  modifier onlyAuthorizedRegulator(){
    require(regulatorIsAuthorized[msg.sender], "You are not permitted to access this data");
    _;
  }

  modifier onlyAuthorizedResident(){
    require(citizenIsResident[msg.sender], "You are not an authorized citizen of this parking zone");
    _;
  }

  event citizedRegistered(
    address
  );

  event citizenRegisteredGuest(
    address
  );

  event permitRevoked(
    address
  );

  uint256 priceForResidentRegistration = 1 ether;
  uint256 priceForGuestRegistrationPerDay = 0.1 ether;
  uint256 timeRegisteredForCitizen = 365 days;
  uint256 deadline;
  string licencePlate;
  string parkingZoneId;

  mapping(address => bool) private citizenIsResident;
  mapping(address => string)private residentToParkingZoneId;
  mapping(address => bool) private regulatorIsAuthorized;
  mapping(string => Permit) private carToPermit;

  struct Permit{
    uint256 deadline;
    string parkingZoneId;
    bool parkingGranted;
  }


  /**
  @notice function to register an authorized citizen for parking permit
  @param _licensePlate licence plate string in format "(X)(X)X-XX-(X)(X)X"
  @param _citizen wallet address of citizen to verify guest registration
  @param _parkingZoneId id of registered parking zone
  */
  function residentCarRegistration(address _citizen, string memory _licensePlate,  string memory _parkingZoneId) external payable onlyOwner{
    require(msg.value == priceForResidentRegistration, "Please send the exact ammount of ether");
    deadline = block.timestamp + timeRegisteredForCitizen;
    Permit memory permit = Permit(deadline, _parkingZoneId, true);
    carToPermit[_licensePlate] = permit;
    citizenIsResident[_citizen] = true;
    residentToParkingZoneId[_citizen] = _parkingZoneId;
    emit citizedRegistered(_citizen);
  }   
  
  /**
  @notice function to temporarily register guests for own parkingzone
  @param _periodInDays ammount of days to grant parking permit
  @param _licensePlate license plate in format "(X)(X)X-XX-(X)(X)X" for guest car
  */
  function registerGuestParkingPermit(uint256 _periodInDays, string memory _licensePlate) external onlyAuthorizedResident{
    deadline = block.timestamp + _periodInDays * 1 days;
    parkingZoneId = residentToParkingZoneId[msg.sender];
    Permit memory permit = Permit(deadline, parkingZoneId,true);
    carToPermit[_licensePlate] = permit;
    emit citizenRegisteredGuest(msg.sender);
  }
  
  /**
  @notice revoke a permit from a car
  */
  function revokePermitFromCar(address _citizen, string memory _licensePlate) external onlyOwner{
    Permit memory permit = Permit(block.timestamp, parkingZoneId, false);
    carToPermit[_licensePlate] = permit;
    citizenIsResident[_citizen] = false;
    emit permitRevoked(msg.sender);
  }
  
  /**
  @notice verify parking permit by licence plate input
  @param _licensePlate license plate in format "(X)(X)X-XX-(X)(X)X"
  */
  function verifyParkingPermit(string memory _licensePlate, string memory _parkingZoneId)
  external view onlyAuthorizedRegulator
  returns(Permit memory)
  {
    Permit memory permit = carToPermit[_licensePlate];
    if(checkTime(permit.deadline)){
        return permit;
    }
    permit.parkingGranted = false;
    return permit;
    
  }

  /**
  @notice authorize a regulator to check license plates
   */
  function authorizeRegulator(address _regulator)external onlyOwner{
    regulatorIsAuthorized[_regulator] = true;
  }

  /**
  @notice unauthorize a regulator to check license plates
  */
  function deauthorizeRugulator(address _regulator)external onlyOwner{
    regulatorIsAuthorized[_regulator] = false;
  }

  /**
  @notice set price for resident registration in wei
  */
  function setPriceForResidentRegistration(uint256 _newPriceInWei)external{
    priceForResidentRegistration = _newPriceInWei * 1 wei;
  }

  /**
  @notice set price for guest registration in wei
  */
  function setPriceForGuestRegistration(uint256 _newPriceInWei)external{
    priceForGuestRegistrationPerDay = _newPriceInWei * 1 wei;
  }

  /**
  @notice allows contract owner to withtdraw all funds
   */
  function withdrawFunds() external onlyOwner{
    (bool success,) = msg.sender.call{value: address(this).balance}("");
    require(success,"Transaction failed.");
  }

  //lowLevelfunctions

  /**
  @dev reverts all unassociated payments
   */
  receive() external payable{
    revert();
  }

  /**
  @dev returns true when current block.timestamp > set deadline
  @notice returns true when car is permitted to stay
  */
  function checkTime(uint256 deadline) private view returns(bool){
    return deadline > block.timestamp;
  }
}
