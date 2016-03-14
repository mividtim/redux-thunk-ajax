Make JSON REST AJAX requests with redux-thunk

Usage:

    import { createStore, applyMiddleware, combineReducers } from 'redux'
    import thunk from 'redux-thunk'
    import ajaxThunk from 'redux-thunk-ajax'
    const LOGIN_ACTIONS = {
        request: "LOGIN",
        complete: "LOGIN_COMPLETE",
        error: "LOGIN_ERROR"
    };
    // Avoid double-dispatching by including onlyif closure, to which is passed
    // the getState method from the store
    const login = ajaxThunk("/auth/login", LOGIN_ACTIONS, (getState) => !getState().auth.loggingIn);
    const auth = function(state = {}, action) {
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

