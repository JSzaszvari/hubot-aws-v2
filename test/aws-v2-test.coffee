Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

helper = new Helper('../src/')

describe 'aws-v2', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  it 'responds to ec2 ls', ->
    @room.user.say('alice', '@hubot ec2 ls').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot ec2 ls']
        ['hubot', 'Fetching all instances...']
      ]
