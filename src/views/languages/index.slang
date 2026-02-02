== render "src/views/partials/subnav.slang"
div
  h1.page__heading
    .container.text-center
      .h1
        ' Languages
      .h6.font-weight-light
        ' Browse languages on shards.info

div#languages data-languages="#{languages_json}"
#languages-cloud

javascript:
  $(function() {
    languages = $("#languages").data("languages");
    window.renderWordCloud('#languages-cloud', languages, {
      autoResize: true,
      fontSize: {
        from: 0.04,
        to: 0.01
      }
    });
  });
