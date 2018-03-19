// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require jquery
//= require jquery_ujs
//= require popper
//= require bootstrap-sprockets
//= require_tree .

$(document).on('turbolinks:load', function() {
  var timeout;
  $('#user-center-lbl').hover(function() {
    clearTimeout(timeout);
      $('#menu-user-panel').show(0);
    }, function() {
      timeout = setTimeout(function() {
        $('#menu-user-panel').hide(0);
      }, 300);
  });

  $(document).on('click', '.close-btn', function(){
    console.log('hi')
    $('.sign-overlay').hide();
  });

  $('#go-top-btn a').click(function(){
    $('html, body').animate({
        scrollTop: $( $(this).attr('href') ).offset().top
    }, 500);
    return false;
  });

  $('.type-pills-panel a').click(function(){
    $('html, body').animate({
        scrollTop: $( $(this).attr('href') ).offset().top
    }, 500);
    return false;
  });
});
