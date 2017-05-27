$(function () {
  $('#container').highcharts({
      title: {
        text: null
      },
      yAxis: {
        title: {
          text: null
        }
      },
      credits: {
        enabled: false
      },
      exporting: {
        enabled: false
      },
      plotOptions: {
        series: {
          turboThreshold: 0
        },
        treemap: {
          layoutAlgorithm: "squarified"
        },
        bubble: {
          minSize: 5,
          maxSize: 25
        }
      },
      annotationsOptions: {
        enabledButtons: false
      },
      tooltip: {
        delayForDisplay: 10
      },
      series: [
        {
          group: "group",
          data: [
            {
              x: 102,
              y: 55
            },
            {
              x: 71,
              y: 98
            },
            {
              x: 48,
              y: 79
            },
            {
              x: 52,
              y: 68
            },
            {
              x: 5,
              y: 61
            },
            {
              x: 40,
              y: 86
            },
            {
              x: 88,
              y: 64
            },
            {
              x: 80,
              y: 92
            },
            {
              x: 82,
              y: 97
            },
            {
              x: 31,
              y: 24
            }
          ],
          type: "scatter"
        }
      ]
    }
  );
});
