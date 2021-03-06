# OE Test Agent

<p align="center">
  <img src="https://raw.githubusercontent.com/totvs/oe-test-agent/master/resources/oe_test_agent_logo.png" width="500" height="200">
</p>

<p align="center">
  An e2e tool for <strong>Progress OpenEdge</strong> applications with <strong>Protractor</strong>
</p>

## Quick start

The **OE Test Agent** was developed in order to make our e2e test for OpenEdge applications easier.

Our dev team was already familiar with [**Protractor**](https://www.protractortest.org), so we took advantage of that to create this project using only _socket_ communication between JavaScript and OE and an external tool - also created by us - called ["Robot"](#robotexe).

In other words, the **OE Test Agent** acts as a web driver of Protractor, allowing it to interact with OpenEdge applications as a user would. We also built a set of [TypeScript](https://www.typescriptlang.org) libraries for helping developers to manipulate widgets, properties and events of OpenEdge applications, so that you can easily write tests in a traditional behavior-driven development style.

## Installation

```bash
npm i oe-test-agent
```

## Changelog

### **1.1.13**

- Solved a bug when using `select` to a value of a `COMBO-BOX` with `LIST-ITEM-PAIRS`.

### **1.1.7**

- Solved a bug when using `select` to a value of a `RADIO-SET` widget.

### **1.1.6**

- Solved a bug when using `select` to an invalid value.

### **1.1.5**

- Solved a bug when running an OE application without having the source (`.p`)
  in the PROPATH.
- Solved a bug when taking a screenshot of a window.

### **1.1.4**

- The method `takeScreenshot` was changed to return the image filenames.
- Created the method `takeScreenshotFromProcess` to take a screenshot from each
  window of a process.

### **1.1.3**

- Now it's possible to send a string value at `windowSendKeys` method.
- **Brazilian Portuguese** titles are now supported at `alertClick` methods.
- Now it's possible to send more than one title to `Robot` find a window -
  delimited by | characters.
- Created the method `takeScreenshot` to take an OS screenshot and return the
  `Base64` value from the image.
- Now it's possible to update the default timeout value.

### **1.1.2**

- Solved a bud when using `select` method with a `SELECT` widget.

### **1.1.1**, **1.1.0**:

#### **BREAKING CHANGES**

- The `delete` method was redefined to expect a where clause and not an object anymore
- The returns was changed to return only a `Promise<boolean>`

### **1.0.11**:

- Solved a bug when enabling coverage

### **1.0.7**, **1.0.8**, **1.0.9**, **1.0.10**:

- Solved a bug on the socket communication
- Removed unused dependencies

### **1.0.6**:

- Solved a bug where OEElement `isElementValid` method was always returning true
- Improvements made at `waitForWindow` and `waitForElement` methods

### **1.0.5**:

- Socket communication improvements
- Created a method to return if an `OEElement` is valid or not
- Created an `OEAgent` singleton instance to use at e2e that uses Page Objects

### **1.0.4**:

- Removed unused dependency
- Created `Keys` enum - to use with `windowSendKeys`
- Created static attribute DEFAULT_TIMEOUT - to use with `waitFor` methods
- `ENTRY` event is now fired when using `select` and `check`

### **1.0.3**:

- Solved a bug when searching for elements using `waitForElement` or `findElement`
- When executing `selectRow` for a empty BROWSE, no errors will be throw
- Improvements on the socket communication
- Changed return type to JavaScript's `Promise` instead of Protractor's `promise.Promise`
- Included console messages when using "Robot"
- Will set profiler's file only if none was defined

### **1.0.2**:

- README.md changes

### **1.0.1**:

- Documentation

## Want to help?

You're welcome to open an issue to report bugs, suggest improvements on this GitHub or to submit a PR.

## Other tools

In order to make this project work with all kinds of Progress OpenEdge applications, besides the _socket_ communication, we had to build an auxiliary tool that we decided to call "Robot".

### Robot.exe

If you are familiar with Progress OE applications, you probably know that visual messages - with `VIEW-AS ALERT-BOX` attributes - block every other execution until the user closes the current message.

To solve that, we created "Robot.exe". This tool - built using ["Auto It"](https://www.autoitscript.com) - simulates a mouse click to the opened message and can also send keyboard events to any other Windows application that is currently open.

> **Heads up!** You may need to sign "Robot.exe" with a valid certificate or add it to your antivirus whitelist.
