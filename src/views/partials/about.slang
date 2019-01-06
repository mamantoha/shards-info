/! Modal
#aboutModal.modal.fade aria-hidden="true" aria-labelledby="aboutModalLabel" role="dialog" tabindex="-1"
  .modal-dialog role="document"
    .modal-content
      .modal-header
        h5#aboutModalLabel.modal-title About
        button.close aria-label="Close" data-dismiss="modal" type="button"
          span aria-hidden="true" == "&times;"
      .modal-body
        ul
          li
            | Build with Crystal #{Crystal::VERSION}
          li
            | Build date #{Config.config.build_time.to_s("%Y-%m-%d %H:%M:%S %:z")}
          li
            | Official code repository is on
            a href="https://github.com/mamantoha/shards-info" GitHub
          li
            | Developed and maintained by
            a href="mailto:anton.maminov@gmail.com" Anton Maminov
