(function() {
  "use strict"
  var root = this,
      $ = root.jQuery;

  if (typeof root.GOVUK === 'undefined') {
    root.GOVUK = {};
  }

  var Mappings = {

    toggles: function() {

      $('tr').on('change', '.js-check', function() {
        console.log('click');
        $(this).parents('tr').toggleClass('selected-row');
      });

      $('.js-check-all').on('click', function() {
        $('tbody .js-check').attr('checked', function(idx, oldAttr) {
            return !oldAttr;
        }).trigger('change');
      });

    },

    editAll: function() {
      var forms = $('.js-edit-mapping-form');

      forms.each(function() {
        GOVUK.Mappings.edit($(this));
      });
    },

    edit: function(form) {

      var httpStatus = form.find('.js-http-status'),
          httpStatusWrapper = form.find('.js-http-status-wrapper'),
          archiveFields = form.find('.js-for-archive'),
          redirectFields = form.find('.js-for-redirect');

      if (httpStatusWrapper.length > 0) {

        httpStatusWrapper.on('click', '.btn', function() {
          setTimeout(function() {
            toggleFormFieldsets("" + httpStatusWrapper.find(".btn.active").data('value'));
          }, 50);
        });

        toggleFormFieldsets("" + httpStatusWrapper.find(".btn.active").data('value'));

        /*
        httpStatusWrapper.on('change', 'input', function() {
          toggleFormFieldsets(httpStatusWrapper.find("input[type='radio']:checked").val());
        });

        toggleFormFieldsets(httpStatusWrapper.find("input[type='radio']:checked").val());
        */

      } else {

        httpStatus.on('change', function() {
          toggleFormFieldsets(httpStatus.val());
        });

        toggleFormFieldsets(httpStatus.val());
      }

      form.find('[data-module="toggle"]').each(function() {
        GOVUK.Mappings.toggle($(this));
      });

      function toggleFormFieldsets(selectedHTTPStatus) {

        console.log('here', selectedHTTPStatus);

        switch (selectedHTTPStatus) {

          case '301':
            redirectFields.show();
            archiveFields.hide();
            redirectFields.find('input').first().focus();
            break;

          case '410':
            redirectFields.hide();
            archiveFields.show();
            break;

          default:
            redirectFields.show();
            archiveFields.show();
            break;
        }
      }
    },

    toggle: function(element) {
      element.on('click', '.js-toggle', toggle);
      element.on('click', '.js-cancel', cancel);

      function toggle(event) {
        element.find('.js-toggle-target').toggleClass('if-js-hide');
        element.find('input').first().focus();
        event.preventDefault();
      }

      function cancel(event) {
        toggle(event);
        element.find('input').first().val('');
      }
    }

  };

  root.GOVUK.Mappings = Mappings;
}).call(this);
