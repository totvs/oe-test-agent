import { Config } from "protractor";

const propath = `${__dirname.replace(/\\/g, "/")}/abl`;

export const config: Config = {
  capabilities: {
    browserName: "chrome",
    chromeOptions: {
      args: ["--headless", "--disable-gpu"]
    }
  },

  directConnect: true,

  params: {
    oeConfig: {
      host: "localhost",
      port: 2091,
      dlcHome: "C:/dlc117",
      outDir: "C:/tmp",
      propath: [propath]
    }
  },

  suites: {
    oeRobot: [ "alertboxes.spec.js", "screenshot.spec.js", "systemdialog.spec.js" ],
    widgets: ["widgets.spec.js"]
  }
};
