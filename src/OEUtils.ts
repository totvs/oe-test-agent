import { bgRed, gray, green, red, yellow } from 'colors';

/**
 * Message type enum.
 * This should be used together with ```OEUtils.consoleLogMessage```.
 */
export enum MessageType {
  INFO = 1,
  WARNING = 2,
  ERROR = 3,
  SUCCESS = 4,
  FATAL = 5
}

export class OEUtils {
  /**
   * Shows a console message.
   *
   * @param message Message text.
   * @param type Message type.
   */
  public static consoleLogMessage(message: string, type: MessageType): void {
    let text: string;

    switch (type) {
      default:
      case MessageType.INFO:
        text = gray(`[OE TEST AGENT] ${message}.`);
        break;
      case MessageType.WARNING:
        text = yellow(`[OE TEST AGENT] ${message}.`);
        break;
      case MessageType.ERROR:
        text = red(`[OE TEST AGENT] ${message}.`);
        break;
      case MessageType.SUCCESS:
        text = green(`[OE TEST AGENT] ${message}.`);
        break;
      case MessageType.FATAL:
        text = bgRed(`[OE TEST AGENT] ${message}.`);
        break;
    }

    const date = new Date();
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    const seconds = date.getSeconds().toString().padStart(2, '0');

    console.log(`[${hours}:${minutes}:${seconds}] ${text}`);
  }
}
