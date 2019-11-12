import { browser } from "protractor";

import { oeAgent, OEConfig } from "../dist";
import { WidgetsPage } from "./widgets.page";

describe("Widgets", () => {
  const widgetsPage = new WidgetsPage();

  beforeAll(() => {
    const config = browser.params.oeConfig as OEConfig;
    oeAgent.start(config);
  });

  it('should open the "Widgets" window', () => {
    widgetsPage.run();
    expect(widgetsPage.getWindow().isValid()).toBeTruthy();
  });

  it("should select the item of an COMBO-BOX defined with LIST-ITEMS by its label", () => {
    const combo = widgetsPage.getComboList();
    combo.select(WidgetsPage.OPTIONS.OPTION_2.LABEL);
    expect(combo.getValue()).toBe(WidgetsPage.OPTIONS.OPTION_2.LABEL);
  });

  it("should select the item of an COMBO-BOX defined with LIST-ITEM-PAIRS by its value", () => {
    const combo = widgetsPage.getComboPairs();
    combo.select(WidgetsPage.OPTIONS.OPTION_3.VALUE);
    expect(combo.getValue()).toBe(WidgetsPage.OPTIONS.OPTION_3.VALUE.toString());
  });

  it("should select the item of an COMBO-BOX defined with LIST-ITEM-PAIRS by its label", () => {
    const combo = widgetsPage.getComboPairs();
    combo.select(WidgetsPage.OPTIONS.OPTION_2.LABEL, true);
    expect(combo.getValue()).toBe(WidgetsPage.OPTIONS.OPTION_2.VALUE.toString());
  });

  it("should select the item of an COMBO-BOX by its value", () => {
    const radio = widgetsPage.getRadioList();
    radio.select(WidgetsPage.OPTIONS.OPTION_1.VALUE);
    expect(radio.getValue()).toBe(WidgetsPage.OPTIONS.OPTION_1.VALUE.toString());
  });

  it("should select the item of an RADIO-SET by its label", () => {
    const radio = widgetsPage.getRadioList();
    radio.select(WidgetsPage.OPTIONS.OPTION_3.LABEL, true);
    expect(radio.getValue()).toBe(WidgetsPage.OPTIONS.OPTION_3.VALUE.toString());
  });

  afterAll(() => {
    widgetsPage.quit();
    oeAgent.quit();
  });
});
