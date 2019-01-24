<p align="center">
  <img src="https://raw.githubusercontent.com/totvs/oe-test-agent/master/resources/oe_test_agent_logo.png" width="500" height="200">
</p>

<h3 align="center">OE Test Agent</h3>

<p align="center">
  An e2e tool for <strong>Progress OpenEdge</strong> applications with <strong>Protractor</strong>
</p>

# Quick start

The **OE Test Agent** was developed in order to make our e2e test for OpenEdge applications easier.

As our dev team was already familiar with **Protractor**, we took advantage of that to create this project, using only *socket* communication, between JavaScript and OE, and an external tool - also created by us - called ["Robot"](#robot.exe).

# Installation

```bash
npm i oe-test-agent
```

# Changelog

- **1.0.1**: Documentation.


# Want to help?

You're welcome to open a issue with bugs and improvements on this GitHub or to make us a PR.


# Other tools

In order to make this project to work with all kind of Progress OpenEdge applications, besides the *socket* communication, we needed to build an auxiliar tool that we decided to call "Robot".

## Robot.exe

If you are familiar with Progress OE applications, you probably know that visual messages - with ```VIEW-AS ALERT-BOX``` attributes - block all other execution until the user closes the current opened message.

To solve that we create "Robot.exe", this tool - built using ["Auto It"](https://www.autoitscript.com) - simulates a mouse click to the opened message and also can send keyboard events to any other Windows opened application.

> **Heads up!** You may need to sign "Robot.exe" with a valid certificate or put it on your antivirus whitelist.


# Sample Test

> At this point we assume that you've already did a ```npm install``` command for this project.

To test our sample, first you need to download both ZIP files available [here](https://community.progress.com/community_groups/openedge_general/w/openedgegeneral/1162.download-11-0-documentation-example-procedure-and-sample-files). Create a folder called "ABL" and extract the examples in the "examples" folder and the samples in the "samples" folder, both of them inside "ABL". In our case the "ABL" folder is available at C:\\, but your structure should be similar as bellow:

```bash
C:\
└── ABL/
    ├── examples/
    │   ├── prodoc/
    ├── samples/
    │   ├── src/
    │   ├── tutorial/
    │   ├── webinstall/
```

Inside the "ABL" folder, create a parameter file ```progress.pf``` with the content bellow:

```ini
# Change C:/dlc116 with your own DLC home.
-db C:/dlc116/sports2000.db -1
-clientlog C:\tmp\oe-test-agent.log
```

In a command line prompt, navigate to the ```test``` folder inside the ```oe-test-agent``` project and type: ```npm run test```. If everything is correct, your test should start and run without any problems.

![npm-test](https://raw.githubusercontent.com/totvs/oe-test-agent/master/resources/npm-test.gif "npm test")