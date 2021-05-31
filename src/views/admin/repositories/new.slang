.container
  form action="/admin/repositories" method="post"
    div.mb-3
      label for="inputUrl" class="form-label"
        | URL
      input.form-control#inputUrl aria-describedby="urlHelp" name="repository[url]" required="required"
      .form-text#urlHelp
        | Enter full path to Github/Gitlab repository
    button.btn.btn-primary type="submit"
      | Submit
