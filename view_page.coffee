cookie = require './cookie'

isString = (obj) -> toString.call(obj) == "[object #{name}]"

fontsLoaded = false

resize = ->
  return unless fontsLoaded
  $('.fittext').fitText('clear').fitText()
  fullscreenOverlay.fit()
  $sections = $('.sections')
  $window = $(window)
  $html = $('html')
  if $sections.outerHeight() > $window.height()
    $html.addClass('scroll').removeClass('noscroll')
  else
    $html.removeClass('scroll').addClass('noscroll')

  # this is unfortunately duplicated in app/previews/base.coffee
  $placeholders = $('.placeholder')
  $placeholders.each (i, el) ->
    $el = $ el
    width = $el.width()
    #size = parseInt(width/4, 10)
    size = 60
    size = 30 if width < 60*3
    $el.css 'font-size', "#{size}px"

pww = null
pwh = null
ppw = null
pph = null

detectChange = ->
  $window = $ window
  ww = $window.width()
  wh = $window.height()

  $sections = $ '.sections'
  pw = $sections.width()
  ph = $sections.height()

  changed = pww != ww or pwh != wh or ppw != pw or pph != ph

  pww = ww
  pwh = wh
  ppw = pw
  pph = ph

  changed

poll = ->
  setTimeout ->
    resize() if detectChange()
    poll()
  , 100

keydown = (e) ->
  if e.which == 27
    return if fullscreenOverlay.hide()

setupPreviewNotification = ->
  return unless $('meta[content=noindex]').length # preview only

  css = """
  .bar {
    display: none;

    position: fixed;
    z-index: 1000;
    top: 0;
    left: 0;
    right: 0;
  }

  .with-bar .bar {
    display: -webkit-flex;
    display: -moz-flex;
    display: -ms-flexbox;
    display: -ms-flex;
    display: flex;
  }

  .bar-button {
    font-family: "roboto condensed", "helevetica neue", arial, sans-serif;
    font-size: 13px;
    line-height: 20px;
    color: #333;
    padding: 4px 8px;
    margin: 0;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
  }

  .bar-button a {
    color: #222;
    text-decoration: underline;
  }

  .bar-button,
  .bar-spacer {
    background-color: #ffc;
    height: 28px;
    position: relative;
    box-sizing: border-box;
    -moz-box-sizing: border-box;
  }

  .bar-button:after,
  .bar-spacer:after {
    content: '';
    position: absolute;
    left: 0;
    right: 0;
    bottom: -4px;
    border-bottom: 4px solid rgba(0, 0, 0, 0.1);
  }

  button.bar-button {
    border: none;
    cursor: pointer;
  }

  .bar-button i {
    line-height: 23px;
  }

  .bar-spacer {
    -webkit-flex: 1;
    -moz-flex: 1;
    -ms-flex: 1;
    flex: 1;
  }

  * + .bar-button {
    margin-left: 1px;
  }
  """

  $title = $ 'title'
  version = $title.data('version')
  title = $title.html()
  editURL = $('link[rel=edit]').attr('href') ? '#'

  $html = $ 'html'
  $html.addClass('with-bar')
  $style = $ '<style>'+css+'</style>'
  $html.find('head').append($style)
  $bar = $ '<div class="bar"></div>'

  $remove = $ '<button class="bar-button remove-bar"></button>'
  $remove.html '<i class="ss-delete"></i>'

  $version = $ '<div class="bar-button">You are viewing version '+
                version+' of </div>'
  $edit = $ '<a href="'+editURL+'">'+title+'</a>'
  $version.append $edit
  $version.append '.'

  $bar.append $version
  $version.addClass 'bar-spacer'
  $bar.append $remove

  $('body').prepend($bar)

  $('body > .bar .remove-bar').click ->
    $html.removeClass 'with-bar'
    $('body > .bar').remove()
    resize()

module.exports.init = (options) ->
  # keep original referrer and query string for analytics
  unless cookie.get('referrer')? and cookie.get('query')?
    cookie.set 'referrer', document.referrer
    cookie.set 'query', location.search

  $(document).keydown keydown

  $('[data-embed]').click (e) ->
    return unless e.which == 1 # skip anything except left click
    return if e.ctrlKey or e.metaKey # skip ctrl-click or cmd-click

    e.preventDefault()

    fullscreenOverlay.show $(e.currentTarget).data('embed')

  setupPreviewNotification()

  # load fonts
  if options.families.length
    WebFont.load
      google:
        families: options.families
      active: ->
        fontsLoaded = true
        resize()
        setTimeout ->
          resize()
        , 1000

  else
    # resize immediately, because no fonts have to load
    fontsLoaded = true
    resize()

  poll()

