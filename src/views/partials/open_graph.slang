- open_graph = env.get("request_context").as(RequestContext).open_graph

meta property="og:site_name" content=open_graph.site_name
meta property="og:type" content=open_graph.type
meta property="og:title" content=open_graph.title
meta property="og:description" content=open_graph.description
meta property="og:image" content=open_graph.image
meta property="og:url" content=open_graph.url
