timer = ->
  previous = new Date()
  (note) ->
    now = new Date()
    elapsed = now-previous
    #console.log "#{note} [#{elapsed}ms]"
    previous = now

$.fn.fitText = (method) ->
  if method == 'destroy'
    this.each ->
      $el = $ this
      unfit $el
    return this

  if method == 'clear'
    this.each ->
      $el = $ this
      #clear $el
      unfit $el
    return this

  this.each -> fit $(this)

  this

unfit = ($el) ->
  #id = $el.attr 'id'
  #return unless id

  clear $el
  $el.removeAttr 'style'

clear = ($el) ->
  $el.data 'fitTextCache', {}

fit = ($el) ->
  # remove the display: inline-block hack again
  cleanup = ->
    $el.css 'display': 'block'

  id = $el.attr 'id'
  #return unless id

  # skip unless there's text
  text = $el.text().trim()
  return unless text

  log = timer()

  # add the cache if it doesn't exist
  clear($el) unless $el.data('fitTextCache')

  # read the cached sizes
  cache = $el.data('fitTextCache')

  # try and fit the parent's width
  $parent = $el.parent()
  pw = $parent.width()

  # get font size/line-height ratio so we can keep it later
  fontSize = parseInt($el.css('font-size'), 10)
  lineHeight = parseInt($el.css('line-height'), 10)
  lineHeightRatio = lineHeight/fontSize
  #console.log lineHeight, fontSize, lineHeightRatio
  #lineHeightRatio = 1

  # set the font size and line height while trying to maintain the font
  # size/line height ratio and return the new width
  total = 0
  setSize = (fs, skipMeasure) ->
    total += 1
    lh = Math.floor fs*lineHeightRatio

    $el.css
      'display': 'inline-block'
      'white-space': 'nowrap'
      'font-size': "#{fs}px"
      'line-height': "#{lh}px"
      'min-height': "#{lh}px" # hack for contenteditables

    if skipMeasure
      null
    else
      width = $el.outerWidth(true)
      width

  # if we already have a cached size for this width, use that and exit
  if cache[pw]
    # TODO: I don't think we clean up properly here
    setSize cache[pw], true
    log "using cached for #{id}:#{pw} (#{cache[pw]})"
    return cleanup()

  # start off at the minimum size
  w = setSize 10

  # don't bother if the minimum size is already too big
  if w > pw
   log("too big for #{id}")
   return cleanup()

  minSize = 10
  maxSize = 1000

  # heuristics..
  guess = Math.floor(pw/w*10)
  minSize = Math.max minSize, guess-20
  maxSize = Math.min maxSize, guess+20

  # find the closest font size where the width is <= the parent width
  [newFontSize, acc] = search(pw, setSize, minSize, maxSize, minSize)

  unless acc == 'exact'
    # we didn't get an exact match, so use what we found
    w = setSize newFontSize

  # cache this value
  cache[pw] = newFontSize
  $el.data('fitTextCache', cache)

  log("#{total} calls for #{id}")
  cleanup()

###
find the closest input applied with function f (where inputs fall in the range
min..max) where the output is equal to or smaller than target. It is assumed
that bigger inputs mean bigger outputs.

so output = f(value) where output <= target

Or in less general terms:

* target == parent width
* f == "set the font size and measure the resultant width"
* min == 10px font size
* max == 1000px font size
* closest == the last size tried where the text's width was
  smaller than the parent width
###
search = (target, f, min, max, closest) ->
  diff = max-min

  if diff <= 0
    # the last thing that was too small is the closest match
    return [closest, 'closest']

  mid = min + Math.floor(diff/2)
  val = f mid

  if val == target
    [mid, 'exact']
  else if val < target
    search(target, f, mid+1, max, mid)
  else
    search(target, f, min, mid-1, closest)
