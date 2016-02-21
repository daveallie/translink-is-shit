window.Translink = window.Translink || {}

Translink.init = function(rawData) {
  var chart

  var updateChartData = function() {
    d3.select("#chart svg").datum(Translink.Data.chartData()).transition().duration(500).call(chart)
    nv.utils.windowResize(chart.update)
  }

  Translink.Data.addData("Global", Translink.Data.convertFromRaw("Global", rawData))

  nv.addGraph(function() {
    chart = nv.models.lineWithFocusChart()

    chart.xAxis
      .tickFormat(Translink.Helpers.secondsToHoursMinutes)
    chart.x2Axis
      .tickFormat(Translink.Helpers.secondsToHoursMinutes)
      .axisLabel("Time of Day (HH:MM)")
      .tickValues(_.range(0, 86400, 3600));
    chart.yAxis
      .tickFormat(Translink.Helpers.secondsToMinutesSeconds)
      .axisLabel("Mintes Late (MM:SS)")
    chart.y2Axis
      .tickFormat(Translink.Helpers.secondsToMinutesSeconds)

    updateChartData()

    return chart
  })

  Translink.Chart = {
    addData: function(key, rawData) {
      Translink.Data.addData(key, Translink.Data.convertFromRaw(key, rawData))
      updateChartData()
    },
    resetData: function() {
      Translink.Data.removeAllRouteData()
      updateChartData()
    }
  }

  getNoCacheJSON("/routes.json", function (routes) {
    Translink.routes = routes;
    var existingRoutes = (getUrlParamValue("route_ids") || "").split(",")
    if (existingRoutes.length === 1 && existingRoutes[0] === "") {
      existingRoutes = []
    }
    _.each(existingRoutes, Translink.Data.checkAndAddRoute)
  })

  $("#search-btn").click(Translink.Handlers.searchBtnClick)
  $("#search").keyup(function(event){
    if(event.keyCode == 13){
      $("#search-btn").click()
    }
  })

  $("#clear-btn").click(Translink.Handlers.clearBtnClick)
}

Translink.Helpers = {
  secondsToHoursMinutes: function(seconds) {
    return Translink.Helpers.secondsToMinutesSeconds(seconds / 60)
  },

  secondsToMinutesSeconds: function(inSeconds) {
    var multi = 1;
    if (inSeconds < 0) {
      inSeconds *= -1;
      multi = -1;
    }

    var minutes = Math.floor(inSeconds / 60)
      , seconds = Math.round(inSeconds % 60)

    seconds = (seconds < 10 ? "0" : "") + seconds
    return (multi === -1 ? "-" : "") + minutes + ':' + seconds
  }
}

Translink.Data = (function () {
  var data = {}
  return {
    getData: function () {
      return data
    },
    addData: function (key, newData) {
      data[key] = newData
    },
    removeAllRouteData: function() {
      data = {Global: data['Global']}
    },
    chartData: function() {
      var keys = _(data).keys().filter(function(k) {return k !== 'Global'}).value()
      keys.unshift('Global')
      return _.map(keys, function(k) {return data[k]})
    },
    convertFromRaw: function (key, rawData) {
      var values = _.map(rawData, function (d) {
        return {x: d[0], y: d[1]}
      })

      return {
        key: key,
        values: values
      }
    },
    getRawRouteData: function (routeId, callback) {
      getNoCacheJSON("/route/" + routeId + ".json", callback)
    },
    checkAndAddRoute: function(routeId, callback) {
      if (_.includes(Translink.routes, routeId)) {
        Translink.Data.getRawRouteData(routeId, function(data) {
          Translink.Chart.addData(routeId, data)
        })
        if (_.isFunction(callback)) callback(routeId)
      } else {
        alert('There is no information for route '+routeId)
      }
    }
  }
})()

Translink.Handlers = {
  searchBtnClick: function() {
    var $search = $("#search")
      , routeId = $search.val()

    if (routeId !== "") {
      $search.val("")
      Translink.Data.checkAndAddRoute(routeId, Translink.Callbacks.updateUrlWithRoute)
    }
  },
  clearBtnClick: function() {
    Translink.Chart.resetData()
    removeUrlParam('route_ids')
  }
}

Translink.Callbacks = {
  updateUrlWithRoute: function(routeId) {
    routeId = encodeURI(routeId)
    var value = getUrlParamValue('route_ids')

    if (value) {
      if (!_.includes(value.split(','), routeId)) {
        value += ',' + routeId
      }
    } else {
      value = routeId
    }
    insertUrlParam('route_ids', value)
  }
}
