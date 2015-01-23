module.exports = (componentName, doc, req) ->
  React = require 'lib/react'
  component = React.createFactory(require 'components/' + componentName)

  if doc and doc.nome
    data = doc
    meta =
      title: doc.nome + ' | doulas.club'
      description: if doc.intro then doc.intro.replace(/"/g, "'") else 'Informações e contatos da doula ' + doc.nome + ', de ' + doc.cidade + '.'
  else
    data = {}
    data.query = req.query
    meta =
      title: 'gestante, ache sua doula | doulas.club'
      description: 'Todas as doulas, todas as regiões.'

  """
<!doctype html>

<head>
  <meta charset="utf-8">
  <meta name=viewport content="width=device-width, initial-scale=1">
  <link rel="search" type="application/opensearchdescription+xml" href="/_ddoc/opensearch.xml" title="doulas.club">
  <link rel="stylesheet" href="//cdn.rawgit.com/picnicss/picnic/master/releases/v1.1.min.css">
  <link rel="stylesheet" href="/_ddoc/style.css">
  <title>#{meta.title}</title>
  <meta name="description" content="#{meta.description}">
  <script>
    (function(t,r,a,c,k){k=r.createElement('script');k.type='text/javascript';
    k.async=true;k.src=a;k.id='ma';r.getElementsByTagName('head')[0].appendChild(k);
    t.maq=[];t.mai=c;t.ma=function(){t.maq.push(arguments)};
    })(window,document,'http://spooner.alhur.es:5984/microanalytics/_design/microanalytics/_rewrite/tracker.js','b7nwbi38ahi6jk');

    ma('pageView');
  </script>
</head>

<body>
#{React.renderToString(component(data))}
</body>

<script src="//cdnjs.cloudflare.com/ajax/libs/require.js/2.1.15/require.min.js"></script>
<script>
  requirejs.config({
    baseUrl: '/_ddoc',
    paths: {
      'lib': '/_ddoc/lib',
      'components': '/_ddoc/components',
      'lib/react': '//cdnjs.cloudflare.com/ajax/libs/react/0.12.2/react-with-addons',
      'lib/superagent': '//cdn.jsdelivr.net/superagent/0.18.0/superagent.min',
      'lib/marked': '//cdnjs.cloudflare.com/ajax/libs/marked/0.3.2/marked.min',
      'masonry': '//cdn.jsdelivr.net/masonry/3.1.5/masonry.min',
      'imagesloaded': '//rawgit.com/desandro/imagesloaded/b8465933e73bdbf689123c304d9d25986cdedfe1/imagesloaded.pkgd.min',
    }
  })
  var __data = #{toJSON data}
  requirejs([
    'lib/react', 'components/#{componentName}',
  ], function (React, component) {
    component = React.createFactory(component)
    React.render(component(window.__data), document.body)
  })
  window.mobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
</script>
<script type="text/javascript">
  WebFontConfig = {
    google: { families: [ 'Cookie::latin', 'Noto-Sans::latin' ] }
  };
  (function() {
    var wf = document.createElement('script');
    wf.src = ('https:' == document.location.protocol ? 'https' : 'http') +
      '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js';
    wf.type = 'text/javascript';
    wf.async = 'true';
    var s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(wf, s);
  })();
</script>
  """
