$(document).on('turbolinks:load', function(){

  $("#q2-choice-panel #type_type_id").append('<option value="99">讓Khroma推薦！</option>');

  window.sr = ScrollReveal();
  sr.reveal('#question1, #gender-choice, #category-choice',{origin:'bottom', duration: 500, distance: '50px'});
  // 首頁開頭動畫設定

  $('#category-choice .btn').click(function(){
    $.ajax({
      url: 'khroma/pop_category_choices',
      method: 'get',
      dataType: 'json',
      data: { 
        gender_id: $('#gender-choice').find('.active').find('input').val(),
        up_or_down: $(this).find('input').val()
      },
      success: function(data){
        $('#q1-choice-panel').html(data['q1Html']);
        $('#q2-choice-panel').html(data['q2Html']);

      }
    }).done(function(){
      $('#q1-choice-panel').css('display', 'grid');
      $("#q2-choice-panel #type_type_id").append('<option value="99">讓Khroma推薦！</option>');
      sr.reveal('#q1-choice-panel',{origin:'bottom', duration: 500, distance: '50px'});
    });  
  }); // 上下身按鈕換selector內容

  $('#gender-choice .btn').on('click', function(){
    $.ajax({
      url: 'khroma/pop_gender_choices',
      method: 'get',
      dataType: 'json',
      data: { gender_id: $(this).find('input').val()},
      success: function(data){
        $('#up-type-choice').html(data['typesUpHtml']);
        $('#down-type-choice').html(data['typesDownHtml']);
      },
    }).done(function(){
      $('.selectpicker').selectpicker();
      $("#q2-choice-panel #type_type_id").append('<option value="99">讓Khroma推薦！</option>');
      });   
  }); // 男女按鈕換selector內容

  
  $('#q1-choice-panel').on('click', '.mm-dropdown .textfirst', function(){
    var li = $('.mm-dropdown > ul > li.input-option');
    li.toggle('fast');
  }); // Color selector animation

  $('#q1-choice-panel').on('click', '.mm-dropdown > ul > li.input-option', function(){
    var main = $('.mm-dropdown .textfirst');
    var inputoption = $(".mm-dropdown .option");
    var li = $('.mm-dropdown > ul > li.input-option');

    li.toggle('fast');
    var livalue = $(this).data('value');
    var lihtml = $(this).html();
    main.html(lihtml);
    inputoption.val(livalue);

    $('#question2').show();
    $('#q2-choice-panel').css('display', 'grid');
    sr.reveal('#question2, #q2-choice-panel',{origin:'bottom', duration: 500, distance: '50px'});
  }); // 選完q1 show q2內容

  $('#q2-choice-panel').on('change', 'span', function(){
    $('#match-btn').css('display', 'grid');
    sr.reveal('#match-btn',{origin:'bottom', duration: 500, distance: '50px'});
  }); // 選完q2 show match btn

  $('#kroma-index-match #match-btn').click(function(){
    $('.error-msg').html('');
    $('#spinner-overlay').css('display', 'grid');
    
    var up_hue_level;
    var down_hue_level;

    if (typeof $('#up-hue-choice #hue_level_id').val() == 'undefined') {
      up_hue_level = "99";
      down_hue_level = $('#down-hue-choice #hue_level_id').val();
    } else if (typeof $('#down-hue-choice #hue_level_id').val() == 'undefined') {
      down_hue_level = "99";
      up_hue_level = $('#up-hue-choice #hue_level_id').val();
    }
    $.ajax({
      url: 'khroma/match',
      method: 'get',
      dataType: 'json',
      data: { 
        up_type_id: $('#up-type-choice #type_type_id').val(),
        up_hue_level: up_hue_level,
        down_type_id: $('#down-type-choice #type_type_id').val(),
        down_hue_level: down_hue_level
      },
      success: function(data){
        $('#match-result-panel').html(data['productsMatchHtml']);
      },      
      error: function() {
        $('#kroma-index-match .error-msg').append('<p class="text-center" style=" color: var(--yellow)">選單皆為必填</p>');
      }
    }).done(function(){
      $('#promote').hide();
      $('#match-result').show();
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
        scrollTop: $('#match-result').offset().top
      }, 500);
      return false;
    });
  }); //match btn ajax 配對內容

  $('#match-result #match-result-panel').on('click', '.match-principle-pill', function(){
    $('#spinner-overlay').css('display', 'grid');

    var up_hue_level;
    var down_hue_level;
    var principle_color_id = $(this).find('.color-panel').attr('id');

    if (typeof $('#up-hue-choice #hue_level_id').val() == 'undefined') {
      up_hue_level = "99";
      down_hue_level = $('#down-hue-choice #hue_level_id').val();
    } else if (typeof $('#down-hue-choice #hue_level_id').val() == 'undefined') {
      down_hue_level = "99";
      up_hue_level = $('#up-hue-choice #hue_level_id').val();
    }

    $.ajax({
      url: 'khroma/match',
      method: 'get',
      dataType: 'json',
      data: { 
        up_type_id: $('#up-type-choice #type_type_id').val(),
        up_hue_level: up_hue_level,
        down_type_id: $('#down-type-choice #type_type_id').val(),
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
        scrollTop: $('#match-result').offset().top
      }, 500);
      return false;
    });
  }); //principle pills ajax 配對內容

  $(document).ajaxStop(function(){
    $('#spinner-overlay').hide();
  }); // loading spinner 隱藏


  if ($(window).width() > 790 ) {
    $('#match-result-panel').on('mouseenter', '.match-principle-pill', function() {
      $(this).find('.match-principle-panel').css('display', 'grid');
    }); // principle pills hover show配色法則圖

    $('#match-result-panel').on('mouseleave', '.match-principle-pill', function() {
      $(this).find('.match-principle-panel').css('display', 'none');
    }); // principle pills hover hide配色法則圖
  }
  
  $('#match-result #match-result-panel, #product-match-result').on('mouseleave', '.slick-current .product-img ', function() {
      $(this).find('.product-match-overlay-1').css('transform', 'translateY(50px)');
      $(this).find('.product-match-overlay-2').css('transform', 'translateY(144px)');
  }); // 配對商品hover hide view detail
});