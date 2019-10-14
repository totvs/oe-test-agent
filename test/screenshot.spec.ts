import { OEAgent } from '../dist';

describe('Screenshot', () => {
  const oe = new OEAgent();
  const screenshot = `${__dirname.replace(/\\/g, '/')}/screenshot.png`;

  it('should take and save a screenshot file', () => {
    expect(oe.takeScreenshot(screenshot)).not.toBeNull();
  });
});
