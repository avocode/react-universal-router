global.jsdom = require 'jsdom'
global.expect = require 'expect.js'
global._ = require 'lodash'
global.sinon = require 'sinon'

global.document = jsdom.jsdom('<html><body></body></html>')
global.window = document.defaultView
global.Image = window.Image
global.navigator = window.navigator

global.React = require 'react'
global.ReactTestUtils = require 'react-addons-test-utils'
global.ReactDOMServer = require 'react-dom/server'
