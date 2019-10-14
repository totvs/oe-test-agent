import { browser } from 'protractor';

import { OEAgent, OEButtons, OEConfig, Keys } from '../dist';

describe('System Dialogs', () => {
  const oe = new OEAgent();
  const title = 'Choose Procedure to run...';

  beforeAll(() => {
    const config = browser.params.oeConfig as OEConfig;
    oe.start(config);
    oe.run('systemdialog-getfile.p');
  });

  it('should send the procedure filename to the system dialog', () => {
    const procname = `${__dirname}\\abl\\not-existent-file.p`;

    oe.windowSendKeys(title, procname);
    oe.alertClick(title, OEButtons.OK);

    expect(oe.windowExists(procname, 1_000)).toBeTruthy();
    oe.alertClick(procname, OEButtons.OK);
  });

  afterAll(() => oe.quit());
});
