import * as fs from 'fs';
import { browser } from 'protractor';

import { OEAgent, OEConfig, OEEvents } from '../dist';

describe('Screenshot', () => {
  const oe = new OEAgent();
  const screenshot = `${__dirname.replace(/\\/g, '/')}`;
  const screenshots: string[] = [];

  beforeAll(() => {
    const config = browser.params.oeConfig as OEConfig;
    oe.start(config);
    oe.run('helloworld.p');
  });

  fit('should take a screenshot of a window', () => {
    const file = oe.takeScreenshot(screenshot, 'Hello World');
    file.then(filename => screenshots.push(filename));
    expect(file.then(filename => fs.existsSync(filename))).toBeTruthy();
  });

  fit('should take a screenshot of the process windows', () => {
    const files = oe.takeScreenshotFromProcess(screenshot, 'prowin32.exe');
    files.then(filenames => filenames.forEach(filename => screenshots.push(filename)));
    files.then(filenames => filenames.forEach(filename => expect(fs.existsSync(filename)).toBeTruthy()));
  });

  afterAll(() => {
    screenshots.forEach(screenshot => fs.unlinkSync(screenshot));
    oe.waitForWindow('Hello World').apply(OEEvents.WINDOWCLOSE);
    oe.quit();
  });
});
