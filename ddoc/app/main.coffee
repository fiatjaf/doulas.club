module.exports = (componentName, doc, req) ->
  React = require 'lib/react'
  component = React.createFactory(require 'components/' + componentName)

  baseTitle = 'doulas.club'
  if req.query.place
    req.query.q = req.query.place

  if doc and doc.nome
    data = doc
    description = doc.cidade + ". \n" + if doc.tel or doc.email then [].concat(doc.tel).concat(doc.email).join(', ') + (if doc.intro then '\n - ' + doc.intro else '') else if doc.intro then doc.intro.replace(/"/g, "'") else '\nInformações e contatos da doula ' + doc.nome + ', de ' + doc.cidade + '.'

    if doc._attachments
      data._foto = if Object.keys(doc._attachments).length then "http://doulas.club/#{doc._id}/#{Object.keys(doc._attachments)[0]}" else null
    else
      data._foto = null

    meta =
      title: doc.nome + ' | ' + baseTitle
      description: description
      og:
        url: 'http://doulas.club/' + doc._id
        title: 'Perfil da doula ' + doc.nome
        site_name: 'doulas.club'
        description: description
        image: data._foto
        type: 'profile'
        
  else
    data = {}
    data.query = req.query
    searchqueryTitle = null
    prefixdescription = ''
    if req.query and req.query.q
      if req.query.place
        searchqueryTitle = 'Doulas em ' + req.query.q + ' e região | ' + baseTitle
        prefixdescription = 'A mais completa coletânea de doulas na região de ' + req.query.q + '. '
      else
        searchqueryTitle = req.query.q + ' | pesquisa ' + baseTitle
    description = 'A doula perfeita para você e para o seu bebê está aqui!'

    meta =
      title: searchqueryTitle or baseTitle + ' - mais de 800 doulas em todas as regiões do Brasil'
      description: (prefixdescription or 'A mais completa coleção de perfis, informações e contatos das doulas brasileiras. ') + description
      og:
        url: 'http://doulas.club/'
        title: searchqueryTitle or 'Encontre a sua doula ideal no doulas.club!'
        site_name: 'doulas.club'
        description: (prefixdescription or 'São mais de 800 doulas em todas as regiões do Brasil. ') + description
        image: 'http://doulas.club/favicon.ico'
        type: 'website'

  data.baseTitle = baseTitle
  data.colors = {
    'GAMA': '993300'
    'ANDO': '0079B2'
    'Cais do Parto': 'E1B643'
    'Instituto Cândida Vargas': '8F8C87'
    'Naoli Vinaver': '503B9D'
  }

  """
<!doctype html>

<head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# profile: http://ogp.me/ns/profile#">
  <meta charset="utf-8">
  <meta name=viewport content="width=device-width, initial-scale=1">
  <link rel="search" type="application/opensearchdescription+xml" href="/_ddoc/opensearch.xml" title="doulas.club">
  <link rel="stylesheet" href="/_ddoc/style.css">
  <title>#{meta.title}</title>
  <meta name="description" content="#{meta.description}">
  #{("<meta property=\"og:#{k}\" content=\"#{v}\">" for k, v of meta.og when v).join('\n  ')}
  #{"<meta property=\"fb:profile_id\" content=\"#{data.facebook}\">" if data.facebook}
  <meta property="og:locale" content="pt_BR">
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
  colors = #{toJSON(data.colors)}

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
        'lib/imagesloaded',
        '//rawgit.com/desandro/imagesloaded/b8465933e73bdbf689123c304d9d25986cdedfe1/imagesloaded.pkgd.min'
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
