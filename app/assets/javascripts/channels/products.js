$(document).on('turbolinks:load', function(){

  $('#product-match #match-btn').click(function(){
    var up_type_id;
    var up_hue_level;
    var down_type_id;
    var down_hue_level;

    if ($('.product-info-lg .up-type').length == 0) {
      up_type_id = "";
      up_hue_level = "";
      down_type_id = $('.product-info-lg .product-title').attr('id');
      down_hue_level = $('.product-info-lg .product-color-panel .color-locked .product-color span').attr('id');
    } else {
      up_type_id = $('.product-info-lg .product-title').attr('id');
      up_hue_level = $('.product-info-lg .product-color-panel .color-locked .product-color span').attr('id');
      down_type_id = "";
      down_hue_level = "";
    }
    
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
    });
  });

});