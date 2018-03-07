$(document).ready(function(){
  $('#gender_gender_id').on('change', function(){ 
    $.ajax({
      url: 'khroma/pop_choices',
      method: 'get',
      dataType: 'json',
      data: { gender_id: $(this).val()},
      success: function(data){
        $('#up-type-choice').html(data['typesUpHtml']);
        $('#down-type-choice').html(data['typesDownHtml']);
      }
    });
  });

  $('#match-btn').on('click', function(){
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

        $('#up-result').html(data['productsUpMatchHtml']);
        console.log(data['productsUpMatchHtml']);
        $('#down-result').html(data['productsDownMatchHtml']);
        console.log(data['productsDownMatchHtml']);
      }
    });
  });
});
