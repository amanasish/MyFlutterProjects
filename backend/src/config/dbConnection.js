// const { MongoClient } = require('mongodb');

// ///Connection string

// /// mongodb+srv://ElderNestAcc:qwer12345@cluster0.5986ojp.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0

// // Connection URL
// // const dbConnectionUrl = 'mongodb://127.0.0.1:27017';

// const dbConnectionUrl = 'mongodb+srv://ElderNestAcc:qwer12345@cluster0.5986ojp.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0&tls=true';
// const client = new MongoClient(dbConnectionUrl,{
//   tls: true,
//   tlsAllowInvalidCertificates: true, 
// });

// let dbConnection= async ()=>{
//  await client.connect();
//  const db = client.db("ElderlyNest");
//  return db;
// }

// module.exports={dbConnection};



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
