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


});
