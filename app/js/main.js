$(function() {


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
              $form.addClass('processing');
              console.log($form.find(".button"))
              $form.find(".button").attr('disabled', true);
          },
          complete: function(jqXHR, status) {
              console.log(jqXHR, status)
              console.log(jqXHR.responseText);
              $form.removeClass('processing');
              $form.find(".button").removeAttr('disabled', false);
          },
          success: function(e) {
            window.location.reload(true);
          },
          error: function(jqXHR, textStatus, errorThrown) {
              console.log("jqXHR: ", jqXHR);
              console.log("textStatus: ", textStatus);
              console.log("errorThrown: ", errorThrown);
              //console.log("error: " + textStatus.responseText)
          }
       });
 
  });


  var $addProject = $('[data-add-project]'),
    $modalTarp = $('.modal-tarp'),
    $projectModal = $('.add-project'),
    $cancelProject = $('[data-cancel-project]'),
    fadeSpeed = 200;

  var closeModal = function() {
    $modalTarp.fadeOut(fadeSpeed);
    $projectModal.removeClass('modal-open');
  }

  // Fade out button, fade in add project instructions
  $addProject.on('click', function(e) {
    e.preventDefault();
    e.stopPropagation();
    $modalTarp.fadeIn(fadeSpeed);
    $projectModal.addClass('modal-open');
  });

  // Fade out project instruction, fade in button
  $cancelProject.on('click', function(e) {
    e.preventDefault();
    closeModal();
  });

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
        $modalTarp.fadeOut(fadeSpeed);
        $projectModal.fadeOut(fadeSpeed);
      }
    }
  });

});
