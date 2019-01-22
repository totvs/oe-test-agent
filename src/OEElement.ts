import { OEAgent } from './OEAgent';
import { OEAttributes } from './OEAttributes.enum';
import { OEEvents } from './OEEvents.enum';
import { OEResultData } from './OESocket';

export class OEElement {
  public id!: number;

  constructor(private oe: OEAgent) {}

  public findElement(name: string, visible = true): OEElement {
    return this.oe.findElement(name, visible, this);
  }

  public findElementByAttribute(attribute: OEAttributes, value: string, visible = true): OEElement {
    return this.oe.findElementByAttribute(attribute, value, visible, this);
  }

  public waitForElement(name: string, visible = true, timeout?: number): OEElement {
    return this.oe.waitForElement(name, visible, timeout, this);
  }

  public choose(): OEElement {
    this.oe.choose(this);
    return this;
  }

  public apply(apply: OEEvents | string): OEElement {
    this.oe.apply(apply, this);
    return this;
  }

  public get(attribute: OEAttributes): OEResultData {
    return this.oe.get(attribute, this);
  }

  public set(attribute: OEAttributes, value: string): OEElement {
    this.oe.set(attribute, value, this);
    return this;
  }

  public getValue(): OEResultData {
    return this.get(OEAttributes.SCREENVALUE);
  }

  public selectRow(row: number): OEElement {
    this.oe.selectRow(row, this);
    return this;
  }

  /**
   * Moves a QUERY object result pointer of the informed BROWSE widget to the
   * specified row.
   *
   * @param row Row number.
   * @returns The element itself.
   */
  public repositionToRow(row: number): OEElement {
    this.oe.repositionToRow(row, this);
    return this;
  }

  /**
   * Check/Uncheck a TOGGLE-BOX widget.
   *
   * @param check ```true``` to check the widget.
   * @returns The element itself.
   */
  public check(check: boolean): OEElement {
    this.oe.check(check, this);
    return this;
  }

  /**
   * Select a value in a COMBO-BOX widget.
   *
   * @param value Selection value.
   * @param partial ```true``` to select the value even if it's partial.
   *
   * @returns The element itself.
   */
  public select(value: string | number, partial = false): OEElement {
    this.oe.select(value, partial, this);
    return this;
  }

  public clear(): OEElement {
    this.oe.clear(this);
    return this;
  }

  public sendKeys(keys: string | number): OEElement {
    this.oe.sendKeys(keys, this);
    return this;
  }

  public isEnabled(): OEResultData {
    return this.get(OEAttributes.SENSITIVE).then((enabled: string) => enabled === 'true');
  }

  public isChecked(): OEResultData {
    return this.get(OEAttributes.CHECKED).then((checked: string) => checked === 'true');
  }
}
