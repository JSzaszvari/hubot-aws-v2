# Description:
#   Get a console screenshot for the specified instance id
#
# Configuration:
#   HUBOT_AWS_ACCESS_KEY_ID
#   HUBOT_AWS_SECRET_ACCESS_KEY
#   HUBOT_AWS_REGION
#   HUBOT_AWS_S3_BUCKET
#   HUBOT_AWS_S3_URL
#
# Commands:
#   hubot ec2 console <instance_id> - Retreive a screenshot of a running instance to help with troubleshooting.
#
# Notes:
#   You'll need to configure the above environment variables for your environment.
#
#   The S3Bucket Var is the 'short name'. Used to identify which bucket s3.putObject will upload too. eg - 'my-bucket'
#
#   The FullS3URL is the full URL of where the files will live in the bucket. Used to build the URL
#   as the URL is not returned when you upload a file. - eg - 'https://s3-ap-southeast-2.amazonaws.com/my-bucket/'
#  
# Author:
#   John Szaszvari <jszaszvari@gmail.com>
#

S3Bucket = process.env.HUBOT_AWS_S3_BUCKET
FullS3URL = process.env.HUBOT_AWS_S3_URL

aws = require('../aws.coffee').aws()
ec2 = new (aws.EC2)
s3 = new (aws.S3)(apiVersion: '2006-03-01')

module.exports = (robot) ->
  robot.respond /ec2 console (.*)/i, (res) ->
      
      #Used to generate a random file name. Did not want to use a external library. 
      fileSuffix = ->
        text = ''
        possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
        i = 0
        while i < 20
          text += possible.charAt(Math.floor(Math.random() * possible.length))
          i++
        text
      id = res.match[1]
      ConsoleScreenshotParams =
      InstanceId: id
      DryRun: false
      WakeUp: true
      FileName = id + '-' + fileSuffix() + '.png'

      #Get the Console Screenshot
      ScreenshotRequest = ec2.getConsoleScreenshot(ConsoleScreenshotParams, (err, data) ->
        if err
          res.send "Error: The EC2 Instance ID privided was invalid."
          console.log err, err.stack
        else
          res.send "Fetching Console Screenshot...."
          console.log 'Succss'

        base64Data = ScreenshotRequest.response.data.ImageData
        buf = new Buffer(base64Data, 'base64')
        
        S3Params =
          Bucket: S3Bucket
          ContentType: 'image/png'
          Body: buf
          Key: FileName
          
        #Stream the data into the bucket. Streams the base64 image returned by AWS direct into the bucket.
        s3.putObject S3Params, (err, data) ->
          if err
            console.log err
            console.log 'Error uploading image to S3: ', data
          else
            console.log 'Success - The image URL is: ' + FullS3URL + FileName
            
            #If the attachement version is not working
            #Uncomment the line below so that the bot posts the
            #URL in the channel instead of the 'attachment'.
        
            #res.send FullS3URL + FileName
            
            #Post the nicer attachment version of the image.
            #Have tested with Slack and Rocket.Chat and works well.
            res.send({
             # channel: 'gCCmdeFSQJFoLRigB',
              attachments: [
                {
                  title: "EC2 Console Screenshot",
                  title_link: FullS3URL + FileName,
                  text: "EC2 Console screenshot for instance ID " + id,
                  image_url: FullS3URL + FileName
                }
              ]
            });
          return
          console.log err
          return
        return
      )
