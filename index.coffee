Promise = require "bluebird"

ajax = (action, json) ->
  new Promise (resolve, reject) ->
    req = new XMLHttpRequest()
    complete = ->
      if req.readyState is 4 # ReadyState Complete
        successResultCodes = [200, 304]
        result = JSON.parse req.responseText
        if req.status in successResultCodes
          resolve result
        else
          result.status = req.status
          reject result
    req.addEventListener "readystatechange", complete, false
    try
      req.open "POST", action
      req.setRequestHeader "Content-Type", "application/json"
      req.send JSON.stringify json
    catch err
      reject JSON.parse err

module.exports = (endpoint, actions, ticket, onlyif = -> yes) ->
  (dispatch, getState) ->
    if onlyif getState
      dispatch type: actions.request, ticket: ticket
      try
        ajax endpoint, ticket
          .then (response) -> dispatch response: response, type: actions.complete, time: new Date()
          .catch (error) -> dispatch type: actions.error, message: error
      catch error
        dispatch type: actions.error, error: error.message
