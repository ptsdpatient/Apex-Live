const { Pool } = require('pg');

const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'apex_live',
    password: 'sus', //development
    // password:'',  //production
    port: 5432, 
});

module.exports = pool;
