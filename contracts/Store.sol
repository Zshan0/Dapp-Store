// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

import {Application} from "./Application.sol";

/// @title App store
/// @author Aakash Jain, Ishaan Shah, Zeeshan Ahmed
/// @notice View, sell, and buy applications
contract Store {

    struct Purchase {
        address payable user;
    }

    /// @dev Stores the details of an application
    struct AppDetails {
        uint256 listingID;
        string appName;
        string appDesc;
        uint256 price;
        address payable developerID;
        uint256 downloads;
        bytes32 fileHash;
        Application applicationContract;
    }
    uint256 appCount;
    address payable public owner;

    /// @dev mapping for all the applications
    mapping(uint256 => AppDetails) private applications;
    /// @dev list of all the hash of the files so far.
    mapping(bytes32 => bool) private hashList;

    /// @notice Triggered to store the details of a listing on transaction logs
    /// @param listingID Unique ID for the application.
    /// @param appName Name of the appplication.
    /// @param price Price set by the developer.
    /// @param developerID Address of the developer for transferring funds.
    event ApplicationAdded(
        uint256 indexed listingID,
        string appName,
        uint256 price,
        address developerID
    );


    /// @notice Constructor to define the marketplace owner
    constructor() public {
        owner = msg.sender;
    }

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
        bytes32 fileHash
    ) public payable {
        if (hashList[fileHash]) {
            return;
        }
        
        // storing the newly created application in the map.
        applications[appCount] = AppDetails(
            appCount,
            appName,
            appDesc,
            price,
            msg.sender,
            0,
            fileHash,
            new Application(
                appName,
                appDesc,
                price,
                msg.sender,
                filePtr,
                developerCut
            )
        );
        hashList[fileHash] = true;
        emit ApplicationAdded(appCount, appName, price, msg.sender);
        appCount += 1;
    }

    /// @notice Function to return all applications in the store
    function fetchAllApps() public view returns (AppDetails[] memory) {
        AppDetails[] memory items = new AppDetails[](appCount);
        for (uint256 i = 0; i < appCount; i++) {
            AppDetails memory currentItem = applications[i];
            items[i] = currentItem;
        }
        return items;
    }

    /// @notice Function to fetch details on all the apps on the store.
    /// @param itemId The itemId of the required app.
    /// @return Application The list of all apps with support.
    function fetchApp(uint256 itemId) public view returns (AppDetails memory) {
        return applications[itemId];
    }

    /// @notice Function to buy a listing and accepts the money to store in the contract
    /// @dev Triggers the event for logging
    /// @param itemId The item the buyer wants to buy
    function buyApp(uint256 itemId) external payable {
        // transferring the funds to the contract which deals with
        // the particular app.
        require(applications[itemId].price == msg.value, "Correct value provided");
        applications[itemId].applicationContract.buy.value(msg.value)(
                 msg.sender
             );
        applications[itemId].downloads += 1;
    }

    /// @notice Function to get the file pointer of the application
    /// @dev Should verify that the user calling the function has purchased the application
    /// @param itemId Id of the app that is being called
    /// @return Returns the application file pointer
    function getApplicationFile(uint256 itemId) public view returns (string memory) {
        if(checkPurchased(itemId, msg.sender)) {
            return applications[itemId].applicationContract.getFilePtr();
        }
    }

    /// @notice Verifies if the user has purchased required app.
    /// @param appId Id of the app which is being checked.
    /// @param user Address of the user that needs verification.
    /// @return If the user has purchased the app.
    function checkPurchased(uint256 appId, address user) public view returns (bool) {
        return applications[appId].applicationContract.checkPurchased(user);
    }

    /// @notice Transfers the owner of the purchased application
    /// @param itemId Id of the app which is being transferred
    /// @param newAddress new address of the user wanting to transfer the app
    function transferApplicationOwner(uint256 itemId, address payable newAddress) public payable {
        if(checkPurchased(itemId, msg.sender)) {
            applications[itemId].applicationContract.transferOwner(msg.sender, newAddress);
        }
    }

    /// @notice Function that clears the marketplace
    /// @dev Useful for testing
    function killStore() external {
        require(msg.sender == owner, "Only the owner can kill the marketplace");
        selfdestruct(owner);
    }
}
