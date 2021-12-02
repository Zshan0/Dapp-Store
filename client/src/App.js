import React, { Component } from "react";
import { BrowserRouter as Router, Route } from "react-router-dom";
import ReactLoading from 'react-loading';
import './css/App.css';

import CreateApplication from "./components/CreateApplication";
import Dashboard from "./components/Dashboard";
import DappStore from "./components/DappStore";
import Home from "./components/Home";
import Navigation from "./components/Navigation";


import ApplicationABI from "./contracts/Application.json";
import StoreABI from "./contracts/Store.json";
import getWeb3 from "./getWeb3";


class App extends Component {
  state = { storageValue: 0, web3: null, accounts: null, contract: null };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the application contract instance.
      const networkId = await web3.eth.net.getId();
      const applicationNetwork = ApplicationABI.networks[networkId];
      const applicationInstance = new web3.eth.Contract(
        ApplicationABI.abi,
        applicationNetwork && applicationNetwork.address
      );
      // Get the store contract instance.
      const storeNetwork = StoreABI.networks[networkId];
      const storeInstance = new web3.eth.Contract(
        StoreABI.abi,
        storeNetwork && storeNetwork.address
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({
        web3,
        accounts,
        contract: {
          application : applicationInstance,
          store: storeInstance,
        },
      });
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  render() {
    // Check if web3 has been loaded or not
    if (!this.state.web3) {
      return <ReactLoading height={667} width={375} />;
    }

    // Return router-dom and default page, and forward contracts and accounts as parameters to auction pages
    return (
      <Router className="">
        <Navigation />
          <Route path="/" exact component={Home} />
          <Route
            path="/dashboard"
            exact
            render={() => (
              <Dashboard
                contracts={this.state.contract}
                accounts={this.state.accounts}
              />
            )}
          />
          <Route
            path="/dappstore"
            exact
            render={() => (
              <DappStore
                contracts={this.state.contract}
                accounts={this.state.accounts}
              />
            )}
          />
          <Route
            path="/create-application"
            exact
            render={() => (
              <CreateApplication
                contracts={this.state.contract}
                accounts={this.state.accounts}
              />
            )}
          />
      </Router>
    );
  }
}

export default App;
