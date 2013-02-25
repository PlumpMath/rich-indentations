
log = -> console.log arguments...
q = (query) -> document.querySelector query
Node.prototype.q = (query) -> @querySelector query

String::count = (char) ->
  count = 0
  for i in @
    count += 1 if i is char
  count
String::__defineGetter__ "end", -> @[@length-1]
Array::__defineGetter__ "end", -> @[@length-1]
String::getx = (n) ->
  part = data[0...n]
  lines = part.split "\n"
  lines.end.length

HTMLTextAreaElement::__defineGetter__ "single", ->
  @selectionStart is @selectionEnd

count_space = (line) ->
  line = line.trimRight()
  if line is "" then return undefined
  count = 0
  while line[0]?
    if line[0] is " " then count += 1
    else break
    line = line[1..]
  count

grid =
  data: ""
  lines: []
  cx: 0
  cy: 0

  update: ->
    @data = @elem.value
    @lines = @data.split("\n")
    start = @elem.selectionStart
    end = @elem.selectionEnd
    @cx = @data[...start].split("\n").end.length
    @cy = @data[...start].count "\n"
    # log "update:", @
    @change()

  onchange: {}

  change: ->
    snapshot =
      data: @data
      lines: @lines
      cx: @cx
      cy: @cy
    @writeback() # unless @lines[@cy][...@cx].trim() is ""
    call snapshot for key, call of @onchange

  writeback: ->
    @data = @lines.join "\n"
    @elem.value = @data
    that = @lines[...@cy].concat [@lines[@cy][...@cx]]
    before = that.join("\n")
      
    # log "before", that, before
    @elem.selectionStart = @elem.selectionEnd =
      before.length

  newline: ->
    curr_line = @lines[@cy][...@cx]
    indent = curr_line.match(/^\s*/)[0]
    next_line = indent + @lines[@cy][@cx..]
    @lines = @lines[...@cy].concat [curr_line],
      [next_line]
      @lines[(@cy+1)..]
    @cy += 1
    @cx = indent.length
    @change()
    off

  backspace: ->
    if @elem.single
      before = @lines[@cy][...@cx]
      if before.match /^\s+$/
        shift = if before.length > 1 then 2 else 1
        @cx -= shift
        point = @cy
        line = @lines[point]
        if line.trim().length > 0
          @lines[point] = @lines[point][shift..]
          point += 1
          while @lines[point]?
            number = count_space @lines[point]
            unless number?
              point += 1
              continue
            else if number > count_space line
              @lines[point] = @lines[point][shift..]
              point += 1
            else break
          @change()
          return off
    yes

  blank: ->
    if @elem.single
      # log "blank single"
      before = @lines[@cy][...@cx]
      if before.match /^\s*$/
        unshift = 2
        @cx += unshift
        point = @cy
        line = @lines[point]
        if line.trim().length > 0
          @lines[point] = "  " + @lines[point]
          # log "adding to:", point
          point += 1
          while @lines[point]?
            number = count_space @lines[point]
            unless number?
              point += 1
              continue
            else if number > count_space line
              @lines[point] = "  " + @lines[point]
              # log "adding in while:", point
              point += 1
            else break
          @change()
          # log "return off"
          return off
    yes

window.onload = ->
  grid.elem = text = q "#text"
  code = q "#code"

  text.focus()

  grid.onchange.render = (data) ->
    code.innerHTML = ""
    data.lines.forEach (line) ->
      html = line.split("").map (char) -> "<code>#{char}</code>"
      html = "<div class='line'>#{html.join ""}</div>"
      code.insertAdjacentHTML "beforeend", html
      row = code.q(".line:nth-child(#{data.cy + 1})")
      if row?
        column = row.q("code:nth-child(#{data.cx})")
        shadow = "1px 0px 0px red"
        if column? and column.innerText is " "
          column.style.boxShadow = "4px 0px 0px red"
          prev = row
          while prev.previousElementSibling?
            prev = prev.previousElementSibling
            prev_column = prev.q("code:nth-child(#{data.cx})")
            if prev_column?
              unless prev_column.innerText is " " then break
              prev_column.style.boxShadow = shadow
          next = row
          while next.nextElementSibling?
            next = next.nextElementSibling
            next_column = next.q("code:nth-child(#{data.cx})")
            if next_column?
              unless next_column.innerText is " " then break
              next_column.style.boxShadow = shadow

  text.onkeydown = (e) ->
    grid.update()
    switch e.keyCode
      when 8 then e.returnValue = grid.backspace()
      when 13 then e.returnValue = grid.newline()
      when 32 then e.returnValue = grid.blank()
  text.onkeyup = -> grid.update()
  text.onclick = -> grid.update()