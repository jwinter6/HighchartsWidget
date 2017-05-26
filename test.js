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
              x: 15,
              y: 60
            },
            {
              x: 39,
              y: 103
            },
            {
              x: 81,
              y: 51
            },
            {
              x: 18,
              y: 96
            },
            {
              x: 2,
              y: 43
            },
            {
              x: 10,
              y: 31
            },
            {
              x: 88,
              y: 91
            },
            {
              x: 38,
              y: 99
            },
            {
              x: 58,
              y: 57
            },
            {
              x: 0,
              y: 89
            }
          ],
          type: "scatter"
        }
      ]
    }
  );
});
