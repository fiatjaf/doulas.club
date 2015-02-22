module.exports = (componentName, doc, req) ->
  React = require 'lib/react'
  component = React.createFactory(require 'components/' + componentName)

  baseTitle = 'doulas.club'

  if doc and doc.nome
    data = doc
    meta =
      title: doc.nome + ' | ' + baseTitle
      description: doc.cidade + ". " + if doc.tel or doc.email then [].concat(doc.tel).concat(doc.email).join(', ') + (if doc.intro then ' - ' + doc.intro else '') else if doc.intro then doc.intro.replace(/"/g, "'") else 'Informações e contatos da doula ' + doc.nome + ', de ' + doc.cidade + '.'
  else
    data = {}
    data.query = req.query
    meta =
      title: if req.query and req.query.q then \
               req.query.q + ' | pesquisa ' + baseTitle \
             else \
               baseTitle + ' - mais de 800 doulas em todas as regiões do Brasil'
      description: 'Todas as doulas, todas as regiões.'

  data.baseTitle = baseTitle

  """
<!doctype html>

<head>
  <meta charset="utf-8">
  <meta name=viewport content="width=device-width, initial-scale=1">
  <link rel="search" type="application/opensearchdescription+xml" href="/_ddoc/opensearch.xml" title="doulas.club">
  <link rel="stylesheet" href="//cdn.rawgit.com/picnicss/picnic/master/releases/v1.1.min.css">
  <link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Cookie|Noto+Sans">
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

<script>
  require = {
    baseUrl: '/_ddoc',
    paths: {
      'lib': '/_ddoc/lib',
      'components': '/_ddoc/components',
      'lib/react': [
        '//cdnjs.cloudflare.com/ajax/libs/react/0.12.2/react-with-addons',
        'lib/react'
       ],
      'lib/superagent': [
        '//cdn.jsdelivr.net/superagent/0.18.0/superagent.min',
        'lib/superagent'
       ],
      'lib/marked': [
        '//cdnjs.cloudflare.com/ajax/libs/marked/0.3.2/marked.min',
        'lib/marked'
       ],
      'masonry': [
        '//cdn.jsdelivr.net/masonry/3.1.5/masonry.min',
        'lib/masonry'
       ],
      'imagesloaded': [
        '//rawgit.com/desandro/imagesloaded/b8465933e73bdbf689123c304d9d25986cdedfe1/imagesloaded.pkgd.min',
        'lib/imagesloaded'
       ],
    }
  }
  </script>
  <script src="https://login.persona.org/include.js"></script>
  <script src="//cdnjs.cloudflare.com/ajax/libs/require.js/2.1.15/require.min.js"></script>
  <script>
  var __data = #{toJSON data}
  requirejs([
    'lib/react', 'components/#{componentName}',
  ], function (React, component) {
    component = React.createFactory(component)
    React.render(component(window.__data), document.body)
  })
  window.mobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
</script>
  """
