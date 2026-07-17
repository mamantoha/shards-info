== render "src/views/partials/subnav.slang"
div
  h1.page__heading
    .container.text-center
      .h1
        ' Tags
      .h6.font-weight-light
        ' Browse popular tags on shards.info

div#tags data-tags="#{tags_json}"
#tags-cloud
