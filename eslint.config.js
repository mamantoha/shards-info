'use strict';

module.exports = require('neostandard')({});

module.exports = [
  {
      ignores: ["assets/vendor/*"],
      rules: {
         semi: "error",
         "prefer-const": "error",
        "no-unused-vars": "off",
        "no-undef": "off",
      }
  }
];
