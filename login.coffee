###
      Test Environment:
      - OS Ubuntu
      - Phantomjs, Casperjs, Coffeescript
      - Chromium web browser
      
      Test execution: casperjs --ignore-ssl-errors=yes login.coffee
      '--ignore-ssl-errors=yes' is significant!
###

##
casper = require('casper').create(verbose: false, logLevel: "debug")
##
casper.on 'error', (msg,backtrace) -> 
  this.echo("=========================")
  this.echo("ERROR:")
  this.echo(msg)
  this.echo(backtrace)
  this.echo("=========================")
##
 casper.on "page.error", (msg, backtrace) -> 
  this.echo("=========================")
  this.echo("PAGE.ERROR:")
  this.echo(msg)
  this.echo(backtrace)
  this.echo("=========================")
## 

#credentials
pm_email = "pm1@hc.com"
user_email = "user0@hc.com"
pm_pass = user_pass = "testing"

#go to https://stage.hiiro.co, observe login form, check page title
casper.start "https://stage.hiiro.co", ->
  @test.assertTitle "Hiiro", "Page title check"
  @test.assertExist "form[action='/auth/login']", "Login form check"

#valid email, invalid password
casper.then ->
  @fill "form[action='/auth/login']", { 
    "user[email]": user_email
    "user[password]": "password"
    }, true
casper.then -> 
  @test.assertTextExist "Invalid email or password", "Invalid password: login failed"

#invalid email, valid password
casper.then ->
  @fill "form[action='/auth/login']", { 
    "user[email]": "person@hc.com"
    "user[password]": user_pass
    }, true
casper.then -> 
  @test.assertTextExist "Invalid email or password", "Invalid email: login failed"

#valid email, valid password
casper.then ->
  @fill "form[action='/auth/login']", { 
    "user[email]": user_email
    "user[password]": user_pass
    }, true
casper.then -> 
  @test.assertTextExist "Signed in successfully", "Valid data: successful login"

#observe freelancer's dashboard
casper.then ->
  @test.assertTextExist "Dashboard", "Page header is Dashboard"
  @test.assertSelectorHasText ".project-contracts-container", "My projects", "My projects are displayed"
  #check Main user navigation is displayed
  top_main_navigation = @evaluate -> __utils__.findAll ".menu-link"
  @test.assertEquals top_main_navigation.length, 4, "Main user navigation is displayed"
  #check main user navigation content
  @test.assertTextExist "Live Stats", "Live Stats link is visible"
  @test.assertTextExist "Projects", "Projects link is visible"
  @test.assertTextExist "Transactions", "Transactions link is visible"
  @test.assertVisible "a[href='/auth/logout']", "Logout link is visible"
  freelancer_name = @getElementInfo ".secondary-user-navigation"
  @test.assert freelancer_name.text != "", "User name is displayed"

top1 = top2 = 0

#widget sliding
casper.then ->
  #observe widget
  @test.assertVisible ".activity-widget-container", "Widged container is visible"
  @test.assertVisible ".activity-widget-expander", "Widged expander is visible"
  @test.assertVisible ".activity-widget", "Widged is visible"
  top1 = @getElementBounds ".activity-widget-container"
  @click ".activity-widget-expander"
casper.wait 1000, ->
  #dot have idea how to check the sliding
  top2 = @getElementBounds ".activity-widget-container"
  @test.assert top2.top < top1.top, "The widget sliding check"

now = new Date
casper.echo now

#chat
casper.then ->
  @test.assertVisible "#chat-user-id-11", "Chat member is visible"
  @click "#chat-user-id-11"
  @fill ".new-direct-message-form", {
    "direct_message[content]": now
    }, true
casper.reload -> 
  @echo now
  @test.assertTextExist now, "Chat message has been sent"

###
caper.then ->
  @fill "form[action='/auth/login']", { 
    "user[email]": "pm1@hc.com"
    "user[password]": "testing"
    }, true
casper.then ->
  @click '[href$="edit.json"]'
  @test.assertTextExist "Your Account", "Account properties"

  @click "#chat-user-id-1"
  @test.assertExist "#direct_message_content", "Check if chat opens"

  @fill ".new-direct-message-form", {"direct_message[content]": "abrakadabra!"}, true
  
  @click '[href="/auth/logout"]'
  @waitUntilVisible "#user_password"

casper.then ->
  @fill "form[action='/auth/login']", { 
    "user[email]": "user0@hc.com"
    "user[password]": "testing"
    }, true

  @waitForResource "https://stage.hiiro.co/users/11/direct_messages.json", ->
    @test.assert true, "AJAX is loaded"
###
##  
casper.then ->
  @evaluateOrDie (->
    /dashboard/.test document.body.innerHTML
  ), "sending message failed"

casper.run ->
  @echo('dashboard').exit() 

