.container
  div.mt-3
    nav aria-label="breadcrumb"
      ol.breadcrumb
        li.breadcrumb-item
          a href="/admin" Admin
        li.breadcrumb-item.active aria-current="page" New repository
  form action="/admin/repositories" method="post"
    div.mb-3
      label for="inputUrl" class="form-label"
        | URL
      input.form-control#inputUrl aria-describedby="urlHelp" name="repository[url]" required="required"
      .form-text#urlHelp
        | Enter full path to Github/Gitlab repository
    button.btn.btn-primary type="submit"
      | Submit
