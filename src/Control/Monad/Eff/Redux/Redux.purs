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
  , Store
  , STORE
  , action
  , applyMiddleware
  , combineReducers
  , createStore
  , dispatch
  , getState
  , replaceReducer
  , subscribe
  ) where

import Prelude
import Control.Monad.Eff (Eff)

newtype Action action = Action { "type" :: action }

foreign import data STORE :: !

foreign import data Redux :: *

foreign import data Store :: *

type ReduxEff eff value = Eff (store :: STORE | eff) value

type Reducer action state = state -> Action action -> state

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

-- | Construct a pure Redux action.
action :: forall action. action -> Action action
action = Action <<< { "type": _ }
