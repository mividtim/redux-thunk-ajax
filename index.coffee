Promise = require "bluebird"
assign = require "lodash.assign"

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
          .then (result) -> dispatch assign result, type: actions.complete, time: new Date()
          .catch (err) -> dispatch type: actions.error, message: err
      catch err
        dispatch type: actions.error, error: err.message
