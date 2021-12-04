const Store = artifacts.require("Store");
const Application = artifacts.require("Application");
const { soliditySha3 } = require("web3-utils");

contract("DappStore", (accounts) => {
  let dappStore;

  const newApplication = {
    name: "Test Application",
    description: "This is a sample description",
    price: 5,
    filePtr: "BitTorrent Pointer",
    developerCut: 4,
    encFileData: soliditySha3("Sample file data")
  };

  beforeEach(async () => {
      dappStore = await Store.new({from: accounts[0]});
  });

  afterEach(async () => {
      await dappStore.killStore({from: accounts[0]});
  });


  it("Checks if the store is running", async () => {

    await dappStore.createAppListing(
        newApplication.name,
        newApplication.description,
        newApplication.price,
        newApplication.filePtr,
        newApplication.developerCut,
        newApplication.encFileData,
        { from: accounts[1]}
    );
    
    const listings = await dappStore.fetchAllApps();
    assert.equal(newApplication.name, listings[0].appName);
    assert.equal(newApplication.description, listings[0].appDesc);
    assert.equal(newApplication.price, listings[0].price);
  });

  it("Checks if applications are being created", async () => {

    for(let i=0;i<3;i++)
    {
      await dappStore.createAppListing(
        newApplication.name,
        newApplication.description,
        newApplication.price,
        newApplication.filePtr,
        newApplication.developerCut,
        soliditySha3("test"+i),
        { from: accounts[i]}
    );
    }
    
    const listings = await dappStore.fetchAllApps();
    assert.equal(listings.length, 3);
    const listing = await dappStore.fetchApp(2);
    assert.equal(newApplication.name, listing.appName);
    assert.equal(newApplication.description, listing.appDesc);
    assert.equal(newApplication.price, listing.price);
    assert.equal(soliditySha3("test2"),listing.fileHash)
  });


  it("Checks if application isn't being created by overwriting torrent hash", async () => {
    const newApplication2 = {
      name: "Test Application 2",
      description: "This is a sample description 2",
      price: 10,
      filePtr: "BitTorrent Pointer 2",
      developerCut: 9,
      encFileData: soliditySha3("Sample file data")
    };

    await dappStore.createAppListing(
        newApplication.name,
        newApplication.description,
        newApplication.price,
        newApplication.filePtr,
        newApplication.developerCut,
        newApplication.encFileData,
        { from: accounts[1]}
    );
    await dappStore.createAppListing(
      newApplication2.name,
      newApplication2.description,
      newApplication2.price,
      newApplication2.filePtr,
      newApplication2.developerCut,
      newApplication2.encFileData,
      { from: accounts[2]}
  );
    
    const listings = await dappStore.fetchAllApps();
    assert.equal(listings.length, 1);
    assert.equal(newApplication.name, listings[0].appName);
    assert.equal(newApplication.description, listings[0].appDesc);
    assert.equal(newApplication.price, listings[0].price);
  });

  it("Checks if applications can be bought", async () => {

    await dappStore.createAppListing(
        newApplication.name,
        newApplication.description,
        newApplication.price,
        newApplication.filePtr,
        newApplication.developerCut,
        newApplication.encFileData,
        { from: accounts[1]}
    );
    
    const listings = await dappStore.fetchAllApps();
    assert.equal(newApplication.name, listings[0].appName);
    assert.equal(newApplication.description, listings[0].appDesc);
    assert.equal(newApplication.price, listings[0].price);

    await dappStore.buyApp(0, {
      from: accounts[2],
      value: newApplication.price
    });
    const filePtr = await dappStore.getApplicationFile(0,{
      from: accounts[2]
    });
    assert.equal(filePtr, newApplication.filePtr);
    const listing = await dappStore.fetchApp(0);
    assert.equal(listing.appName, newApplication.name);
    assert.equal(listing.downloads,1);
  });

  it("Checks if purchase occurs for correct amount only", async () => {

    await dappStore.createAppListing(
        newApplication.name,
        newApplication.description,
        newApplication.price,
        newApplication.filePtr,
        newApplication.developerCut,
        newApplication.encFileData,
        { from: accounts[1]}
    );
    
    const listings = await dappStore.fetchAllApps();
    assert.equal(newApplication.name, listings[0].appName);
    assert.equal(newApplication.description, listings[0].appDesc);
    assert.equal(newApplication.price, listings[0].price);

    try {
      await dappStore.buyApp(0, {
        from: accounts[2],
        value: newApplication.price + 1
      });
      throw error;
    } catch(error) {
      assert(error, "Expected an error but did not get one");
      assert(
        error.message.startsWith(
          "Returned error: VM Exception while processing transaction: revert Incorrect value provided"
        ),
        "Expected an error 'Incorrect value provided' but got '" +
          error.message +
          "' instead"
      );
    }
  });

  it("Checks if applications can be transferred", async () => {

    await dappStore.createAppListing(
        newApplication.name,
        newApplication.description,
        newApplication.price,
        newApplication.filePtr,
        newApplication.developerCut,
        newApplication.encFileData,
        { from: accounts[1]}
    );
    
    const listings = await dappStore.fetchAllApps();
    assert.equal(newApplication.name, listings[0].appName);
    assert.equal(newApplication.description, listings[0].appDesc);
    assert.equal(newApplication.price, listings[0].price);

    await dappStore.buyApp(0, {
      from: accounts[2],
      value: newApplication.price
    });
    const filePtr = await dappStore.getApplicationFile(0,{
      from: accounts[2]
    });
    assert.equal(filePtr, newApplication.filePtr);
    const listing = await dappStore.fetchApp(0);
    assert.equal(listing.appName, newApplication.name);
    assert.equal(listing.downloads,1);

    await dappStore.transferApplicationOwner(0,accounts[3], {
        from: accounts[2]
      });
    const oldAddress = await dappStore.checkPurchased(0, accounts[2]);
    const newAddress = await dappStore.checkPurchased(0, accounts[3]);
    assert.equal(oldAddress,false);
    assert.equal(newAddress,true);  
  });

});
