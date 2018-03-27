$(window).on("scroll", debounce(function(){
  if (($(window).height() + $(window).scrollTop()) >= $(document).height()) {

    var nextSelector = $('nav.pagination a[rel=next]').attr('href');
    if ( typeof nextSelector === 'undefined') {
      $('#styles-spinner').html('<em>沒有更多商品</em>')
      return
    }

    $.ajax({
      url: nextSelector,
      method: 'GET',
      dataType: 'json',
      success: function(data) {
        $('.styles-panel').append(data['html']);
        $('nav.pagination').replaceWith(data['paginateHtml']);  
      }
    });
  }
}));

$(document).on('turbolinks:load', function(){
  $('.product-color-panel a').on('click', function(){
    $(this).parent().children('a').removeClass('color-unlocked');
    $(this).parent().children('a').removeClass('color-locked');
    $(this).addClass('color-locked');
  });
});


// lodash debounce function https://lodash.com/docs/4.17.5#debounce

function debounce(func, wait = 500, immediate = false) {
  var timeout;
  return function() {
      var context = this,
          args = arguments;
      var later = function() {
          timeout = null;
          if (!immediate) func.apply(context, args);
      }
      var callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) func.apply(context, args);
  }
}