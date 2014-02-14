$(function() {

  var $responseBar = $(".response-bar");

  $("#submit-form").submit(function(event) {

      event.preventDefault();

      var $form = $(this),
          actionURL = $form.attr('action'),
          formData = $form.serialize();


      $.ajax({
          url: actionURL,
          type: "POST",
          data: formData,
          beforeSend: function() {
              $responseBar.removeClass('show')
              $form.addClass('processing');
              $form.find(".button").attr('disabled', true);
          },
          complete: function(jqXHR, status) {
              $responseBar.find('.response-text').html(jqXHR.responseText);
              $responseBar.addClass('show');

              console.log("complete")
              console.log("jqxr: ", jqXHR, " , status: ", status)
              console.log('responseText: ', jqXHR.responseText);
              $form.removeClass('processing');
              $form.find(".button").removeAttr('disabled', false);

          },
          success: function(e) {
            $responseBar.removeClass('error').addClass('success');
            //console.log("success")
            if(window.location.pathname === "/") {
              $("#main").load("/ #main");
            }

          },
          error: function(jqXHR, textStatus, errorThrown) {
              $responseBar.removeClass('success').addClass('error');
          }
       });
  });


  var $addProject = $('[data-add-project]'),
    $modalTarp = $('.modal-tarp'),
    $projectModal = $('.add-project'),
    $cancelProject = $('[data-cancel-project]'),
    $sachesearch = $('.sache-search input'),
    fadeSpeed = 200;


  // Close modaal method
  var closeModal = function() {
    $modalTarp.fadeOut(fadeSpeed);
    $projectModal.removeClass('modal-open');
    $('body').css('position','static');
    $responseBar.removeClass('show');
  }

  // Fade in add project instructions
  $addProject.on('click', function(e) {
    e.preventDefault();
    e.stopPropagation();
    $modalTarp.fadeIn(fadeSpeed);
    $projectModal.addClass('modal-open');
    if ($(window).width() < 768) {
      $('body').css('position','fixed');
    }
  });

  // Fade out project instruction
  $cancelProject.on('click', function(e) {
    e.preventDefault();
    closeModal();
  });


  // Handle clicking outside of elements
  $('body').on('click', function(e) {
    if ($modalTarp.is(':visible')) {
      if ($(e.target).is('.modal-tarp')) {
        closeModal();
      }
    }
  });

  // Esc functions
  $(document).keyup(function(e) {
    if ($modalTarp.is(':visible')) {
      if (e.keyCode == 27) { // esc
        closeModal();
      }
    }
  });

  // Sortability
  $("#main").on('click', 'th a', function() {

    var el = $(this),
        data = {sort: el.data('sort'), direction: el.data('direction')};

        $.ajax({
          url: '/',
          data: data,
          success: function(data) {
            var table = $(data).find(".extensions")
            $("#main").html(table);
          }
        });
  });

});
