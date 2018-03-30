$(document).on('turbolinks:load', function(){
  $("#up-type-choice #type_type_id").append('<option value="99" disabled>讓Khroma推薦！</option>');
  $("#up-hue-choice #hue_level_id").append('<option value="99" disabled>讓Khroma推薦！</option>');
  $("#down-type-choice #type_type_id").append('<option value="99" selected="selected">讓Khroma推薦！</option>');
  $("#down-hue-choice #hue_level_id").append('<option value="99" selected="selected">讓Khroma推薦！</option>');

  window.sr = ScrollReveal();

  sr.reveal('#question1, #type-choice-panel, #gender-choice',{origin:'bottom', duration: 2000, distance: '50px'});

  // $('#question1, #type-choice-panel, #gender-choice').fadeIn();

  $('#gender-choice .btn').on('click', function(){
    $.ajax({
      url: 'khroma/pop_choices',
      method: 'get',
      dataType: 'json',
      data: { gender_id: $(this).find('input').val()},
      success: function(data){
        $('#up-type-choice').html(data['typesUpHtml']);
        $('#down-type-choice').html(data['typesDownHtml']);
      }
    }).done(function(){
      $("#up-type-choice #type_type_id").append('<option value="99" disabled>讓Khroma推薦！</option>');
      $("#down-type-choice #type_type_id").append('<option value="99" selected="selected">讓Khroma推薦！</option>');
      }
    );   
  });

  $('#type-choice-panel').on('change', function(){
    // $(this, '#question1', '#gender-choice').css('transform', 'translateY(-200)');
    $('#question2').show();
    $('#hue-choice-panel').css('display', 'grid');
    sr.reveal('#question2, #hue-choice-panel',{origin:'bottom', duration: 2000, distance: '50px'});
    // $('#question2, #hue-choice-panel').fadeIn();
  });

  $('#hue-choice-panel').on('change', function(){
    $('#match-btn').css('display', 'grid');
    sr.reveal('#match-btn',{origin:'bottom', duration: 1000, distance: '50px'});
  });

  $('#kroma-index-match #match-btn').click(function(){

    $('#spinner-overlay').css('display', 'grid');

    $.ajax({
      url: 'khroma/match',
      method: 'get',
      dataType: 'json',
      data: { 
        up_type_id: $('#up-type-choice #type_type_id').val(),
        up_hue_level: $('#up-hue-choice #hue_level_id').val(),
        down_type_id: $('#down-type-choice #type_type_id').val(),
        down_hue_level: $('#down-hue-choice #hue_level_id').val()
      },
      success: function(data){
        $('#match-result-panel').html(data['productsMatchHtml']);
      }
    });
  });

  $(document).ajaxStop(function(){
    $('#spinner-overlay').hide();
  });

  $(document).on('click','.gender-btn', function(){
    $.ajax({
      url: '/khroma/navbar',
      method: 'get',
      dataType: 'json',
      data: { id: $(this).val() },
      success: function(data){
        $('#lower-nav').css('transform', 'translateY(0)');
        $('#lower-nav .container').html(data['html']);
      }
    });
  });

  $(document).on('click','.close-btn', function(){
    $('#lower-nav').css('transform', 'translateY(-100%)');
  });


  $('#match-result-panel').on('mouseenter', '.match-principle-lbl', function() {
      $(this).find('.match-principle-panel').show(0);
  }); 

  $('#match-result-panel').on('mouseleave', '.match-principle-lbl', function() {
      $(this).find('.match-principle-panel').hide(0);
  });

  $('#match-result-panel').on('click', '.match-right', function(){
    $(this).siblings('.match-left').prop('disabled', false);
    $(this).siblings('.show-item').eq(3).next().addClass('show-item');
    $(this).siblings('.show-item').eq(0).removeClass('show-item');
    if ($(this).siblings('.show-item').eq(3).is(':nth-last-child(2)') ){
      $(this).prop('disabled', true);
    }
  });

  $('#match-result-panel').on('click', '.match-left', function(){
    $(this).siblings('.match-right').prop('disabled', false);
    $(this).siblings('.show-item').eq(3).removeClass('show-item');
    $(this).siblings('.show-item').eq(0).prev().addClass('show-item');
    if ($(this).siblings('.show-item').eq(0).is(':nth-child(2)') ){
      $(this).prop('disabled', true);
    }
  });
});
