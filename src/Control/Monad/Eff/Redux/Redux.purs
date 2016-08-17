module Control.Monad.Eff.Redux
  ( Action(Action)
  , CreateStore
  , Dispatch
  , GetState
  , Middleware
  , Next
  , Reducer
  , Redux
  , ReduxEff
  , ReduxReducer
  , Store
  , STORE
  , applyMiddleware
  , combineReducers
  , createAction
  , createReducer
  , createStore
  , dispatch
  , getState
  , replaceReducer
  , subscribe
  ) where

import Prelude
import Control.Monad.Eff (Eff)
import Data.Function.Uncurried (mkFn2, Fn2)
import Data.Maybe (Maybe(Just))
import Data.Nullable (Nullable, toMaybe)

newtype Action action = Action { "type" :: action }

foreign import data STORE :: !

foreign import data Redux :: *

foreign import data Store :: *

type ReduxEff eff value = Eff (store :: STORE | eff) value

type Reducer action state = action -> state -> state

newtype ReduxReducer action state =
  ReduxReducer (Fn2 (Nullable state) (Action action) state)

type Dispatch action eff = Action action -> ReduxEff eff (Action action)

type GetState eff state = ReduxEff eff state

type CreateStore action state eff =
  Reducer action state -> action -> ReduxEff eff Store

type Next action eff = Dispatch action eff

type Middleware action eff =
  Store -> Next action eff -> Action action -> ReduxEff eff (Action action)

foreign import createStore :: forall action state eff.
  Reducer action state -> state -> ReduxEff eff Store

foreign import subscribe :: forall eff.
  Eff eff Unit -> Store -> ReduxEff eff Unit

foreign import dispatch :: forall action eff.
  Action action -> Store -> ReduxEff eff (Action action)

foreign import getState :: forall eff state. Store -> ReduxEff eff state

foreign import replaceReducer :: forall action state eff.
  Reducer action state -> Store -> ReduxEff eff Unit

foreign import combineReducers :: forall reducers action state eff.
  Record reducers -> ReduxEff eff (Reducer action state)

foreign import applyMiddleware :: forall state action eff.
  Array (Middleware action eff) -> Reducer action state -> state ->
  ReduxEff eff Store

-- | Apply an initial state and an action to a reducer
foreign import applyReducer :: forall action state.
  Reducer action state -> action -> state -> state

-- | Construct a pure Redux action.
createAction :: forall action. action -> Action action
createAction = Action <<< { "type": _ }

-- | Construct a reducer that unwraps the action before using.
createReducer :: forall action state.
  Reducer action state -> state -> ReduxReducer action state
createReducer reducer initialState = ReduxReducer <<< mkFn2 $
  \state (Action action) ->
    case (toMaybe state) of
      (Just state') -> applyReducer reducer action.type state'
      otherwise -> initialState
