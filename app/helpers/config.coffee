pkgInfo = require '../../package.json'
process.env.NODE_ENV = 'development' unless process.env.NODE_ENV?
unless process.env.NODE_ENV is 'production'
  process.env.AWS_IMAGES_BUCKET = "ateliesteste"
  process.env.AWS_REGION = "us-east-1"
  process.env.APP_COOKIE_SECRET = 'somesecret'
  process.env.SERVER_ENVIRONMENT = 'dev'
  process.env.STATIC_PATH = '/public' unless process.env.STATIC_PATH?
  process.env.RECAPTCHA_PUBLIC_KEY = '6LfzS-QSAAAAAP3ydudINWrhwGAo-X0Vg86F6hf3'
  process.env.RECAPTCHA_PRIVATE_KEY = 'what' unless process.env.RECAPTCHA_PRIVATE_KEY?
  process.env.FB_APP_ID = '1415894348640840' unless process.env.FB_APP_ID?
  process.env.FB_APP_SECRET = '6318e0570043978efca19c7ee18b0c59' unless process.env.FB_APP_SECRET?
  process.env.PAYPAL_HOST = 'api.sandbox.paypal.com' unless process.env.PAYPAL_HOST?
  process.env.PAYPAL_PORT = '' unless process.env.PAYPAL_PORT?
  process.env.SUPER_ADMIN_EMAIL = "admin@atelies.com.br"
  process.env.CLIENT_LIB_VERSION = "."
  process.env.UPLOAD_FILES = true unless process.env.UPLOAD_FILES?
  if !process.env.DEBUG? then process.env.DEBUG = 'true'
  switch process.env.NODE_ENV
    when 'development'
      process.env.MONGOLAB_URI = "mongodb://localhost/atelies" unless process.env.MONGOLAB_URI?
      process.env.PORT = 3000 unless process.env.PORT?
      process.env.AWS_ACCESS_KEY_ID = 'a' unless process.env.AWS_ACCESS_KEY_ID?
      process.env.AWS_SECRET_KEY = 'b' unless process.env.AWS_SECRET_KEY?
    when 'test'
      process.env.MONGOLAB_URI = "mongodb://localhost/ateliesteste"
      process.env.PORT = 8000 unless process.env.PORT?
  process.env.BASE_DOMAIN = "localhost:#{process.env.PORT}" unless process.env.BASE_DOMAIN?
if process.env.NODE_ENV is 'production' and process.env.SERVER_ENVIRONMENT is 'production'
  process.env.PAYPAL_HOST = 'api.paypal.com' unless process.env.PAYPAL_HOST?
  process.env.PAYPAL_PORT = '' unless process.env.PAYPAL_PORT?

values =
  appCookieSecret: process.env.APP_COOKIE_SECRET
  connectionString: process.env.MONGOLAB_URI
  port: process.env.PORT
  environment: process.env.NODE_ENV
  isProduction: process.env.NODE_ENV is 'production'
  debug: process.env.DEBUG? and process.env.DEBUG is 'true'
  aws:
    accessKeyId: process.env.AWS_ACCESS_KEY_ID
    secretKey: process.env.AWS_SECRET_KEY
    region: process.env.AWS_REGION
    imagesBucket: process.env.AWS_IMAGES_BUCKET
  recaptcha:
    publicKey: process.env.RECAPTCHA_PUBLIC_KEY
    privateKey: process.env.RECAPTCHA_PRIVATE_KEY
  test:
    sendMail: process.env.SEND_MAIL?
    uploadFiles: process.env.UPLOAD_FILES?
    snapci: process.env.SNAP_CI is 'true'
  baseDomain: process.env.BASE_DOMAIN
  serverEnvironment: process.env.SERVER_ENVIRONMENT
  app:
    version: pkgInfo.version
    name: pkgInfo.name
  staticPath: process.env.STATIC_PATH
  facebook:
    appId: process.env.FB_APP_ID
    appSecret: process.env.FB_APP_SECRET
  superAdminEmail: process.env.SUPER_ADMIN_EMAIL?.toLowerCase()
  clientLibVersion: process.env.CLIENT_LIB_VERSION
  clientLibPath: "#{process.env.STATIC_PATH}/javascripts/#{process.env.CLIENT_LIB_VERSION}"
  paypal:
    host: process.env.PAYPAL_HOST
    port: process.env.PAYPAL_PORT
values.secureUrl = if values.environment is 'production' then "https://www.#{values.baseDomain}" else "http://#{values.baseDomain}"
values.allValuesPresent = ->
  @appCookieSecret? and @connectionString? and @port? and @environment? and
    @aws? and @aws?.accessKeyId? and @aws?.secretKey? and @aws?.region? and @aws?.imagesBucket? and
    @recaptcha? and @recaptcha?.publicKey? and @recaptcha?.privateKey and @baseDomain? and @serverEnvironment? and
    @staticPath? and @clientLibVersion? and @superAdminEmail? and
    @paypal.host? and @paypal.port?
valuesPresent =
  appCookieSecret: values.appCookieSecret?
  connectionString: values.connectionString?
  port: values.port?
  environment: values.environment?
  debug: values.debug?
  aws:
    accessKeyId: values.aws?.accessKeyId?
    secretKey: values.aws?.secretKey?
    region: values.aws?.region?
    imagesBucket: values.aws?.imagesBucket?
  recaptcha:
    publicKey: values.recaptcha?.publicKey?
    privateKey: values.recaptcha?.privateKey?
  test:
    sendMail: values.test?.sendMail?
    uploadFiles: values.test?.uploadFiles?
  baseDomain: values.baseDomain?
  serverEnvironment: values.serverEnvironment?
  staticPath: values.staticPath?
  clientLibVersion: values.clientLibVersion?
  superAdminEmail: values.superAdminEmail?
  paypal:
    host: values.paypal?.host?
    port: values.paypal?.port?
unless values.environment is 'test'
  console.log "Config values present: #{JSON.stringify valuesPresent}"
  console.log "Config values: #{JSON.stringify values}"
if !values.allValuesPresent() and !values.debug and values.environment isnt 'test'
  missing = []
  checkValues = (o) ->
    for k, v of o
      if typeof v is 'object'
        checkValues v
      else
        missing.push k unless v
  checkValues valuesPresent
  throw new Error("Missing config values: #{missing.join()}.")
module.exports = values
