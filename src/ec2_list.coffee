# Description:
#   List ec2 instances on your AWS account.  
#
# Commands:
#   hubot ec2 ls <search_filter> - Displays Instances

# Notes:
#   <search_filter>: [optional] The name to be used for filtering the returned instances by instance name.
#
# Author:
#   John Szaszvari <jszaszvari@gmail.com>

moment = require 'moment'
util   = require 'util'
tsv    = require 'tsv'

getArgParams = (arg) ->
  ins_id_capture = /--instance_id=(.*?)( |$)/.exec(arg)
  ins_id = if ins_id_capture then ins_id_capture[1] else ''


  # filter by instance name
  #ins_filter_capture = /--instance_filter=(.*?)( |$)/.exec(arg)
  #ins_filter_capture = arg[1]

  #ins_filter = if ins_filter_capture then ins_filter_capture[1] else ''

  return {
    ins_id: ins_id,
   # ins_filter: ins_filter
  }
module.exports = (robot) ->
  hubotAdapter = robot.adapterName
  #robot.respond /ec2 ls(.*)$/i, (msg) ->
  robot.hear /ec2 ls(.*)$/i, (msg) ->

    arg_params = getArgParams(msg.match[1])
    ins_id  = arg_params.ins_id
    ins_filter = msg.match[1].replace /^\s+|\s+$/g, ""
   
    msg_txt = "Fetching #{ins_id || 'all instances'}"
    msg_txt += " containing '#{ins_filter}' in name" if ins_filter
    msg_txt += "..."
    msg.send msg_txt

    aws = require('../aws.coffee').aws()
    ec2 = new aws.EC2({apiVersion: '2014-10-01'})

    ec2.describeInstances (if ins_id then { InstanceIds: [ins_id] } else null), (err, res) ->
      if err
        msg.send "DescribeInstancesError: #{err}"
      else
        if ins_id
          msg.send util.inspect(res, false, null)

          ec2.describeInstanceAttribute { InstanceId: ins_id, Attribute: 'userData' }, (err, res) ->
            if err
              msg.send "DescribeInstanceAttributeError: #{err}"
            else if res.UserData.Value
              msg.send new Buffer(res.UserData.Value, 'base64').toString('ascii')
        else
          messages = []
          for data in res.Reservations
            ins = data.Instances[0]

            name = '[NoName]'
            for tag in ins.Tags when tag.Key is 'Name'
              name = tag.Value

            continue if ins_filter and name.indexOf(ins_filter) is -1

            if ins.State.Name is "running"
              statuscolor = "#008000"
            if ins.State.Name is 'stopped'
              statuscolor = "#FF0000"
           
            if robot.adapterName is 'rocketchat'
              msgSendMethod = robot.adapter.customMessage
            if robot.adapterName is 'slack'
              msgSendMethod = msg.send

            msg.send({
              channel: 'gCCmdeFSQJFoLRigB',
              attachments: [
                {
                  title: name,
                  text: "Instance is currently: " + ins.State.Name,
                  color: statuscolor
                  fields: [
                   {
                    "title": "ID",
                    "value": ins.InstanceId,
                    "short": true
                   },
                   {
                    "title": "Instance Type",
                    "value": ins.InstanceType ,
                    "short": true
                   }
                   {
                    "title": "Private IP",
                    "value": ins.PrivateIpAddress,
                    "short": true
                   }
                   {
                    "title": "Public IP",
                    "value": ins.PublicIpAddress,
                    "short": true
                   }
                  ]
                }
              ]
            });
            
           # messages.push({
           #   time   : moment(ins.LaunchTime).format('YYYY-MM-DD HH:mm:ssZ')
           #   state  : ins.State.Name
           #   id     : ins.InstanceId
           #   image  : ins.ImageId
           #   az     : ins.Placement.AvailabilityZone
           #   subnet : ins.SubnetId
           #   type   : ins.InstanceType
           #   ip     : ins.PrivateIpAddress
           #   name   : name || '[NoName]'
           # })

          #messages.sort (a, b) ->
          #  moment(a.time) - moment(b.time)
          #message = tsv.stringify(messages) || '[None]'
         # msg.send message
