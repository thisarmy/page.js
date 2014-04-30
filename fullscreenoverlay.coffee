getScaleInfo = (cw, ch, iw, ih) ->
  ws = cw/iw
  hs = ch/ih
  s = Math.min(ws, hs)

  w = iw*s
  h = ih*s

  hw = w/2
  hh = h/2

  return {
    scale: s
    width: parseInt(w, 10)
    height: parseInt(h, 10)
    halfWidth: parseInt(hw, 10)
    halfHeight: parseInt(hh, 10)
  }

getEmbedHTML = (opts) ->
  $embed = $ '<div class="embed"></div>'
  if opts.html
    $embed.html opts.html
  else
    $img = $ '<img>'
    $img.attr('src', opts.src)
    $img.attr('width', opts.width) if opts.width
    $img.attr('height', opts.height) if opts.height
    $img.attr('alt', opts.alt) if opts.alt # future-proof
    $embed.append $img
  $inner = $ '<div class="fullscreen-overlay-inner"></div>'
  $inner.append $embed
  $inner

fullscreenOverlay =
  overlay: null
  preloadURL: null
  dimensions: null

  prepareOverlay: ->
    return if @overlay

    @overlay = $ '<div class="fullscreen-overlay hidden"></div>'
    $('body').append @overlay

    @overlay.click (e) =>
      e.stopPropagation()
      @hide()

  show: (opts) ->
    ###
    html (video, audio, map)
    src (images)
    width (some images)
    height (some images)
    ###

    @prepareOverlay()
    @dimensions = null
    @promise.reject() if @promise
    @preloadURL = null
    @overlay.html getEmbedHTML(opts)
    @overlay.removeClass 'hidden'
    @overlay.addClass 'loading'
    @fit()

  hide: ->
    return false unless @overlay
    return false if @overlay.hasClass('hidden')
    @overlay.html ''
    @overlay.addClass 'hidden'
    true

  getContentDimensions: ->
    $el = @overlay.find('iframe,img')

    validate = (w, h) ->
      if parseInt(w, 10).toString() == w and parseInt(h, 10).toString() == h
        return {
          width: parseInt(w, 10)
          height: parseInt(h, 10)
        }
      else
        return null

    # try the attributes first
    dimensions = validate($el.attr('width'), $el.attr('height'))
    return dimensions if dimensions

    # try just measuring it
    dimensions = validate($el.width(), $el.height())
    return dimensions if dimensions

    # give up
    return null

  fit: ->
    return unless @overlay
    return if @overlay.hasClass('hidden')

    @dimensions ?= @getContentDimensions()
    if @dimensions
      # just fit it into window width+height, then remove class "loading"

      # use the overlay's dimensions rather than window dimensions so that
      # overlay padding is taken into consideration
      $c = @overlay.find('.fullscreen-overlay-inner')
      cw = $c.width()
      ch = $c.height()
      info = getScaleInfo(cw, ch, @dimensions.width, @dimensions.height)

      $embed = @overlay.find('.embed')
      $embed.addClass 'fitted'
      $embed.css
        'width': "#{info.width}px"
        'height': "#{info.height}px"
        'margin-left': "-#{info.halfWidth}px"
        'margin-top': "-#{info.halfHeight}px"

      $el = @overlay.find('iframe,img')
      $el.removeAttr('width').removeAttr('height')

      @overlay.removeClass 'loading'

    else if @preloadURL
      # NOTE: don't do anything because we're already preloading the image to
      # get the size. It will re-fit once that's done.

    else
      # preload the image to get the size
      @preloadURL = src
      src = @overlay.find('img').attr('src')
      img = new Image
      img.onload = =>
        return unless src == @preloadURL
        $img = $(img)
        @dimensions =
          width: $img.width()
          height: $img.height()
        @preloadURL = null
        @fit()
      img.src = src

unless typeof window == 'undefined'
  window.fullscreenOverlay = fullscreenOverlay
