import Redux from 'redux'

// `createStore` needs a 2-parameter, pure function for creating a new store.
// The `initialState` can be used to 'rehydrate' the client state.
export const createStore = reducer => initialState => () => {
  return Redux.createStore(extractReducer(reducer), initialState)
}

// To get information about state changes via registered `listeners`.
// http://redux.js.org/docs/api/Store.html#subscribe
export const subscribe = callback => store => () => {
  store.subscribe(callback)
  return {}
}

// Dispatches an action. A Redux-based app never changes its state directly but
// instead via so-called `actions` / `action creators`
// http://redux.js.org/docs/api/Store.html#dispatch
export const dispatch = action => store => () => {
  if (action) {
    return action.value0
      ? store.dispatch(action.value0)
      : store.dispatch(action)
  }
  return {}
}

// Returns the current state
// http://redux.js.org/docs/api/Store.html#getState
export const getState = store => () => store.getState()

// For replacing the current reducer.
// http://redux.js.org/docs/api/Store.html#replaceReducer
export const replaceReducer = store => nextReducer => () => {
  store.replaceReducer(extractReducer(nextReducer))
}

// Apply an action and an initial state to a reducer
export const applyReducer = reducer => action => state => {
  try {
    state = reducer(action)(state)
  } catch (e) {
    if (!e.message.startsWith('Failed pattern match')) {
      throw e
    }
  }
  return state
}

// For injecting 3rd-party extensions between dispatch and reducer.
// http://redux.js.org/docs/advanced/Middleware.html
export const applyMiddleware = middlewares => reducer => initialState => () => {
  const all = middlewares.map(extractMiddleware)
  return Redux.createStore(
    extractReducer(reducer),
    initialState,
    Redux.applyMiddleware.apply(undefined, all)
  )
}

// For combining separate `reducing functions` int one reducer
// http://redux.js.org/docs/api/combineReducers.html
export const combineReducers = reducers => () => {
  return Redux.combineReducers(reducers)
}

const extractReducer = reducer => (a, b) => reducer(a)(b)

// The `next` call is the dispatcher call and by default PureScript puts an
// additional ()-call after its completion (this is how PureScript wrapps
// effects from JS side). To maintain this extra call on the JS side we wrap the
// original next(action)-call into an additional function call.
const wrapNextDispatch = next => action => () => next(action)

// NOTE: EXPERIMENTAL
// Create a complete middleware function chain so redux can properly register
// it. There are three interleaved functions calls: store=>next=>action The
// `store` is not a complete store but a shrinked version of it containing only:
// getState & dispatch The `next` is the next dispatch call in the hierarchy The
// `action` is the next action to be dispatched by the current `next` dispatcher
const extractMiddleware = middleware => store => next => action => {
  return middleware(store)(wrapNextDispatch(next))(action)()
}
