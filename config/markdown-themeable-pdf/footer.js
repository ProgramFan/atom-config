/**
 * Your markdown-themeable-pdf custom footer.
 * After you have made any changes you need to reload or restart atom.
 *
 * The default file can be found in the folder ~/.atom/packages/markdown-themeable-pdf/templates
 *
 * @returns {{height: string, contents: string}}
 */
module.exports = function () {
    return {
        height: '1cm',
        contents: '<div style="float:center;">{{page}}/{{pages}}</div>'
    };
};
