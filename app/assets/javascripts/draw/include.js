//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require d3
//= require html2canvas
//= require screen-grabber
//= require ../sankey

function getParameterByName(name, url) {
  if (!url) url = window.location.href;
  name = name.replace(/[\[\]]/g, "\\$&");
  var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)", "i"),
      results = regex.exec(url);
  if (!results) return null;
  if (!results[2]) return '';
  return decodeURIComponent(results[2].replace(/\+/g, " "));
}

var getDataHeaderKey = function(data, header) {
  return data["header_keys"][header];
}