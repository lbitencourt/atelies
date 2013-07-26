nodemailer = require 'nodemailer'
module.exports = class Postman
  @configure = (id, secret) ->
    unless @dryrun
      @smtp = nodemailer.createTransport "SES",
        AWSAccessKeyID: id
        AWSSecretKey: secret
      @running = true
  @stop = -> @smtp.close() if @running

  @dryrun = off

  send: (from, to, subject, body, cb = (->)) ->
    if Postman.dryrun
      console.log "NOT sending mail, dry run"
      return cb()
    mail =
      from: "'#{from.name}' <#{from.email}>"
      to: "'#{to.name}' <#{to.email}>"
      subject: subject
      html: body
      generateTextFromHTML: true
      forceEmbeddedImages: true
    #console.log "Sending mail from #{mail.from} to #{mail.to} with subject '#{mail.subject}'"
    Postman.smtp.sendMail mail, cb

  sendFromContact: @::send.partial {name:'Ateliês', email:'contato@atelies.com.br'}
