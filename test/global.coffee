global.jsdom = require 'jsdom'
global.expect = require 'expect.js'
global.React = require 'react'
global.ReactTestUtils = require 'react/lib/ReactTestUtils'
global._ = require 'lodash'
global.sinon = require 'sinon'

before (done) ->
  jsdom.env '', [], (errs, window) ->
    global.window = window
    global.document = window.document
    global.Image = window.Image
    global.navigator = window.navigator

    done()
