/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const fs = require("fs")
const RefView = require('../lib/ref-view')

describe("RefView", () =>

  describe("Initialising a RefView", () =>
    it("loads loads a reference JSON into the view", function() {
      const references = JSON.parse(fs.readFileSync(__dirname + '/library.json', 'utf-8'))
      const fakeProvider = {references: references}
      const refView = new RefView(fakeProvider)
      console.log(refView);
      expect(refView.selectListView).not.toBeNull()
    })
  )
)
