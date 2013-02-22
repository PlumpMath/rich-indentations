var log;

log = function() {
  return console.log.apply(console, arguments);
};

log("hello");
