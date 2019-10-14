import { browser } from 'protractor';

import { OEAgent, OEButtons, OEConfig } from '../dist';

describe('Alert Boxes', () => {
  const oe = new OEAgent();
  oe.setDefaultTimeout(1_000);

  beforeAll(() => {
    const config = browser.params.oeConfig as OEConfig;
    oe.start(config);
    oe.run('alertboxes.p');
  });

  it('should click on the OK button of the message', () => {
    oe.alertClick('Message', OEButtons.OK);

    // Wait the alert box to be closed.
    browser.sleep(50);
    expect(oe.windowExists('Message', 1_000)).toBeFalsy();
  });

  it('should click on the OK button of the message with a custom title', () => {
    oe.alertClick('Custom Title', OEButtons.OK);

    // Wait the alert box to be closed.
    browser.sleep(50);
    expect(oe.windowExists('Custom Title', 1_000)).toBeFalsy();
  });

  it('should click on the YES button of the question message', () => {
    oe.alertClick('Pergunta|Question', OEButtons.YES);
    expect(oe.windowExists('YES')).toBeTruthy();
    oe.alertClick('YES', OEButtons.OK);
  });

  it('should click on the NO button of the question message', () => {
    oe.alertClick('Question', OEButtons.NO);
    expect(oe.windowExists('NO')).toBeTruthy();
    oe.alertClick('NO', OEButtons.OK);
  });

  it('should click on the CANCEL button of the question message', () => {
    oe.alertClick('Question', OEButtons.CANCEL);
    expect(oe.windowExists('CANCEL')).toBeTruthy();
    oe.alertClick('CANCEL', OEButtons.OK);
  });

  it('should click on the OK button of the information message', () => {
    oe.alertClick('Information', OEButtons.OK);
    expect(oe.windowExists('Information', 1_000)).toBeFalsy();
  });

  it('should click on the CANCEL button of the error message', () => {
    oe.alertClick('Error', OEButtons.CANCEL);
    expect(oe.windowExists('CANCEL')).toBeTruthy();
    oe.alertClick('CANCEL', OEButtons.OK);
  });

  it('should click on the RETRY button of the error message', () => {
    oe.alertClick('Warning', OEButtons.RETRY);
    expect(oe.windowExists('RETRY')).toBeTruthy();
    oe.alertClick('RETRY', OEButtons.OK);
  });

  afterAll(() => oe.quit());
});
