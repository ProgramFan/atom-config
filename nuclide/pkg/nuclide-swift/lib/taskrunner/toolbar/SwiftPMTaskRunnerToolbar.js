'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _reactForAtom = require('react-for-atom');

var _AtomInput;

function _load_AtomInput() {
  return _AtomInput = require('../../../../nuclide-ui/AtomInput');
}

var _Button;

function _load_Button() {
  return _Button = require('../../../../nuclide-ui/Button');
}

var _SwiftPMSettingsModal;

function _load_SwiftPMSettingsModal() {
  return _SwiftPMSettingsModal = _interopRequireDefault(require('./SwiftPMSettingsModal'));
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

class SwiftPMTaskRunnerToolbar extends _reactForAtom.React.Component {

  constructor(props) {
    super(props);
    this.state = { settingsVisible: false };
    this._onChdirChange = this._onChdirChange.bind(this);
  }

  render() {
    return _reactForAtom.React.createElement(
      'div',
      { className: 'nuclide-swift-task-runner-toolbar' },
      _reactForAtom.React.createElement((_AtomInput || _load_AtomInput()).AtomInput, {
        className: 'inline-block',
        size: 'sm',
        value: this.props.store.getChdir(),
        onDidChange: chdir => this._onChdirChange(chdir),
        placeholderText: 'Relative path to Swift package',
        width: 400
      }),
      _reactForAtom.React.createElement((_Button || _load_Button()).Button, {
        className: 'nuclide-swift-settings icon icon-gear',
        size: (_Button || _load_Button()).ButtonSizes.SMALL,
        onClick: () => this._showSettings()
      }),
      this.state.settingsVisible ? _reactForAtom.React.createElement((_SwiftPMSettingsModal || _load_SwiftPMSettingsModal()).default, {
        configuration: this.props.store.getConfiguration(),
        Xcc: this.props.store.getXcc(),
        Xlinker: this.props.store.getXlinker(),
        Xswiftc: this.props.store.getXswiftc(),
        buildPath: this.props.store.getBuildPath(),
        onDismiss: () => this._hideSettings(),
        onSave: (configuration, Xcc, Xlinker, Xswiftc, buildPath) => this._saveSettings(configuration, Xcc, Xlinker, Xswiftc, buildPath)
      }) : null
    );
  }

  _onChdirChange(value) {
    this.props.actions.updateChdir(value);
  }

  _showSettings() {
    this.setState({ settingsVisible: true });
  }

  _hideSettings() {
    this.setState({ settingsVisible: false });
  }

  _saveSettings(configuration, Xcc, Xlinker, Xswiftc, buildPath) {
    this.props.actions.updateSettings(configuration, Xcc, Xlinker, Xswiftc, buildPath);
    this._hideSettings();
  }
}
exports.default = SwiftPMTaskRunnerToolbar;
module.exports = exports['default'];