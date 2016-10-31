$(document).ready(function() {

  var id = $(".metadata").children().length+1;

  function add(){
      $('#metadatum-template').clone()
          .insertBefore(this)
          .attr("id", "metadatum" +  id)
          .on('click', '.remove_metadatum', remove)
          .find('input').attr('required', 'true');

      id++
  };

  function remove(){
      $(this).parent().parent().remove()
  };

  function keysDuplicated(){
      var stored  =   [];
      var inputs  =   $('input[id^="metadata__key"');
      var keysDup = false;

      $.each(inputs,function(k,v){
          var getVal  =   $(v).val();
          if(stored.indexOf(getVal) != -1){
              $(v).parent().css('border-color','red');
              keysDup = true;
          }else{
              $(v).parent().css('border-color','#aaa');
              stored.push($(v).val());
          };
      });
      return keysDup
  };

  $('#metadata-form').submit(function(){
      var keysDup = keysDuplicated();
      if (keysDup) {
          return false
      };
  });

  $(".add_metadatum").on("click", add);
  $(".remove_metadatum").on("click", remove);

});