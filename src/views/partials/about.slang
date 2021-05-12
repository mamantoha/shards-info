/! Modal
#aboutModal.modal.fade aria-hidden="true" aria-labelledby="aboutModalLabel" role="dialog" tabindex="-1"
  .modal-dialog role="document"
    .modal-content
      .modal-header
        h5#aboutModalLabel.modal-title About
        button.btn-close type="button" data-bs-dismiss="modal" aria-label="Close"
      .modal-body
        p
          | View of all repositories on Github and Gitlab that have Crystal code in them.
        ul
          li
            | Build with:
            ul
              li
                a href="https://crystal-lang.org" Crystal
                = Crystal::VERSION
              li
                a href="https://kemalcr.com/" Kemal
                = Kemal::VERSION
              li
                a href="https://github.com/anykeyh/clear" Clear
                = Clear::VERSION
          li
            | Build date #{Time.parse_rfc2822(Config.date).to_s("%Y-%m-%d %H:%M:%S %:z")}
          li
            | Official code repository is on
            a href="https://github.com/mamantoha/shards-info" Github
          li
            | Developed and maintained by
            a href="mailto:anton.maminov@gmail.com" Anton Maminov
        .px-4.mt-3
          | We hope that this site will encourage you to start your own Crystal projects!
        .px-4.mt-3
          | Happy Crystalling ♥
