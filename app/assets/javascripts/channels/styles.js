$(document).on('turbolinks:load', function(){

  $('.product-color-panel a').click(function(){
    $(this).parent().children('a').removeClass('color-unlocked');
    $(this).parent().children('a').removeClass('color-locked');
    $(this).addClass('color-locked');
  });
});