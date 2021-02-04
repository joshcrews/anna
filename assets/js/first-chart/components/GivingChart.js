import React, { PureComponent } from "react";
import Chart from "chart.js";


export default class GivingChart extends PureComponent {
  chartRef = React.createRef();

  componentDidUpdate() {
    console.log('this.props.compare_last_year', this.props.compare_last_year)
    if(this.props.compare_last_year) {
      this.state.chart.data.datasets.forEach((dataset) => {
        if(!dataset.this_year) {
          dataset.hidden = false
        }
      });
    } else {
      this.state.chart.data.datasets.forEach((dataset) => {
        if(!dataset.this_year) {
          dataset.hidden = true
        }
      });
    }

    this.state.chart.update();
  }

  componentDidMount() {
    this.buildChart();
  }

  buildChart = () => {
    const givingChartRef = this.chartRef.current.getContext("2d");

    const chart = new Chart(givingChartRef, {
      type: "bar",
      data: {
              labels: ['Oct 1', 'Oct 2', 'Oct 3', 'Oct 4', 'Oct 5', 'Oct 6', 'Oct 7', 'Oct 8', 'Oct 9', 'Oct 10', 'Oct 11', 'Oct 12'],
              datasets: [{
                label: '2020',
                data: [25, 20, 30, 22, 17, 10, 18, 26, 28, 26, 20, 32],
                this_year: true,
              }, {
                label: '2019',
                data: [15, 10, 20, 12, 7, 0, 8, 16, 18, 16, 10, 22],
                backgroundColor: '#d2ddec',
                hidden: true,
                this_year: false,
              }]
            },

      // Configuration options go here
      options: {
        legend: {
          display: false,
        },
      },
    });

    this.setState({ chart: chart });
  };

  render() {

    return (
          <div>
            <canvas id="givingChart" ref={this.chartRef} />
          </div>
    );
  }
}
