module Test.Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Random (RANDOM)
import Control.Monad.Eff.Redux (Action(Action), STORE, Store, ReduxEff, Next, action, applyMiddleware, combineReducers, getState, dispatch)
import Debug.Trace (traceAnyA, traceA)
import Test.QuickCheck (quickCheck, (===))
import Unsafe.Coerce (unsafeCoerce)

-- | A simple reducer reacting to two actions: INCREMENT, DECREMENT
data Counter = Increment | Decrement

counter :: Int -> Counter -> Int
counter state Increment = state + 1
counter state Decrement = state - 1

-- | Additional reducer to test combineReducer() API
data Squared = SquareInc | SquareDec

counterSquared :: Int -> Squared -> Int
counterSquared state SquareInc = state + (state * state)
counterSquared state SquareDec = state - (state * state)

-- | Additional reducer to test combineReducer() API
data Doubled = DoubleInc | DoubleDec

counterDoubled :: Int -> Doubled -> Int
counterDoubled state DoubleInc = state + (state * 2)
counterDoubled state DoubleDec = state - (state * 2)

-- | This is a middleware for logging | It receives a subset of the Store API
-- (getState & dispatch) and processes `actions`
simpleLogger :: forall action eff.
  Store -> Next action eff -> Action action ->
  ReduxEff eff (Action action)
simpleLogger = \store next action' -> do
  traceAnyA action'
  (next action')

-- | A simple listener for displaying current state
numericListener :: forall eff.
  Store -> ReduxEff (console :: CONSOLE | eff) Unit
numericListener = \store -> do
  currentState <- getState store
  traceA $ "STATE: " <> (unsafeCoerce currentState)

-- | Wrapper for testing the 'counter'-reducer
testReducer :: Int -> Action Counter -> Boolean
testReducer state (Action action') = counter state action'.type /= state

-- | Wrapper for testing the 'square counter'-reducer
testSquareReducer :: Int -> Action Squared -> Boolean
testSquareReducer state (Action action') =
  counterSquared state action'.type /= state

-- | Wrapper for testing the 'double counter'-reducer
testDoubleReducer :: Int -> Action Doubled -> Boolean
testDoubleReducer state (Action action') =
  counterDoubled state action'.type /= state

-- | Test middleware by sending actions which lead to state chages
testMiddleware :: forall eff. Store -> ReduxEff (console :: CONSOLE | eff) Unit
testMiddleware store = do
  actInc <- dispatch (action Increment) store
  currentState <- getState store
  traceA $ "STATE: " <> currentState
  actDec <- dispatch (action Decrement) store
  currentState2 <- (getState store)
  traceA $ "STATE: " <> currentState2
  pure unit

main :: forall eff. ReduxEff
  ( console :: CONSOLE
  , random :: RANDOM
  , err :: EXCEPTION
  | eff
  ) Unit
main = do
  traceA "\r\n[TESTING] combineReducers()"
  let combined = combineReducers { counterDoubled, counterSquared }

  traceA "\r\n[TESTING] applyMiddleware()"
  -- | Try to init a new container with middleware
  store <- (applyMiddleware [ simpleLogger ] counter 1)
  -- | Test reducer
  traceA "\r\n[TESTING] reducer (+1 INC and DEC)"
  quickCheck \n -> testReducer n Increment === true
  quickCheck \n -> testReducer n Decrement === true
  traceA "\r\n[TESTING] square reducer (^2 INC and DEC)"
  quickCheck \n -> testSquareReducer n SquareInc === true
  quickCheck \n -> testSquareReducer n SquareDec === true
  traceA "\r\n[TESTING] double reducer (*2 INC and DEC)"
  quickCheck \n -> testDoubleReducer n DoubleInc === true
  quickCheck \n -> testDoubleReducer n DoubleDec === true

  traceA "\r\n[TESTING] middleware"
  -- | Test middleware
  (testMiddleware store)
