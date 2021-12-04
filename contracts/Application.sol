// pragma solidity >0.4.23 <0.7.0;

pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

/// @title Base class for applications.
/// @author Aakash Jain, Ishaan Shah, Zeeshan Ahmed
/// @notice Do not deploy
/// @dev Parent class for the other contracts.
contract Application {
  /// @dev structure to contain details about users for verification.
  struct User {
    bool hasBought;
  }
  /// @dev structure to store all the details about the product 
  struct Details {
    string appName;
    string appDesc;
    uint256 price;
    uint256 developerCut;
    address payable developerID;
    uint256 downloads;
    string filePtr;
  }
  Details public details;

  mapping(address => User) public users;

  /// @notice Constructor for the auction. 
  /// @dev Triggers event for logs.
  /// @param _appName Name of the application.
  /// @param _appDesc Description of the application.
  /// @param _price Price of the application.
  /// @param _developerID address for payment.
  /// @param _filePtr pointer to BitTorrent seed
  /// @param _developerCut percentage of proceeds going to developer
  constructor(
    string memory _appName,
    string memory _appDesc,
    uint256 _price,
    address payable _developerID,
    string memory _filePtr,
    uint256 _developerCut
  ) public {
    details.appName = _appName;
    details.appDesc = _appDesc;
    details.price = _price;
    details.developerID = _developerID;
    details.filePtr = _filePtr;
    details.developerCut = _developerCut;
    details.downloads = 0;
  }
  /// @notice Triggered to store the details of a listing on transaction logs
  /// @param buyer address of the application buyer
  /// @param developerID address of the application developer
  /// @param appName name of the application
  event PurchaseMade (
    address buyer,
    address developerID,
    string appName
  );

  /// @notice Function called by the buyer to purchase an application.
  /// @param buyer address of the buyer.
  /// @return filePtr if the transaction is successful, else empty string.
  function buy(address payable buyer) public payable 
  {
      users[buyer] = User({ hasBought: true});
      // Passing on the price to the developer.
      details.developerID.transfer(details.developerCut);
      emit PurchaseMade(buyer, details.developerID, details.appName);
      details.downloads += 1;
  }

  /// @notice Fetches the details of the application.
  /// @return details structure of the contract.
  function fetchDetails() public view returns (Details memory) {
    return details;
  }

  /// @notice Verifies if the user has purchased the app.
  /// @param user Address of the user that needs verification.
  /// @return If the user has purchased the app.
  function checkPurchased(address user) public view returns (bool) {
    return users[user].hasBought;
  }

  /// @notice Fetches the file pointer to the application
  /// @return returns filePtr of the application
  function getFilePtr() public view returns (string memory) {
    return details.filePtr;
  }

  /// @notice Transfers the ownership of app to the new address
  /// @param user Original address of the application.
  /// @param newUser New address of the application.
  function transferOwner(address user, address newUser) public {
    if(users[user].hasBought) {
      users[user].hasBought = false;
      users[newUser].hasBought = true;
    }
  }

}
