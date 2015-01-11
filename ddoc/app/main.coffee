module.exports = (componentName, __data) ->
  React = require 'lib/react'
  component = React.createFactory(require 'components/' + componentName)

  """
<!doctype html>

<head>
  <meta charset="utf-8">
  <link rel="stylesheet" href="//cdn.rawgit.com/picnicss/picnic/master/releases/v1.1.min.css">
  <link rel="stylesheet" href="/_ddoc/style.css">
  <link rel="stylesheet" href="//fonts.googleapis.com/css?family=Cookie|Noto+Sans">
  <title>doulas.club - gestante, ache sua doula</title>
  <script>
    (function(t,r,a,c,k){k=r.createElement('script');k.type='text/javascript';
    k.async=true;k.src=a;k.id='ma';r.getElementsByTagName('head')[0].appendChild(k);
    t.maq=[];t.mai=c;t.ma=function(){t.maq.push(arguments)};
    })(window,document,'http://spooner.alhur.es:5984/microanalytics/_design/microanalytics/_rewrite/tracker.js','b7nwbi38ahi6jk');

    ma('pageView');
  </script>
</head>

<body>
#{React.renderToString(component(__data))}
</body>

<script src="//rawgit.com/desandro/imagesloaded/b8465933e73bdbf689123c304d9d25986cdedfe1/imagesloaded.pkgd.min.js"></script>
<script src="//cdn.jsdelivr.net/masonry/3.1.5/masonry.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/curl/0.7.3/curl/curl.min.js"></script>
<script>
  curl.config({
    baseUrl: '/_ddoc',
    paths: {
      'lib/react': '//cdnjs.cloudflare.com/ajax/libs/react/0.12.2/react.js',
      'lib/superagent': '//cdn.jsdelivr.net/superagent/0.18.0/superagent.min.js',
      'lib/marked': '//cdnjs.cloudflare.com/ajax/libs/marked/0.3.2/marked.min.js'
    }
  })
  var __data = #{toJSON __data}
  curl(['lib/react', 'components/#{componentName}'], function (React, component) {
    component = React.createFactory(component)
    React.render(component(window.__data), document.body)
  })
</script>
  """
