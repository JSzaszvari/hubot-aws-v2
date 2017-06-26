# hubot-aws-v2
This is a hubot plugin to interact with AWS thats had some enhancements made compared to what is available. 

This is very much a work in progress and has bugs. Please feel free to report any here on GitHub and Pull Requests are more than welcome.

This comes pre bundled with the basic hubot components to quickly get started otherwise you can install the scripts into your own hubot install.


# Known Issues
* These plugins only work with Rocket.Chat and Slack at the moment. It may very well work with other chat systems, but these are the only two that I have tested for consistant functionality. 

* The filter when listing instances is case sensitve. 



# Setup
The following environment variables must be set before this pacakge will start working. (In addition to any that need to be set for the particular adapter that you are using)

Environment Variable | Description | Example
:---- | :---- | :----
HUBOT_AWS_ACCESS_KEY_ID | AWS Access Key | AKIAJXXXXXXSSSSQYZKQ
HUBOT_AWS_SECRET_ACCESS_KEY | AWS Secret Access Key | tSEz9uvDXXXXXXXqO5yXXFGmXXnXXGXXZRj8XXXX
HUBOT_AWS_REGION | Main AWS Region you will be interacting with. | ap-southeast-2
HUBOT_AWS_S3_BUCKET | Bucket Short-Name used at the moment only to store screenshots retrieved with the Console Screenshot script. | my-bucket/console-screenshots
HUBOT_AWS_S3_URL | URL including folder path of where the console screenshots will be stored. This is used to build the URL where the screenshot is stored. | https://s3-ap-southeast-2.amazonaws.com/my-bucket/console-screenshots/

### Running the bundled hubot 
Inside the repo folder run 

```
npm install
```

Then start the bot with 

```
bin/hubot -a rocketchat
```

or

```
bin/hubot -a slack
```

Depending on what chat software you use. 

### Using the plugins on a exisiting hubot install
Copy the following files into your own hubot install

* aws.coffee
* scripts/ec2_console_screenshot.coffee
* scripts/ec2_list.coffee

aws.coffee shoukd be in the hubot root as its included by all the scripts to set the auth environment vars.

# Commands 
See screenshots at the end to see what the output looks like. 

### aws ec2 ls
Will return a complete listing of your EC2 Instances under the configured region. 

### aws ec2 ls < Filter > 
```
aws ec2 ls SQL 
```
This will filter the list by the Name tag in AWS.

So running the above will only return results where SQL is anywhere in the "Name" tag.

### aws ec2 console < Instance ID> 
```
aws ec2 console i-077f7532a8f58cabf
```

Generates and captures a screenshot of the instance console. Very useful if the instance has become unreachable via SSH or RDP - the physical console often contains log messages or other clues that can be used to identify and understand what’s going on when things are not working as expected.

# To-Do
* Re-implement roles so that only users with a particular role can execute the commands. 
* Fix up case sensitivty on the instance listing 
* Test with more adapters instead of just rocket.chat and slack

# Screenshots
![list][ec2_list_screenshot.png]

![console][ec2_console_screenshot.png]