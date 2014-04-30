isString = (myVar) ->
  typeof myVar == 'string' or myVar instanceof String

cookie = module.exports =
  get: (name) ->
    nameEQ = name + "="
    ca = document.cookie.split(";")
    i = 0

    while i < ca.length
      c = ca[i]
      c = c.substring(1, c.length) while c.charAt(0) == " "
      return c.substring(nameEQ.length, c.length) if c.indexOf(nameEQ) == 0
      i++

    null

  set: (name, v, days) ->
    v ?= ''
    value = if isString(v) then v else JSON.stringify(v)
    if days
      date = new Date()
      date.setTime date.getTime() + (days * 24 * 60 * 60 * 1000)
      expires = "; expires=#{date.toGMTString()}"
    else
      expires = ""
    document.cookie = "#{name}=#{value}#{expires}; path=/"

  del: (name) ->
    cookie.set name, "", -1

  pop: (name) ->
    value = cookie.get name
    cookie.del name
    value
