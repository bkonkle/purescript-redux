'use strict';

exports.__esModule = true;
exports.combineReducers = exports.applyMiddleware = exports.replaceReducer = exports.getState = exports.dispatch = exports.subscribe = exports.createStore = undefined;

var _redux = require('redux');

var _redux2 = _interopRequireDefault(_redux);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

// `createStore` needs a 2-parameter, pure function for creating a new store.
// The `initialState` can be used to 'rehydrate' the client state.
var createStore = exports.createStore = function createStore(reducer) {
  return function (initialState) {
    return function () {
      return _redux2.default.createStore(extractReducer(reducer), initialState);
    };
  };
};

// To get information about state changes via registered `listeners`.
// http://redux.js.org/docs/api/Store.html#subscribe
var subscribe = exports.subscribe = function subscribe(callback) {
  return function (store) {
    return function () {
      store.subscribe(callback);
      return {};
    };
  };
};

// Dispatches an action. A Redux-based app never changes its state directly but
// instead via so-called `actions` / `action creators`
// http://redux.js.org/docs/api/Store.html#dispatch
var dispatch = exports.dispatch = function dispatch(action) {
  return function (store) {
    return function () {
      if (action) {
        return action.value0 ? store.dispatch(action.value0) : store.dispatch(action);
      }
      return {};
    };
  };
};

// Returns the current state
// http://redux.js.org/docs/api/Store.html#getState
var getState = exports.getState = function getState(store) {
  return function () {
    return store.getState();
  };
};

// For replacing the current reducer.
// http://redux.js.org/docs/api/Store.html#replaceReducer
var replaceReducer = exports.replaceReducer = function replaceReducer(store) {
  return function (nextReducer) {
    return function () {
      store.replaceReducer(extractReducer(nextReducer));
    };
  };
};

// For injecting 3rd-party extensions between dispatch and reducer.
// http://redux.js.org/docs/advanced/Middleware.html
var applyMiddleware = exports.applyMiddleware = function applyMiddleware(middlewares) {
  return function (reducer) {
    return function (initialState) {
      return function () {
        var all = middlewares.map(extractMiddleware);
        return _redux2.default.createStore(extractReducer(reducer), initialState, _redux2.default.applyMiddleware.apply(undefined, all));
      };
    };
  };
};

// For combining separate `reducing functions` int one reducer
// http://redux.js.org/docs/api/combineReducers.html
var combineReducers = exports.combineReducers = function combineReducers(reducers) {
  return function () {
    return _redux2.default.combineReducers(reducers);
  };
};

var extractReducer = function extractReducer(reducer) {
  return function (a, b) {
    return reducer(a)(b);
  };
};

// The `next` call is the dispatcher call and by default PureScript puts an
// additional ()-call after its completion (this is how PureScript wrapps
// effects from JS side). To maintain this extra call on the JS side we wrap the
// original next(action)-call into an additional function call.
var wrapNextDispatch = function wrapNextDispatch(next) {
  return function (action) {
    return function () {
      return next(action);
    };
  };
};

// NOTE: EXPERIMENTAL
// Create a complete middleware function chain so redux can properly register
// it. There are three interleaved functions calls: store=>next=>action The
// `store` is not a complete store but a shrinked version of it containing only:
// getState & dispatch The `next` is the next dispatch call in the hierarchy The
// `action` is the next action to be dispatched by the current `next` dispatcher
var extractMiddleware = function extractMiddleware(middleware) {
  return function (store) {
    return function (next) {
      return function (action) {
        return middleware(store)(wrapNextDispatch(next))(action)();
      };
    };
  };
};
//# sourceMappingURL=Interface.js.map