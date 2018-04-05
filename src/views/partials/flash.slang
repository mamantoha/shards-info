- if flash = env.flash["notice"]?
  div class="alert alert-primary alert-dismissible fade show" role="alert"
    == flash
    button type="button" class="close" data-dismiss="alert" aria-label="Close"
      span aria-hidden="true" ×
