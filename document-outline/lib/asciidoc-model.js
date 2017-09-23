'use babel';
import AbstractModel from './abstract-model';

// const HEADING_REGEX = /^(.+)\n([!-/:-@[-`{-~])\2+$/gm;
const HEADING_REGEX = /^([=#]+)\s*(.+)$/gm;

export default class AsciiDocModel extends AbstractModel {
  constructor(editorOrBuffer) {
    super(editorOrBuffer, HEADING_REGEX);
    this.sectionLevels = {};
  }

  getRegexData(scanResult) {
    return {
      level: scanResult[1].length,
      label: scanResult[2]
    };

    let level = 1;
    let c = scanResult[2].substr(0, 1);

    // Sometimes sectionLevels not set. Shouldn't happen but cant be bother to figure out why it does
    if (this.sectionLevels === undefined) {
      this.sectionLevels = {};
    }

    if (c in this.sectionLevels) {
      level = this.sectionLevels[c];
    } else {
      level = Object.keys(this.sectionLevels).length + 1;
      this.sectionLevels[c] = level;
    }
    return {
      level: level,
      label: scanResult[1]
    };
  }

}
