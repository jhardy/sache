$(function() {

    $("#submit-form").submit(function(event) {

        event.preventDefault();

        var $form = $(this),
            actionURL = $form.attr('action'),
            formData = $form.serialize();

        console.log($form);
        console.log(actionURL);
        console.log(formData);

        $.ajax({
            url: actionURL,
            type: "POST",
            data: formData,
            beforeSend: function() {
                $form.addClass('processing')
            },
            complete: function(jqXHR, status) {
                console.log(jqXHR, status)
                console.log(jqXHR.responseText);
                $form.removeClass('processing')
            },
            success: function(e) { console.log("success: " + e)

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


      // Fade out button, fade in add project instructions
      $addProject.on('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        $modalTarp.fadeIn(fadeSpeed);
        $projectModal.addClass('modal-open');
        // $projectModal.fadeIn(fadeSpeed);
      });

      // Fade out project instruction, fade in button
      $cancelProject.on('click', function(e) {
        e.preventDefault();
        $modalTarp.fadeOut(fadeSpeed);
        $projectModal.removeClass('modal-open');
        // $projectModal.fadeOut(fadeSpeed);
      });

      $('body').on('click', function(e) {
        if ($modalTarp.is(':visible')) {
          if ($(e.target).is('.modal-tarp')) {
            $modalTarp.fadeOut(fadeSpeed);
            $projectModal.fadeOut(fadeSpeed);
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
