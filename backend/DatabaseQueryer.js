// © Thomas Frank, Node Hill 
// MIT licensed
// A thin wrapper with error handling
// around our DB driver

const mysql = require('mysql2');

module.exports = class DatabaseQueryer {

  static verbose = false;

  static connect() {
    // read settings
    const {
      mySqlHost: host,
      mySqlPort: port,

      /*
        if set to null and passed along, 
        socketPath won't do anything.
        Currently, behaviour when using socketPath in
        mysql2 is for the socketPath to override
        the port and host passed and instead just to connect
        with the path given. For more details, check out
        mysql2's source code. At the time of commit
        6bc64442b402b420145781057c4aebe9618be246
        this behaviour is defined between lines 47-53 
        in lib/connection.js. Shorthand view: 

        git clone https://github.com/sidorares/node-mysql2.git
        sed -n '47,53p' node-mysql2/lib/connection.js
      */
      mySqlSocketPath: socketPath,

      mySqlUser: user,
      mySqlPassword: password,
      database
    } = require('../settings.json');

    this.dbConnection = mysql.createPool({ host, port, socketPath, user, password, database });
    return this.dbConnection;
  }

  static query(sql, params = []) { // call using await!
    this.dbConnection || this.connect();
    return new Promise((resolve, reject) => {
      this.verbose && this.log(sql, params);
      let driverMethod = params.length ? 'execute' : 'query';
      this.dbConnection[driverMethod](sql, params, (error, results) => {
        return error ? reject(error) : resolve(results)
      }
      );
    });
  }

  static log(sql, params) {
    sql = sql.replace(/ {1,}/g, ' ');
    params ? console.log(sql, '? ->', params) : console.log(sql);
    console.log('\n' + '-'.repeat(60) + '\n');
  }

}
