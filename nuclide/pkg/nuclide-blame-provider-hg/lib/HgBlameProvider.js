'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _asyncToGenerator = _interopRequireDefault(require('async-to-generator'));

let doGetBlameForEditor = (() => {
  var _ref = (0, _asyncToGenerator.default)(function* (editor) {
    const path = editor.getPath();
    if (!path) {
      return Promise.resolve([]);
    }

    const repo = (0, (_common || _load_common()).hgRepositoryForEditor)(editor);
    if (!repo) {
      const message = `HgBlameProvider could not fetch blame for ${path}: no Hg repo found.`;
      logger.error(message);
      throw new Error(message);
    }

    return repo.getBlameAtHead(path);
  });

  return function doGetBlameForEditor(_x) {
    return _ref.apply(this, arguments);
  };
})();

var _common;

function _load_common() {
  return _common = require('./common');
}

var _nuclideAnalytics;

function _load_nuclideAnalytics() {
  return _nuclideAnalytics = require('../../nuclide-analytics');
}

var _nuclideLogging;

function _load_nuclideLogging() {
  return _nuclideLogging = require('../../nuclide-logging');
}

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 *
 * 
 */

const logger = (0, (_nuclideLogging || _load_nuclideLogging()).getLogger)();

function canProvideBlameForEditor(editor) {
  if (editor.isModified()) {
    atom.notifications.addInfo('There is Hg blame information for this file, but only for saved changes. ' + 'Save, then try again.');
    logger.info('nuclide-blame: Could not open Hg blame due to unsaved changes in file: ' + String(editor.getPath()));
    return false;
  }
  const repo = (0, (_common || _load_common()).hgRepositoryForEditor)(editor);
  return Boolean(repo);
}

function getBlameForEditor(editor) {
  return (0, (_nuclideAnalytics || _load_nuclideAnalytics()).trackTiming)('blame-provider-hg:getBlameForEditor', () => doGetBlameForEditor(editor));
}

let getUrlForRevision;
try {
  // $FlowFB
  const { getPhabricatorUrlForRevision } = require('./fb/FbHgBlameProvider');
  getUrlForRevision = getPhabricatorUrlForRevision;
} catch (e) {
  // Ignore case where FbHgBlameProvider is unavailable.
}

exports.default = {
  canProvideBlameForEditor,
  getBlameForEditor,
  getUrlForRevision
};
module.exports = exports['default'];