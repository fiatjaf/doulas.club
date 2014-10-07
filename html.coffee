React = require 'react'
FrozenHead = require 'react-frozenhead'

{html, body, meta, script, link, title} = React.DOM

module.exports = React.createClass
  render: ->
    (html {},
      (FrozenHead {},
        (meta charSet: 'utf-8')
        (link rel: 'stylesheet', href: 'http://cdn.rawgit.com/picnicss/picnic/master/releases/v1.1.min.css')
        (link rel: 'stylesheet', href: '/assets/style.css')
        (link rel: 'stylesheet', href: 'http://fonts.googleapis.com/css?family=Cookie|Noto+Sans')
        (script src: 'http://rawgit.com/desandro/imagesloaded/b8465933e73bdbf689123c304d9d25986cdedfe1/imagesloaded.pkgd.min.js')
        (script src: 'http://cdn.jsdelivr.net/masonry/3.1.5/masonry.min.js')
        (title {},
          if @props.data and @props.data.nome then @props.data.nome + ' | doulas.club'
          else 'doulas.club - gestante, ache sua doula'
        )
      )

      (body {}, @props.body)

      (script src: '/assets/bundle.js')
      #(script
      #  dangerouslySetInnerHTML:
      #    __html: '''
      #  (function(t,r,a,c,k){k=r.createElement('script');k.type='text/javascript';
      #  k.async=true;k.src=a;r.getElementsByTagName('head')[0].appendChild(k);
      #  t.maq=[];t.mai=c;t.ma=function(){t.maq.push(arguments)};
      #  })(window,document,'http://static.microanalytics.alhur.es/tracker.js','b7nwbi38ahi6jk');

      #  ma('pageView');
      #    '''
      #)
    )
