Promise = require "bluebird"

ajax = (options) ->
  new Promise (resolve, reject) ->
    req = new XMLHttpRequest()
    complete = ->
      if req.readyState is 4 # ReadyState Complete
        successResultCodes = [200, 304]
        result = {}
        try
          result = JSON.parse req.responseText
        catch
          result.message = req.responseText
        if req.status in successResultCodes
          resolve result
        else
          error = new Error "Non-success status received in AJAX request"
          error.status = req.status
          error.result = result
          reject error
    req.addEventListener "readystatechange", complete, no
    try
      req.open "POST", options.url
      req.setRequestHeader "Content-Type", "application/json"
      req.setRequestHeader key, value for key, value of options.headers
      req.send JSON.stringify options.payload
    catch err
      reject err

module.exports = (options) ->
  headers = options.headers or {}
  (dispatch, getState) ->
    options.headers = headers
    options.headers[key] = value for key, value of options.getHeaders? getState
    if not options.onlyif? or options.onlyif getState
      dispatch type: options.actions.request, payload: options.payload
      try
        ajax options
          .then (response) ->
            dispatch { response, type: options.actions.complete, time: new Date() }
            options.onComplete? dispatch, getState, response
          .catch (error) ->
            dispatch type: options.actions.error, message: error
      catch error
        dispatch type: options.actions.error, message: error.message
