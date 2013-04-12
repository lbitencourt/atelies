helper    = require './support/SpecHelper'
Product   = require '../models/product'
zombie    = new require('zombie')

describe 'Home page', ->
  browser = null
  product1 = null
  product2 = null
  eachCalled = false
  beforeEach (done) ->
    if eachCalled
      return done()
    eachCalled = true
    browser = new zombie.Browser()
    helper.cleanDB (error) ->
      if error
        return done error
      product1 = new Product(name: 'name1', picture: 'http://aa.com/picture1.jpg', price: 11.1)
      product2 = new Product(name: 'name2', picture: 'http://aa.com/picture2.jpg', price: 12.2)
      product1.save()
      product2.save()
      helper.whenServerLoaded ->
        browser.visit "http://localhost:8000/", (error) ->
          if error
            console.error "Error visiting. " + error.stack
            done error
          else
            done()
  it 'answers with 200', ->
    expect(browser.success).toBeTruthy()
  it 'has two products', ->
    expect(browser.query('table#productsHome tbody').children.length).toBe 2
  it 'shows product 1', ->
    expect(browser.text('#' + product1.id)).toBe product1.id
