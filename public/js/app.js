(function() {

  $(function() {
    var update, world;
    world = {
      tweets: ko.observable([]),
      builds: ko.observable([]),
      gits: ko.observable([])
    };
    update = function() {
      $.get("/twitter", function(data) {
        var t;
        return world.tweets((function() {
          var _i, _len, _ref, _results;
          _results = [];
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            t = data[_i];
            _results.push((_ref = t.retweeted_status) != null ? _ref : t);
          }
          return _results;
        })());
      });
      $.get("/travis", function(data) {
        return world.builds(data);
      });
      return $.get("/github", function(data) {
        return world.gits(data);
      });
    };
    update();
    setInterval(update, 60000);
    return ko.applyBindings(world);
  });

}).call(this);
