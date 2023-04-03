const fs = require('fs');

// read table definitions and parse to query array
function defaul() { 
  return (
    fs.readFileSync('./sql/table-definitions.sql', 'utf-8') +
    fs.readFileSync('./sql/views.sql', 'utf-8')
  ).split(';')
    .map(x => x.trim().replaceAll('\n', ' '))
    .filter(x => x && x[0] !== '#' && x[0] !== '/')
};

module.exports = { defaul };

