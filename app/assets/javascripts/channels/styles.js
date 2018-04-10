$(window).on("scroll", debounce(function(){
  if (($(window).height() + $(window).scrollTop()) >= $(document).height()-100) {
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
})); // infinite scroll debounce設定

$(document).on('turbolinks:load', function(){
  $('.product-color-panel a').on('click', function(){
    $(this).parent().children('a').removeClass('color-unlocked');
    $(this).parent().children('a').removeClass('color-locked');
    $(this).addClass('color-locked');
  });

  $(document).on('mouseenter', '.product-cart .following-state', function(){
    $(this).css('color', 'var(--red)');
    $(this).html('移出收藏品');
  });

   $(document).on('mouseleave', '.product-cart .following-state', function(){
    $(this).css('color', 'var(--info)');
    $(this).html('已加入收藏');
  });
}); // 加入收藏商品按鈕之 ajax

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
} // lodash debounce function https://lodash.com/docs/4.17.5#debounce