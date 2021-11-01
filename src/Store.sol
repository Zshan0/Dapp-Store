// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

import {Application} from "./Application.sol"

/// @title App store
/// @author Aakash Jain, Ishaan Shah, Zeeshan Ahmed
/// @notice View, sell, and buy applications
/// @dev 
contract Store {

    /// @dev 
    struct Purchase {
      address payable user;
    }

    /// @dev Stores the details of an application 
    struct AppDetails {
      uint listingID;
      string appName;
      string appDesc;
      uint256 price;
      address payable developerID;
      uint256 downloads;
      bytes32 fileHash;
      Application applicationContract;
    }
    uint appCount;

    /// @dev mapping for all the applications
    mapping(uint256 => AppDetails) private applications;
    mapping(bytes32 => bool) private hashList;

    /// @notice Triggered to store the details of a listing on transaction logs
    /// @param listingID Unique ID for the application.
    /// @param appName Name of the appplication.
    /// @param price Price set by the developer.
    /// @param developerID Address of the developer for transferring funds.
    event ApplicationAdded (
      uint indexed listingID,
      string appName,
      uint price,
      address developerID
    );

    /// @notice Function to add application to the app store.
    /// @dev Triggers the event for logging
    /// @param appName Name of the item
    /// @param appDesc Description of the item set by seller
    /// @param price Price set by the seller
    /// @param filePtr The pointer which will allow user to download the app.
    /// @param developerCut Value which will be transferred to the developer.
    function createAppListing(
      string memory appName,
      string memory appDesc,
      uint256 price,
      string memory filePtr,
      uint256 developerCut,
      uint256 fileHash
    ) public payable {
      if(hashList[fileHash]) {
        return;
      }
      // generating a new random id.
      uint id = (keccak256(abi.encodePacked(
                block.difficulty, block.timestamp, players)));
      // storing the newly created application in the map.
      listings[id] = Listing(
        id,
        appName,
        appDesc,
        price,
        msg.sender,
        0,
        fileHash,
        new Application(
          appName, appDesc, price, developerID, filePtr, developerCut)
      );
      appCount += 1;

      emit ListingCreated(id, appName, price, msg.sender);
    }


    /// @notice Function to fetch details on all the apps on the store.
    /// @return Application The list of all apps with support.
    /// @param itemId The itemId of the required app.
    function fetchApp(uint itemId) public view returns (Application memory) {
      return applications[itemId];
    }

    /// @notice Function to buy a listing and accepts the money to store in the contract
    /// @dev Triggers the event for logging
    /// @param itemId The item the buyer wants to buy
    function buyApp(uint itemId) external payable return (string memory){
      // transferring the funds to the contract which deals with
      // the particular app.
      return applications[itemId].buy.value(msg.value)(msg.sender);
    }

    /// @notice Verifies if the user has purchased required app.
    /// @param appId Id of the app which is being checked.
    /// @param user Address of the user that needs verification.
    /// @return If the user has purchased the app.
    function checkPurchased(uint256 appId, address user) 
      public view returns (bool) 
    {
        return applications[appId].checkPurchased(user);
    }

}

