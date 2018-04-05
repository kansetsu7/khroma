$(document).on('turbolinks:load', function(){

  $('.product-panel-lg').on('click', '.family-btn', function(){
    if ($('#product-family-panel').css('display') == 'block' ) {
      $('#product-family-panel').hide();
      $('.family-btn').html('查看相似商品');
    } else {
      $('#spinner-overlay').css('display', 'grid');
      var ProductId = $('.product-lg-left .product-img').attr('id');

      $.ajax({
      url:  ProductId + '/family',
      method: 'get',
      dataType: 'json',
      success: function(data){
        $('.product-family-items').html('');
        $('#product-family-panel').show();
        $('.product-family-items').html(data['familyHtml']);
        $('.family-btn').html('關閉相似商品');
      }
      }).done(function(){
        $('.carousel-family').not('.slick-initialized').slick({
          dots: true,
          infinite: false,
          speed: 300,
          slidesToShow: 4,
          slidesToScroll: 4,
          responsive: [
            {
              breakpoint: 1024,
              settings: {
                slidesToShow: 3,
                slidesToScroll: 3,
                infinite: true,
                dots: true
              }
            },
            {
              breakpoint: 800,
              settings: {
                slidesToShow: 2,
                slidesToScroll: 2
              }
            },
            {
              breakpoint: 480,
              settings: {
                slidesToShow: 1,
                slidesToScroll: 1
              }
            }
          ]
        });
      });
    }
    
  });

  $('#product-match #match-btn').click(function(){
    $('#product-family-panel').hide();

    var up_type_id;
    var up_hue_level;
    var down_type_id;
    var down_hue_level;

    if ($('.product-info-lg .up-type').length == 0) {
      up_type_id = "99";
      up_hue_level = "99";
      down_type_id = $('.product-info-lg .product-title').attr('id');
      down_hue_level = $('.product-info-lg .product-color-panel .color-locked .product-color span').attr('id');
    } else {
      up_type_id = $('.product-info-lg .product-title').attr('id');
      up_hue_level = $('.product-info-lg .product-color-panel .color-locked .product-color span').attr('id');
      down_type_id = "99";
      down_hue_level = "99";
    }

    $('#spinner-overlay').css('display', 'grid');
    
    
    $.ajax({
      url: '/khroma/match',
      method: 'get',
      dataType: 'json',
      data: { 
        up_type_id: up_type_id,
        up_hue_level: up_hue_level,
        down_type_id: down_type_id,
        down_hue_level: down_hue_level
      },
      success: function(data){
        $('#match-result-panel').html(data['productsMatchHtml']);
      }
    }).done(function(){
      $('#product-match-result').show();
      $('.match-principle-pill:first-of-type .color-panel').addClass('active');

       $('.carousel').slick({
        centerMode: true,
        slidesToShow: 1,
        responsive: [
          {
            breakpoint: 768,
            settings: {
              arrows: true,
            }
          },
          {
            breakpoint: 590,
            settings: {
              arrows: false,
            }
          },
          {
            breakpoint: 425,
            settings: {
              arrows: false,
            }
          },
          {
            breakpoint: 320,
            settings: {
              arrows: false,
            }
          }
        ]
      });
    }).done(function(){
      $('html, body').animate({
        scrollTop: $('#match-result-panel').offset().top
      }, 500);
      return false;
    });
  });

  $('#product-match-result #match-result-panel').on('click', '.match-principle-pill', function(){
    $('#spinner-overlay').css('display', 'grid');

    var up_type_id;
    var up_hue_level;
    var down_type_id;
    var down_hue_level;
    var principle_color_id = $(this).find('.color-panel').attr('id');

    if ($('.product-info-lg .up-type').length == 0) {
      up_type_id = "99";
      up_hue_level = "99";
      down_type_id = $('.product-info-lg .product-title').attr('id');
      down_hue_level = $('.product-info-lg .product-color-panel .color-locked .product-color span').attr('id');
    } else {
      up_type_id = $('.product-info-lg .product-title').attr('id');
      up_hue_level = $('.product-info-lg .product-color-panel .color-locked .product-color span').attr('id');
      down_type_id = "99";
      down_hue_level = "99";
    }

    $.ajax({
      url: '/khroma/match',
      method: 'get',
      dataType: 'json',
      data: { 
        up_type_id: up_type_id,
        up_hue_level: up_hue_level,
        down_type_id: down_type_id,
        down_hue_level: down_hue_level,
        principle_color_id: principle_color_id
      },
      success: function(data){
        $('#match-result-panel').html(data['productsMatchHtml']);
      }
    }).done(function(){
      $('.match-principle-pill.active').removeClass('active');
      $('.match-principle-pill .color-panel#' + principle_color_id).addClass('active');
       $('.carousel').slick({
        centerMode: true,
        slidesToShow: 1,
        responsive: [
          {
            breakpoint: 768,
            settings: {
              arrows: true,
            }
          },
          {
            breakpoint: 590,
            settings: {
              arrows: false,
            }
          },
          {
            breakpoint: 425,
            settings: {
              arrows: false,
            }
          },
          {
            breakpoint: 320,
            settings: {
              arrows: false,
            }
          }
        ]
      });
    }).done(function(){
      $('html, body').animate({
        scrollTop: $('#match-result-panel').offset().top
      }, 500);
      return false;
    });
  });

});