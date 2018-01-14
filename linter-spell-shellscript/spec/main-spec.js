'use babel'

describe('The linter-spell-shellscript provider for Atom Linter', () => {
  const grammar = require('../lib/main').provideGrammar()[0]

  beforeEach(() => {
    waitsForPromise(() => {
      return atom.packages.activatePackage('linter-spell-shellscript')
    })
  })
})
