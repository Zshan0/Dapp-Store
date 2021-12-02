import React from "react";
import Container from "react-bootstrap/Container";
import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import Table from "react-bootstrap/Table";
import EthCrypto from "eth-crypto";
import ReactLoading from 'react-loading';
import Web3 from "web3";

class Dashboard extends React.Component {

    render() {
        const { loading } = this.state;
        // Check if page is loading or not
        if (this.state.loading) {
          return <ReactLoading height={667} width={375} />;
        }
        else {
            return(
                <div> Dashboard</div>
            );
        }

    }

}

export default Dashboard;