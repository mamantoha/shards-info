- if message = env.flash["notice"]?
  .container
    .alert.alert-success.alert-dismissible.fade.mt-3.show role="alert"
      i.fas.fa-info-circle
      = message
      button.btn-close type="button" data-bs-dismiss="alert" aria-label="Close"
