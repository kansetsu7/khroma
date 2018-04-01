$(document).on('turbolinks:load', function(){

  $('#product-match #match-btn').click(function(){
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
        centerPadding: '60px',
        slidesToShow: 1,
        responsive: [
          {
            breakpoint: 768,
            settings: {
              arrows: false,
              centerMode: true,
              centerPadding: '40px',
              slidesToShow: 1
            }
          },
          {
            breakpoint: 480,
            settings: {
              arrows: false,
              centerMode: true,
              centerPadding: '40px',
              slidesToShow: 1
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

  $('#match-result-panel').on('click', '.match-principle-pill', function(){
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
        centerPadding: '60px',
        slidesToShow: 1,
        responsive: [
          {
            breakpoint: 768,
            settings: {
              arrows: false,
              centerMode: true,
              centerPadding: '40px',
              slidesToShow: 1
            }
          },
          {
            breakpoint: 480,
            settings: {
              arrows: false,
              centerMode: true,
              centerPadding: '40px',
              slidesToShow: 1
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