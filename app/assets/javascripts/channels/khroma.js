$(document).on('turbolinks:load', function(){
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
    });
  });

  $('#match-btn').on('click', function(){
    console.log('hi');
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
        $('#result').html(data['productsMatchHtml']);
      }
    });
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
});
