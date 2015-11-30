// Generated by CoffeeScript 1.9.2
var qs, url, urlPattern, waterfall;

urlPattern = require('lib/url-pattern');

url = require('lib/url');

qs = require('lib/querystring/index');

module.exports = function(handlers) {
  var args, i, len, match, matchWithData, parseURL, routes;
  routes = [];
  for (i = 0, len = handlers.length; i < len; i++) {
    args = handlers[i];
    routes.push({
      pattern: urlPattern.newPattern(args[0]),
      handler: args.slice(-1)[0],
      fetchers: args.slice(1, -1)
    });
  }
  match = function(url, arbitraryData, cb) {
    var j, len1, params, pathname, querystring, r, ref;
    if (!cb) {
      cb = arbitraryData;
    }
    ref = parseURL(url), querystring = ref.querystring, pathname = ref.pathname;
    for (j = 0, len1 = routes.length; j < len1; j++) {
      r = routes[j];
      params = r.pattern.match(pathname);
      if (params) {
        if (typeof window !== 'undefined' && typeof window._data !== 'undefined') {
          cb(null, r.handler, window._data);
          delete window._data;
        } else {
          args = [
            r.fetchers, (function(err, data) {
              return cb(null, r.handler, data);
            }), params
          ];
          if (r.fetchers && r.fetchers[0]) {
            if (r.fetchers[0].length > 2) {
              args.push(querystring);
            }
            if (r.fetchers[0].length > 3) {
              args.push(arbitraryData);
            }
          }
          waterfall.apply(this, args);
        }
        return;
      }
    }
    return cb({
      Error: 'no match.'
    });
  };
  matchWithData = function(url, data, cb) {
    var j, len1, params, pathname, r;
    pathname = parseURL(url).pathname;
    for (j = 0, len1 = routes.length; j < len1; j++) {
      r = routes[j];
      params = r.pattern.match(pathname);
      if (params) {
        cb(null, r.handler, data);
      }
    }
    return cb({
      Error: 'no match.'
    });
  };
  parseURL = function(something) {
    var req;
    if (typeof something === 'object' && something.url) {
      req = something;
      return {
        pathname: url.parse(req.url).pathname,
        querystring: req.query
      };
    } else if (typeof something === 'string') {
      url = url.parse(something);
      return {
        pathname: url.pathname,
        querystring: qs.parse(url.search)
      };
    } else {
      throw {
        Error: 'Invalid url or pathname passed to agnostic-router.'
      };
    }
  };
  return {
    match: match,
    matchWithData: matchWithData
  };
};

waterfall = function(tasks, cb) {
  var args, current, done;
  current = 0;
  cb = cb || function() {};
  done = function(err) {
    var args;
    args = Array.prototype.slice.call(arguments, 1);
    if (err) {
      return cb(err, args);
    }
    if (++current >= tasks.length) {
      return cb.apply(void 0, [null].concat(args));
    } else {
      return tasks[current].apply(void 0, args.concat(done));
    }
  };
  if (tasks[current]) {
    args = Array.prototype.slice.call(arguments, 2);
    return tasks[current].apply(void 0, args.concat(done));
  } else {
    return cb(null, {});
  }
};
