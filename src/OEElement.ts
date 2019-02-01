import { OEAgent } from './OEAgent';
import { OEAttributes } from './OEAttributes.enum';
import { OEEvents } from './OEEvents.enum';

export class OEElement {
  public id!: number;

  constructor(private oe: OEAgent) {}

  public isValid(): Promise<boolean> {
    return this.oe.isElementValid(this);
  }

  /**
   * Wait until an OE child widget is found with the informed name attribute or
   * a timeout error is raised.
   *
   * @param name Widget ```NAME``` attribute.
   * @param visible ```true``` to only search visible elements.
   * @param timeout Waiting timeout.
   *
   * @returns Widget ```OEElement``` instance.
   */
  public waitForElement(name: string, visible = true, timeout?: number): OEElement {
    return this.oe.waitForElement(name, visible, timeout, this);
  }

  /**
   * Searches for an OE child widget with the informed name attribute.
   *
   * @param name Widget ```NAME``` attribute.
   * @param visible ```true``` to only search visible elements.
   *
   * @returns Widget ```OEElement``` instance.
   */
  public findElement(name: string, visible = true): OEElement {
    return this.oe.findElement(name, visible, this);
  }

  /**
   * Search for an OE child widget with the value of the informed attribute.
   *
   * @param attr Attribute name.
   * @param value Attribute value.
   * @param visible ```true``` to only search visible elements.
   *
   * @returns Widget ```OEElement``` instance.
   */
  public findElementByAttribute(attribute: OEAttributes, value: string, visible = true): OEElement {
    return this.oe.findElementByAttribute(attribute, value, visible, this);
  }

  /**
   * Return this widget ```SENSITIVE``` value.
   * @returns A promise result data of the command.
   */
  public isEnabled(): Promise<boolean> {
    return this.get(OEAttributes.SENSITIVE).then((enabled: string) => enabled === 'true' || enabled === 'yes');
  }

  /**
   * Return this widget ```CHECKED``` value.
   * @returns A promise result data of the command.
   */
  public isChecked(): Promise<boolean> {
    return this.get(OEAttributes.CHECKED).then((checked: string) => checked === 'true' || checked === 'yes');
  }

  /**
   * Clears this widget ```SCREEN-VALUE```.
   * @returns This widget ```OEElement``` instance.
   */
  public clear(): OEElement {
    this.oe.clear(this);
    return this;
  }

  /**
   * Changes this widget ```SCREEN-VALUE```.
   *
   * @param value Widget's new ```SCREEN-VALUE```.
   * @returns This widget ```OEElement``` instance.
   */
  public sendKeys(keys: string | number): OEElement {
    this.oe.sendKeys(keys, this);
    return this;
  }

  /**
   * Returns this widget ```SCREEN-VALUE```.
   * @returns A promise result data of the command.
   */
  public getValue(): Promise<string> {
    return this.get(OEAttributes.SCREENVALUE);
  }

  /**
   * Checks/Unchecks this TOGGLE-BOX widget.
   *
   * @param check ```true``` to check the widget.
   * @returns This widget ```OEElement``` instance.
   */
  public check(check: boolean): OEElement {
    this.oe.check(check, this);
    return this;
  }

  /**
   * Selects a value in this COMBO-BOX or RADIO-SET widget.
   *
   * @param value Selection value.
   * @param partial ```true``` if it's a partial value.
   *
   * @returns This widget ```OEElement``` instance.
   */
  public select(value: string | number, partial = false): OEElement {
    this.oe.select(value, partial, this);
    return this;
  }

  /**
   * Selects a row in this BROWSE widget.
   *
   * @param row Row number.
   * @returns This widget ```OEElement``` instance.
   */
  public selectRow(row: number): OEElement {
    this.oe.selectRow(row, this);
    return this;
  }

  /**
   * Moves the QUERY result pointer of this BROWSE widget to the specified row.
   *
   * @param row Row number.
   * @returns This widget ```OEElement``` instance.
   */
  public repositionToRow(row: number): OEElement {
    this.oe.repositionToRow(row, this);
    return this;
  }

  /**
   * Fire this widget ```CHOOSE``` event.
   * @returns This widget ```OEElement``` instance.
   */
  public choose(): OEElement {
    this.oe.choose(this);
    return this;
  }

  /**
   * Sends an ```APPLY``` command with an event to this widget.
   *
   * @param event Event name.
   * @param wait ```true``` to wait the ```APPLY``` event.
   *
   * @returns This widget ```OEElement``` instance.
   */
  public apply(apply: OEEvents | string, wait = false): OEElement {
    this.oe.apply(apply, this, wait);
    return this;
  }

  /**
   * Gets this widget's informed attribute value.
   *
   * @param attr Attribute name.
   * @returns A promise result data of the command.
   */
  public get(attribute: OEAttributes): Promise<string> {
    return this.oe.get(attribute, this);
  }

  /**
   * Sets this widget's informed attribute value.
   *
   * @param attr Attribute name.
   * @param value Attribute value.
   *
   * @returns This widget ```OEElement``` instance.
   */
  public set(attribute: OEAttributes, value: string): OEElement {
    this.oe.set(attribute, value, this);
    return this;
  }
}
