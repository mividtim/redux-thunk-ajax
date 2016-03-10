Promise = require "bluebird"

ajax = Promise.promisify (action, json, callback) ->
  req = new XMLHttpRequest()
  complete = ->
    if req.readyState is 4 # ReadyState Complete
      successResultCodes = [200, 304]
      result = JSON.parse req.responseText
      if req.status in successResultCodes
        callback null, result
      else
        result.status = req.status
        callback result, null
  req.addEventListener "readystatechange", complete, false
  try
    req.open "POST", action
    req.setRequestHeader "Content-Type", "application/json"
    req.send JSON.stringify json
  catch err
    err = JSON.parse err
    callback err, null

module.exports = (endpoint, ticket, action, done, error) ->
  (dispatch) ->
    dispatch type: action, ticket: ticket
    try
      ajax endpoint, ticket
        .then (result) -> dispatch _.assign result, type: done, time: new Date()
        .catch (err) -> dispatch type: error, message: err
    catch err
      dispatch type: error, message: err.message

