// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require lodash
//= require d3
//= require nv.d3
//= require_tree .

function getNoCacheJSON(url, successCallback, errorCallback) {
  errorCallback = errorCallback || _.noop
  $.ajax({
    cache: false,
    url: url,
    dataType: "json",
    success: successCallback,
    error: errorCallback
  });
}

function getUrlParamValue(key) {
  key = encodeURI(key)

  var kvp = document.location.search.substr(1).split('&')
    , i = kvp.length
    , x

  while(i--) {
    x = kvp[i].split('=');
    if (x[0] == key) {
      return x[1]
    }
  }
}

function insertUrlParam(key, value) {
  if (_.isNil(value)) {
    return removeUrlParam(key)
  }

  key = encodeURI(key)
  value = encodeURI(value)

  var kvp = document.location.search.substr(1).split('&')
    , i = kvp.length
    , x

  if (i === 1 && kvp[0] === "") {
    kvp = []
    i = 0
  }

  while(i--) {
    x = kvp[i].split('=');

    if (x[0] == key) {
      x[1] = value
      kvp[i] = x.join('=')
      break
    }
  }

  if (i < 0) {
    kvp[kvp.length] = [key, value].join('=')
  }

  window.history.pushState({}, document.title, window.location.pathname + '?' + kvp.join('&'))
}

function removeUrlParam(key) {
  key = encodeURI(key)

  var kvp = document.location.search.substr(1).split('&')
    , i = kvp.length
    , x
    , newUrl

  if (i === kvp.length && kvp[0] === "") {
    kvp = []
    i = 0
  }

  while(i--) {
    x = kvp[i].split('=');

    if (x[0] == key) {
      kvp.splice(i, 1)
      break
    }
  }

  if (kvp.length > 0) {
    newUrl = window.location.pathname + '?' + kvp.join('&')
  } else {
    newUrl = window.location.pathname
  }

  window.history.pushState({}, document.title, newUrl)
}
