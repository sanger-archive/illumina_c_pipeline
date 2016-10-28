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

  // function lastMetadatum(metadata){
  //   metadata.childNodes().count() == 1
  // }


  function remove(){
    $(this).parent().parent().remove()
  };

  $(".add_metadatum").on("click", add);
  $(".remove_metadatum").on("click", remove);

});