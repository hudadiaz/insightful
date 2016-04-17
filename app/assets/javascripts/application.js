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
//= require jquery.turbolinks
//= require jquery_ujs
//= require selectize
//= require bootstrap
//= require bootstrap-material-design
//= require nprogress
//= require nprogress-turbolinks
//= require d3
//= require_directory .
//= require turbolinks

$(document).ready(function () {
  $.material.init();
  // $(".select").dropdown({ "autoinit" : ".select" });

  setTimeout(function() {
    $(".alert.alert-dismissible").fadeOut();
  }, 7000);
});

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
