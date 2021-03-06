Routes          = require '../../../app/routes/admin'
Store           = require '../../../app/models/store'
Product         = require '../../../app/models/product'
AccessDenied    = require '../../../app/errors/accessDenied'
Q               = require 'q'
Err             = require '../../../app/models/error'

describe 'AdminProductDeleteRoute', ->
  routes = null
  describe 'If user owns the store and product', ->
    product = store = req = res = body = user = null
    before ->
      routes = new Routes()
      product =
        remove: sinon.stub().yields null, product
        storeSlug: 'some_store'
      store = _id: 9876, calculateProductCount: sinon.spy()
      sinon.stub(Product, 'findById').yields null, product
      sinon.stub(Store, 'findBySlug').returns Q.fcall -> store
      user =
        isSeller: true
        stores: [9876]
        hasStore: -> true
      params = productId: '1234'
      req = loggedIn: true, user: user, params: params, body: {}
      body = req.body
      res = send: sinon.spy()
      routes.adminProductDelete req, res
    after ->
      Product.findById.restore()
      Store.findBySlug.restore()
    it 'looked for correct product', -> Product.findById.should.have.been.calledWith req.params.productId
    it 'looked for correct store', -> Store.findBySlug.should.have.been.calledWith product.storeSlug
    it 'access allowed and return code is correct', -> res.send.should.have.been.calledWith 204
    it 'product should had been deleted', -> product.remove.should.have.been.called
    it 'calculated product count', -> store.calculateProductCount.should.have.been.called

  describe 'Access is denied', ->
    describe "a seller but does not own this product's store", ->
      it 'denies access and throws', sinon.test ->
        routes = new Routes()
        product =
          save: @stub().yields null, product
          storeSlug: 'some_store'
        store = _id: 9876
        @stub(Product, 'findById').yields null, product
        @stub(Store, 'findBySlug').returns Q.fcall -> store
        user =
          isSeller: true
          stores: [6543]
          hasStore: -> false
        params = productId: '1234'
        req = loggedIn: true, user: user, params: params, body:
          name: 'Some Product'
        body = req.body
        sinon.stub routes, '_logError'
        res = json: sinon.spy()
        routes.adminProductDelete req, res
        .then -> res.json.should.have.been.calledWith 400
    describe 'not a seller', ->
      beforeEach -> routes = new Routes()
      it 'denies access if the user isnt a seller and throws', ->
        req = user: {isSeller:false}, loggedIn: true
        expect( -> routes.adminProductDelete req, null).to.throw AccessDenied
      it 'throws if not signed in', ->
        req = loggedIn: false
        expect( -> routes.adminProductDelete req, null).to.throw AccessDenied
