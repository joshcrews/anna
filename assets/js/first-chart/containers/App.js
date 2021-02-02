import React, { Component } from 'react'

import cx from 'classnames'
import { connect } from 'react-redux'

class App extends Component {


  render() {
    return (
        <div className="card" style="min-height: 700px;">
          <div className="card-header">

            <h4 className="card-header-title">
              Giving
            </h4>

            <span className="text-muted mr-3">
              Last year comparision:
            </span>

            <div className="custom-control custom-switch">
              <input type="checkbox" className="custom-control-input" id="cardToggle"  />
              <label className="custom-control-label" for="cardToggle"></label>
            </div>

          </div>
          <div className="card-body">

            <div className="chart">
              <canvas id="conversionsChart" className="chart-canvas"></canvas>
            </div>

          </div>
        </div>

    );
  }
}

function mapStateToProps(state) {
  return {}
}

export default connect(mapStateToProps, { } )(App)
