const { Pool } = require('pg');
const db = require('../../dbConfig.js');

const pool = new Pool(db.dbconfig);

pool.connect(() => {
  console.log('connected to db');
});

module.exports.pool = pool;