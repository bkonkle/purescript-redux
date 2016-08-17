var Interface = require('purescript-redux').Interface

module.exports = {
  createStore: Interface.createStore,
  subscribe: Interface.subscribe,
  dispatch: Interface.dispatch,
  getState: Interface.getState,
  replaceReducer: Interface.replaceReducer,
  applyReducer: Interface.applyReducer,
  combineReducers: Interface.combineReducers,
  applyMiddleware: Interface.applyMiddleware
}
