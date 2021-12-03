import React from "react";
import Carousel from 'react-bootstrap/Carousel';
import ReactLoading from 'react-loading';
import '../css/Home.css'

class Home extends React.Component {

    render() {
        const { loading } = this.state;
        // Check if page is loading or not
        if (this.state.loading) {
          return <ReactLoading height={667} width={375} />;
        }
        else {
            return(
                <div> Home</div>
            );
        }

    }

}

export default Home;