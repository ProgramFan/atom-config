'use babel'

import * as bibtexParse from '../lib/lite-bibtex-parse'
import fs from 'fs'
import path from 'path'

describe("BibtexParser", () =>
  describe("Parsing bibtex file", function() {
    it("reads a normal bibtex file", function() {
      let file = 'latex_test.bib'

      let bibTexStr = fs.readFileSync(path.join(__dirname, 'test_bibtexes', 'good', file), 'utf8')

      let bibTexJson = bibtexParse.toJSON(bibTexStr)
      expect(bibTexJson.length).toBeGreaterThan(0)
    })

    it("reads a bibtex file with comments", () => {
      let file = 'commentTest.bib'

      let bibTexStr = fs.readFileSync(path.join(__dirname, 'test_bibtexes', 'good', file), 'utf8')
      let bibTexJson = bibtexParse.toJSON(bibTexStr)
      expect(bibTexJson.length).toBeGreaterThan(0)
    })

    it("runs on all good input files", () => {
      let goodFiles = fs.readdirSync(path.join(__dirname, 'test_bibtexes', 'good'))
      goodFiles.forEach(function(file) {
        let bibTexStr = fs.readFileSync(path.join(__dirname, 'test_bibtexes', 'good', file), 'utf8')

        let bibTexJson = bibtexParse.toJSON(bibTexStr)
        expect(bibTexJson.length).toBeGreaterThan(0)
      })
    })

    it("throws error on all bad input files", () => {
      let badFiles = fs.readdirSync(path.join(__dirname, 'test_bibtexes', 'bad'))
      badFiles.forEach(function(file) {
        let bibTexStr = fs.readFileSync(path.join(__dirname, 'test_bibtexes', 'bad', file), 'utf8')

        expect(function() {
          bibtexParse.toJSON(bibTexStr)
        }).toThrow(new TypeError("Runaway key: key"))

        // try {
        //   let bibTexJson = bibtexParse.toJSON(bibTexStr);
        // } catch (err) {
        //   console.log('expected error ' + err);
        //   bibTexJson = {};
        // }
        // expect(Object.keys(bibTexJson).length).toEqual(0);
      })
    })
  })
)
