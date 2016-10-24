$(document).ready(function() {

  var id = $(".metadata").children().length;

  function add(){
      $(this).prev().clone()
          .find("input:text").val("").end()
          .insertBefore(this)
          .attr("id", "metadatum" +  id)
          .on('click', '.remove_metadatum', remove);
      id++
  };

  function remove(){
      console.log("here")
      $(this).parent().parent().remove()
  };

  $(".add_metadatum").on("click", add);
  $(".remove_metadatum").on("click", remove);

});