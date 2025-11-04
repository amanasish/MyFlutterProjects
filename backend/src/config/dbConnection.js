const { MongoClient } = require('mongodb');

// Connection URL with database specified
const dbConnectionUrl = 'mongodb+srv://ElderNestAcc:qwer12345@cluster0.5986ojp.mongodb.net/ElderlyNest?retryWrites=true&w=majority';

// Create a new MongoClient
const client = new MongoClient(dbConnectionUrl);

const dbConnection = async () => {
  await client.connect();
  const db = client.db('ElderlyNest');
  return db;
};

module.exports = { dbConnection };
