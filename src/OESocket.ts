import * as net from 'net';
import { promise } from 'protractor';

import { MessageType, OEUtils } from './OEUtils';

export class OESocket {
  private client!: net.Socket;
  private isConnected = false;

  public connect(host: string, port: number): OEResultConn {
    return new Promise((resolve, reject) => {
      this.client = new net.Socket();

      const connect = () => this.client.connect(port, host);
      const retries = 5;

      connect();

      this.client.on('connect', () => this.onConnect(resolve));
      this.client.on('close', () => this.onClose());
      this.client.on('error', (error) => this.onError(connect, retries, error, reject));
    });
  }

  public connected(): boolean {
    return this.isConnected;
  }

  public close(): void {}

  public send(showError = true, wait: boolean, ...args: any[]): OEResultData {
    return new Promise((resolve, reject) => {
      const message = `${wait}|${args.join('|')}`;
      OEUtils.consoleLogMessage(`Sending data: "${message}"`, MessageType.INFO);

      this.client.write(message);

      if (wait) {
        this.client.once('data', (data: Buffer) => this.onData(data.toString('utf-8'), showError).then(resolve).catch(reject));
      } else {
        resolve();
      }
    });
  }

  private onConnect(resolve): void {
    this.isConnected = true;
    resolve(true);
  }

  private onData(data: string, showError = true): OEResultData {
    let promise;

    const output = data.split('|');
    const status = output[0].toUpperCase();
    const result = output.length > 1 ? output[1] : undefined;

    if (status !== 'NOK') {
      OEUtils.consoleLogMessage(`Data received: "${data}"`, MessageType.SUCCESS);
      promise = Promise.resolve(result);
    } else {
      if (showError) {
        OEUtils.consoleLogMessage(`Data received: "${data}"`, MessageType.ERROR);
      }

      promise = Promise.reject(new Error(result));
    }

    return promise;
  }

  private onClose(): void {}

  private onError(connect: Function, retries: number, error: Error, reject: Function): void {
    retries--;

    if (retries > 0) {
      setTimeout(connect, 1000);
    } else {
      reject(error);
    }
  }
}

export interface OEResultData extends promise.Promise<any> {} // Will always return a string as a result.
export interface OEResultConn extends promise.Promise<boolean> {} // Will always return "true" or a Error instance.
