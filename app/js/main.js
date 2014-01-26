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
      $searchReveal = $('[data-search-reveal]'),
      $searchBox = $('[data-search-box]'),
      fadeSpeed = 200;


      // Fade out button, fade in add project instructions
      $addProject.on('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        $modalTarp.fadeIn(fadeSpeed);
        $projectModal.fadeIn(fadeSpeed);
      });

      // Fade out project instruction, fade in button
      $cancelProject.on('click', function(e) {
        e.preventDefault();
        $modalTarp.fadeOut(fadeSpeed);
        $projectModal.fadeOut(fadeSpeed);
      });

      $('body').on('click', function(e) {
        if ($modalTarp.is(':visible')) {
          if ($(e.target).is('.modal-tarp')) {
            $modalTarp.fadeOut(fadeSpeed);
            $projectModal.fadeOut(fadeSpeed);
          }
        }
      });

      // Fade out project instruction, fade in button
      $searchReveal.on('click', function(e) {
        e.preventDefault();
        $searchBox.addClass('activated');
        setTimeout(function() {
          $searchBox.focus();
        }, fadeSpeed);
      });

      $searchBox.blur(function() {
        $searchBox.removeClass('activated');
      });

      // Esc functions
      $(document).keyup(function(e) {
        if ($searchBox.hasClass('activated')) {
          if (e.keyCode == 27) { // esc
            $searchBox.removeClass('activated').blur();
          }
        } else if ($modalTarp.is(':visible')) {
          if (e.keyCode == 27) { // esc
            $modalTarp.fadeOut(fadeSpeed);
            $projectModal.fadeOut(fadeSpeed);
          }
        }
      });

});
