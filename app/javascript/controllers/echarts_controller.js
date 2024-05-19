import { Controller } from "@hotwired/stimulus"

import * as echarts from "echarts";

// Connects to data-controller="echarts"
export default class extends Controller {
  connect() {
    this.renderChart();
  }

  renderChart() {
    const chartData = JSON.parse(this.element.dataset.echartsChart);
    const chartType = this.element.dataset.echartsType;
    
    const chart = echarts.init(this.element);
    
    const option = {
      title: {
        text: chartData.title
      },
      xAxis: {
        type: 'category',
        data: chartData.categories
      },
      yAxis: {
        type: 'value'
      },
      series: [{
        data: chartData.data,
        type: chartType
      }]
    };
    
    chart.setOption(option);
  }   
}
