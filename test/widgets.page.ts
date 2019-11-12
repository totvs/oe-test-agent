import { oeAgent, OEElement, OEEvents } from "../dist";

class Options {
  public static readonly OPTION_1 = { VALUE: 1, LABEL: "Option 1" };
  public static readonly OPTION_2 = { VALUE: 2, LABEL: "Option 2" };
  public static readonly OPTION_3 = { VALUE: 3, LABEL: "Option 3" };
}

export class WidgetsPage {
  private window: OEElement;
  public static readonly OPTIONS = Options;

  public run() {
    oeAgent.run("widgets.w");
    this.window = oeAgent.waitForWindow("Widgets");
  }

  public getWindow(): OEElement {
    return this.window;
  }

  public getComboList(): OEElement {
    return this.window.findElement("cComboList");
  }

  public getComboPairs(): OEElement {
    return this.window.findElement("cComboPair");
  }

  public getRadioList(): OEElement {
    return this.window.findElement("cRadioList");
  }

  public quit() {
    this.window.apply(OEEvents.WINDOWCLOSE);
  }
}
