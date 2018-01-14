'use babel'

import { CompositeDisposable } from 'atom'

export default {
  disposables: null,
  provideGrammar () {
    function checkComments () {
      return atom.config.get('linter-spell-shellscript.checkComments')
    }

    function checkStrings () {
      return atom.config.get('linter-spell-shellscript.checkStrings')
    }

    return [{
      grammarScopes: ['source.shell'],
      checkedScopes: {
        'punctuation.whitespace.comment.leading.shell': checkComments,
        'punctuation.definition.comment.shebang.shell': false,
        'comment.line.number-sign.shebang.shell': false,
        'comment.line.number-sign.shell': checkComments,
        'string.quoted.single.shell': checkStrings,
        'string.quoted.double.shell': checkStrings,
        'punctuation.definition.variable.shell': false,
        'variable.other.normal.shell': false,
        'variable.other.special.shell': false,
        'variable.other.positional.shell': false,
        'variable.other.bracket.shell': false
      }
    }]
  },

  provideDictionary () {
    let wordList = require('linter-spell-word-list')
    let a = new wordList.ConfigWordList({
      name: 'ShellScript',
      keyPath: 'linter-spell-shellscript.words',
      grammarScopes: ['source.shell']
    })
    this.disposables.add(a)
    return a.provideDictionary()
  },

  activate () {
    this.disposables = new CompositeDisposable()
    require('atom-package-deps').install('linter-spell-latex')
      .then(() => {
        console.log('All dependencies installed, good to go')
      })
  },

  deactivate () {
    this.disposables.dispose()
  }
}
