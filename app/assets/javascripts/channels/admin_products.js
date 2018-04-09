$(document).on('turbolinks:load', function(){
  $('#get-color').click(function(){
    var chip_url = $('#product_color_chip').val();
    $.ajax({
      url: '/admin/products/get_chip_colors',
      method: 'get',
      dataType: 'json',
      data: { 
        color_chip_url: $('#product_color_chip').val(),
      },
      success: function(data){
        $('#color-info-panel').html(data['colorInfoHtml']);
      },      
      error: function() {
      }
    }).done(function(){
      var img_url = document.querySelector("#color-info-panel img").src
      var chip_input = document.getElementById("product_color_chip");
      console.log(img_url)
      chip_input.value = img_url
    });

  });
});

function changeColorColumn() {
  var radios = document.querySelectorAll("[type='radio']");
  var selects = document.querySelectorAll("select");
  for (var i = 0; i < radios.length; i++) {
    if (radios[i].checked) {
      selects[i].disabled = false;
    } else {
      selects[i].disabled = true;
    }
  }
}