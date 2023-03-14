# app1-infrastruktur
App att gå live med för deluppgift 1.

### First of all - install all dependencies
```
npm install
```

### Prepare the DB server
1. Make sure that you have a MySQL server installed and running on the machine.
2. And a database user that has full rights to the db 'cinema'.

### Change the settings.json file
* Enter the name and password of the MySQL user in setttings.json.

### Seed the database

```
cd _seed_db
node seeder.js
```

### Make a build and run the production server

1. Run npm run build
2. Then you should be able to start the  productionserver:

```
cd backend
node index.js
```
