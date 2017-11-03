// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require_tree .
//
this.successModal = function(titleOrBody, body, setup) {
  var title;
  title = body ? titleOrBody : (body = titleOrBody, "Success");
  setupContentModal(function($contentModal) {
    $contentModal.find('.modal-content').addClass('modal-content-success');
    $contentModal.find('.modal-body').addClass('centered');
    if (setup) {
      return setup($contentModal);
    }
  });
  return showContentModal({
    title: title,
    body: body,
    footer: $("<button class='btn btn-default' data-dismiss='modal'>OK</button>")
  });
};

this.errorModal = function(body, options) {
  if (typeof options !== 'object') {
    options = {};
  }
  options.title || (options.title = 'Error');
  options.body || (options.body = body);
  options.footer || (options.footer = $('<button class="btn btn-danger" data-dismiss="modal">OK</button>'));
  setupContentModal(function($contentModal) {
    $contentModal.find('.modal-content').addClass('modal-content-error');
    return $contentModal.find('.modal-body').addClass('centered');
  });
  return showContentModal(options);
};
