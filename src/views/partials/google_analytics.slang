/! Global site tag (gtag.js) - Google Analytics
script async="async" src="https://www.googletagmanager.com/gtag/js?id=#{ENV["GOOGLE_ANALYTICS_ID"]}""
javascript:
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', '#{ENV["GOOGLE_ANALYTICS_ID"]}');
