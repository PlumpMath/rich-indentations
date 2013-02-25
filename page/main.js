var count_space, grid, log, q;

log = function() {
  return console.log.apply(console, arguments);
};

q = function(query) {
  return document.querySelector(query);
};

Node.prototype.q = function(query) {
  return this.querySelector(query);
};

String.prototype.count = function(char) {
  var count, i, _i, _len;
  count = 0;
  for (_i = 0, _len = this.length; _i < _len; _i++) {
    i = this[_i];
    if (i === char) {
      count += 1;
    }
  }
  return count;
};

String.prototype.__defineGetter__("end", function() {
  return this[this.length - 1];
});

Array.prototype.__defineGetter__("end", function() {
  return this[this.length - 1];
});

String.prototype.getx = function(n) {
  var lines, part;
  part = data.slice(0, n);
  lines = part.split("\n");
  return lines.end.length;
};

HTMLTextAreaElement.prototype.__defineGetter__("single", function() {
  return this.selectionStart === this.selectionEnd;
});

count_space = function(line) {
  var count;
  line = line.trimRight();
  if (line === "") {
    return void 0;
  }
  count = 0;
  while (line[0] != null) {
    if (line[0] === " ") {
      count += 1;
    } else {
      break;
    }
    line = line.slice(1);
  }
  return count;
};

grid = {
  data: "",
  lines: [],
  cx: 0,
  cy: 0,
  update: function() {
    var end, start;
    this.data = this.elem.value;
    this.lines = this.data.split("\n");
    start = this.elem.selectionStart;
    end = this.elem.selectionEnd;
    this.cx = this.data.slice(0, start).split("\n").end.length;
    this.cy = this.data.slice(0, start).count("\n");
    return this.change();
  },
  onchange: {},
  change: function() {
    var call, key, snapshot, _ref, _results;
    snapshot = {
      data: this.data,
      lines: this.lines,
      cx: this.cx,
      cy: this.cy
    };
    this.writeback();
    _ref = this.onchange;
    _results = [];
    for (key in _ref) {
      call = _ref[key];
      _results.push(call(snapshot));
    }
    return _results;
  },
  writeback: function() {
    var before, that;
    this.data = this.lines.join("\n");
    this.elem.value = this.data;
    that = this.lines.slice(0, this.cy).concat([this.lines[this.cy].slice(0, this.cx)]);
    before = that.join("\n");
    return this.elem.selectionStart = this.elem.selectionEnd = before.length;
  },
  newline: function() {
    var curr_line, indent, next_line;
    curr_line = this.lines[this.cy].slice(0, this.cx);
    indent = curr_line.match(/^\s*/)[0];
    next_line = indent + this.lines[this.cy].slice(this.cx);
    this.lines = this.lines.slice(0, this.cy).concat([curr_line], [next_line], this.lines.slice(this.cy + 1));
    this.cy += 1;
    this.cx = indent.length;
    this.change();
    return false;
  },
  backspace: function() {
    var before, line, number, point, shift;
    if (this.elem.single) {
      before = this.lines[this.cy].slice(0, this.cx);
      if (before.match(/^\s+$/)) {
        shift = before.length > 1 ? 2 : 1;
        this.cx -= shift;
        point = this.cy;
        line = this.lines[point];
        if (line.trim().length > 0) {
          this.lines[point] = this.lines[point].slice(shift);
          point += 1;
          while (this.lines[point] != null) {
            number = count_space(this.lines[point]);
            if (number == null) {
              point += 1;
              continue;
            } else if (number > count_space(line)) {
              this.lines[point] = this.lines[point].slice(shift);
              point += 1;
            } else {
              break;
            }
          }
          this.change();
          return false;
        }
      }
    }
    return true;
  },
  blank: function() {
    var before, line, number, point, unshift;
    if (this.elem.single) {
      before = this.lines[this.cy].slice(0, this.cx);
      if (before.match(/^\s*$/)) {
        unshift = 2;
        this.cx += unshift;
        point = this.cy;
        line = this.lines[point];
        if (line.trim().length > 0) {
          this.lines[point] = "  " + this.lines[point];
          point += 1;
          while (this.lines[point] != null) {
            number = count_space(this.lines[point]);
            if (number == null) {
              point += 1;
              continue;
            } else if (number > count_space(line)) {
              this.lines[point] = "  " + this.lines[point];
              point += 1;
            } else {
              break;
            }
          }
          this.change();
          return false;
        }
      }
    }
    return true;
  }
};

window.onload = function() {
  var code, text;
  grid.elem = text = q("#text");
  code = q("#code");
  text.focus();
  grid.onchange.render = function(data) {
    code.innerHTML = "";
    return data.lines.forEach(function(line) {
      var column, html, next, next_column, prev, prev_column, row, shadow, _results;
      html = line.split("").map(function(char) {
        return "<code>" + char + "</code>";
      });
      html = "<div class='line'>" + (html.join("")) + "</div>";
      code.insertAdjacentHTML("beforeend", html);
      row = code.q(".line:nth-child(" + (data.cy + 1) + ")");
      if (row != null) {
        column = row.q("code:nth-child(" + data.cx + ")");
        shadow = "1px 0px 0px red";
        if ((column != null) && column.innerText === " ") {
          column.style.boxShadow = "4px 0px 0px red";
          prev = row;
          while (prev.previousElementSibling != null) {
            prev = prev.previousElementSibling;
            prev_column = prev.q("code:nth-child(" + data.cx + ")");
            if (prev_column != null) {
              if (prev_column.innerText !== " ") {
                break;
              }
              prev_column.style.boxShadow = shadow;
            }
          }
          next = row;
          _results = [];
          while (next.nextElementSibling != null) {
            next = next.nextElementSibling;
            next_column = next.q("code:nth-child(" + data.cx + ")");
            if (next_column != null) {
              if (next_column.innerText !== " ") {
                break;
              }
              _results.push(next_column.style.boxShadow = shadow);
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        }
      }
    });
  };
  text.onkeydown = function(e) {
    grid.update();
    switch (e.keyCode) {
      case 8:
        return e.returnValue = grid.backspace();
      case 13:
        return e.returnValue = grid.newline();
      case 32:
        return e.returnValue = grid.blank();
    }
  };
  text.onkeyup = function() {
    return grid.update();
  };
  return text.onclick = function() {
    return grid.update();
  };
};
