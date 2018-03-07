$(document).ready(function(){
  $('#gender_gender_id').on('change', function(){ 
    $.ajax({
      url: 'khroma/pop_choices',
      method: 'get',
      dataType: 'json',
      data: { gender_id: $(this).val()},
      success: function(data){
        $('#top-type-choice').html(data['typesTopHtml']);
        $('#bottom-type-choice').html(data['typesBottomHtml']);
      }
    });
  });

  $('#match-btn').on('click', function(){
    $.ajax({
      url: 'khroma/match',
      method: 'get',
      dataType: 'json',
      data: { 
        top_type_id: $('#top-type-choice #type_type_id').val(),
        top_rough_color: $('#top-hue-choice #rough_color').val(),
        bottom_type_id: $('#bottom-type-choice #type_type_id').val(),
        bottom_rough_color: $('#bottom-hue-choice #rough_color').val()
      },
      success: function(data){
        $('#top-result').html(data['productsTopMatchHtml']);
        $('#bottom-result').html(data['productsBottomMatchHtml']);
      }
    });
  });
});