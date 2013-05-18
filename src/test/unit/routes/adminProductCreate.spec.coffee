SandboxedModule = require 'sandboxed-module'
Store           = require '../../../models/store'
Product         = require '../../../models/product'
AccessDenied    = require '../../../errors/accessDenied'

describe 'AdminProductCreateRoute', ->
  describe 'If user owns the store and product', sinon.test ->
    simpleProduct = toSimpleProductStub = ProductStub = saveStub = updateFromSimpleProductSpy = product = store = req = res = body = user = null
    before ->
      simpleProduct = {}
      store = _id: 9876, slug: 'some_store', name: 'Some Store'
      saveStub = sinon.stub().yields null, product
      updateFromSimpleProductSpy = sinon.spy()
      toSimpleProductStub = sinon.stub().returns simpleProduct
      class ProductStub
        @created: false
        constructor: ->
          ProductStub.created = true
          product = @
        save: saveStub
        storeSlug: store.slug
        updateFromSimpleProduct: updateFromSimpleProductSpy
        toSimpleProduct: toSimpleProductStub
      sinon.stub(Store, 'findBySlug').yields null, store
      user =
        isSeller: true
        stores: [9876]
        hasStore: -> true
      params = storeSlug: store.slug
      req = loggedIn: true, user: user, params: params, body:
        storeSlug: store.slug
      body = req.body
      res = send: sinon.spy()
      routes = SandboxedModule.require '../../../routes',
        requires:
          '../models/product': ProductStub
          '../models/store': Store
      routes.adminProductCreate req, res
    after ->
      Store.findBySlug.restore()
    it 'created a product', ->
      ProductStub.created.should.be.true
    it 'looked for correct store', ->
      Store.findBySlug.should.have.been.calledWith store.slug
    it 'access allowed and return code is correct', ->
      res.send.should.have.been.calledWith 201, simpleProduct
    it 'product is updated correctly', ->
      updateFromSimpleProductSpy.should.have.been.calledWith req.body
    it "sets the product's store", ->
      product.storeName.should.equal store.name
      product.storeSlug.should.equal store.slug
    it 'product should had been saved', ->
      saveStub.should.have.been.called

  describe 'Access is denied', ->
    routes = null
    before ->
      routes = require '../../../routes',
    it "a seller but does not own this product's store denies access and throws", sinon.test ->
      @stub(Store, 'findBySlug').yields()
      user =
        isSeller: true
        hasStore: -> false
      req = loggedIn: true, user: user, body: {}, params: {}
      expect( -> routes.adminProductCreate req, null).to.throw AccessDenied
    it 'denies access if the user isnt a seller and throws', ->
      req = user: {isSeller:false}, loggedIn: true
      expect( -> routes.adminProductCreate req, null).to.throw AccessDenied
    it 'throws if not signed in', ->
      req = loggedIn: false
      expect( -> routes.adminProductCreate req, null).to.throw AccessDenied