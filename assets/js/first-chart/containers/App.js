import React, { Component } from 'react'
import GivingChart from '../Components/GivingChart'
import cx from 'classnames'
import { connect } from 'react-redux'

class App extends Component {

  state = {compare_last_year: false}

  toggleCompareLastYear = () => {
    this.setState({compare_last_year: !this.state.compare_last_year})
  }

  render() {
    return (
        <div className="card" style={{minHeight: '700px'}}>
          <div className="card-header">

            <h4 className="card-header-title">
              Giv5
            </h4>

            <span className="text-muted mr-3">
              Last year comparision:
            </span>

            <div className="custom-control custom-switch" onClick={this.toggleCompareLastYear}>
              <input readOnly={true} type="checkbox" className="custom-control-input" id="cardToggle" checked={this.state.compare_last_year}  />
              <label className="custom-control-label"></label>
            </div>

          </div>
          <div className="card-body">

            <GivingChart {...this.state} />

          </div>
        </div>

    );
  }
}

function mapStateToProps(state) {
  return {}
}

export default connect(mapStateToProps, { } )(App)
