// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require jquery
//= require jquery_ujs
//= require popper
//= require bootstrap-sprockets
//= require bootstrap-select
//= require bootstrap/alert
//= require bootstrap/dropdown
//= require_tree .
//= require jquery.slick
//= require javascript/scrollreveal.min.js

$(document).on('turbolinks:click', function() {
   $('#spinner-overlay').css('display', 'grid');
}); // 讀取時loading spinner 開啟

$(document).on('turbolinks:load', function() {
  $('#spinner-overlay').hide(); // 讀取畫面完成loading spinnder 關閉 
  
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
  }); // navbar 按下men woment btn 後 show lower nav

  $(document).on('click','.close-btn', function(){
    $('#lower-nav').css('transform', 'translateY(-100%)');
  }); // X鈕按下關閉lower nav

  $('[data-sr-id]').removeAttr('data-sr-id').removeAttr('style'); //去除按上一頁後 srollreveal讀取失敗的bug

  var timeout;
  $('#user-center-lbl').hover(function() {
    clearTimeout(timeout);
      $('#menu-user-panel').show(0);
    }, function() {
      timeout = setTimeout(function() {
        $('#menu-user-panel').hide(0);
      }, 300);
  }); // 會員中心hover秀出選單內容

  $(document).on('click', '.close-btn', function(){
    $('.sign-overlay').hide();
  }); // X按下關閉登入註冊等畫面

  $(document).scroll(function() {
    var y = $(this).scrollTop();
    if (y > 800) {
      $('#go-top-btn').fadeIn();
    } else {
      $('#go-top-btn').fadeOut();
    }
  }); // go top btn scroll Y大小於800px時出現或消失

  $('#go-top-btn a').click(function(){
    $('html, body').animate({
        scrollTop: $( $(this).attr('href') ).offset().top
    }, 500);
    return false;
  }); // go top btn 按下回到最頂端

  $('.type-pills-panel a').click(function(){
    $('html, body').animate({
        scrollTop: $( $(this).attr('href') ).offset().top
    }, 500);
    return false;
  }); // types pills 按下滑至相對應內容
});