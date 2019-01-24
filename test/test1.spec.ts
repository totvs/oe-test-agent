import { browser } from 'protractor';

import { OEAgent, OEConfig, OEElement, OEEvents } from '../dist';

describe('Sample CustOrderMenu', () => {
  const oe = new OEAgent();
  let custOrderMenuWindow: OEElement;

  beforeAll(() => {
    const config: OEConfig = {
      host: 'localhost',
      port: 2901,
      dlcHome: 'C:/dlc116',
      outDir: 'C:/tmp',
      propath: ['C:/ABL/examples/prodoc/handbook', 'C:/ABL/samples'],
      parameterFile: 'C:/ABL/progress.pf'
    };

    oe.start(config);
  });

  it('should execute CustOrderMenu application', () => {
    oe.run('h-CustOrderMenu.w'); // Execute the OpenEdge application.

    custOrderMenuWindow = oe.waitForWindow('Customers and Orders'); // Get the HANDLE of the application's window.
    browser.call(() => expect(custOrderMenuWindow.id).toBeDefined()); // Important to call "expect" inside "browser.call" in this case.
  });

  it('should go to the first record', () => {
    const firstButton = custOrderMenuWindow.findElement('BtnFirst');
    firstButton.choose();

    const custNum = custOrderMenuWindow.findElement('CustNum');
    expect(custNum.getValue()).toBe('1');
  });

  it('should go to the next record', () => {
    const firstButton = custOrderMenuWindow.findElement('BtnNext');
    firstButton.choose();

    const custNum = custOrderMenuWindow.findElement('CustNum');
    expect(custNum.getValue()).toBe('2');
  });

  it('should go to the previous record', () => {
    const firstButton = custOrderMenuWindow.findElement('BtnPrev');
    firstButton.choose();

    const custNum = custOrderMenuWindow.findElement('CustNum');
    expect(custNum.getValue()).toBe('1');
  });

  it('should go to the last record', () => {
    const firstButton = custOrderMenuWindow.findElement('BtnLast');
    firstButton.choose();

    const custNum = custOrderMenuWindow.findElement('CustNum');
    expect(custNum.getValue()).toBe('2106');
  });

  afterAll(() => {
    custOrderMenuWindow.apply(OEEvents.WINDOWCLOSE);
    oe.quit();
  });
});
