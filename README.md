Make JSON REST AJAX requests with redux-thunk

Usage:

```js
import { createStore, applyMiddleware, combineReducers } from 'redux'
import thunk from 'redux-thunk'
import ajaxThunk from 'redux-thunk-ajax'
const LOGIN_ACTIONS = {
    request: "LOGIN",
    complete: "LOGIN_COMPLETE",
    error: "LOGIN_ERROR"
};
// Avoid double-dispatching by including onlyif closure, and add http
// headers with getHeaders closure, each to which is passed the getState
// method from the store
// Pass in onComplete closure if you need to do more than dispatch an action
const login = (payload) =>
  ajaxThunk({
    url: "/auth/login",
    actions: LOGIN_ACTIONS,
    payload,
    onlyif: (getState) => !getState().auth.loggingIn,
    // Poor example here, since we're logging in, but this is useful
    // elsewhere
    getHeaders: (getState) => Authorization: "JWT " + getState().auth.token,
    onComplete: (getState, dispatch, response) => console.log arguments
  });
const auth = (state = {}, action) => {
  switch(action.type) {
    case LOGIN_ACTIONS.request:
      return Object.assign({}, state, {
        loggingIn: true,
        token: null,
        error: null
      });
      break;
    case LOGIN_ACTIONS.complete:
      return Object.assign({}, state, {
        loggingIn: false,
        token: action.token,
        error: null
      });
      break;
    case LOGIN_ACTIONS.error:
      return Object.assign({}, state, {
        loggingIn: false,
        token: null,
        error: action.message
      });
      break;
    default:
      return state;
      break;
  }
};
let reducer = combineReducers({ auth });
let store = createStore(reducer, applyMiddleware(thunk));
store.dispatch(login({ username: 'tim', password: 'bigSecret' }));
```
