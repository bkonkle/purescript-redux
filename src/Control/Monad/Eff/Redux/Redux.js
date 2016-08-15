var Interface = require('../../../../../lib/Interface')

module.exports = {
  createStore: Interface.createStore,
  subscribe: Interface.subscribe,
  dispatch: Interface.dispatch,
  getState: Interface.getState,
  replaceReducer: Interface.replaceReducer,
  combineReducers: Interface.combineReducers,
  applyMiddleware: Interface.applyMiddleware
}
