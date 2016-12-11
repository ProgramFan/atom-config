# READY: This should manage access to all config settings id:24
pkg = require '../../package.json'

module.exports =
  getPackageName: () -> pkg.name

  getPackagePath: () -> atom.packages.getLoadedPackage(pkg.name).path

  getSettings: () -> atom.config.get "#{pkg.name}"
