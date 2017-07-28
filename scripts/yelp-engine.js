const yelp = require('yelp-fusion');

const CLIENT_ID = process.env.YELP_CLIENT_ID;
const CLIENT_SECRET = process.env.YELP_CLIENT_SECRET;

const num_businesses = 3
function selectBusinesses(businesses) {
  recoms = [];
  for(let i = 0; i < num_businesses; i += 1){
    rand = Math.floor( Math.random() * businesses.length );
    if(recoms.indexOf(rand) != -1){ i -= 1; }
    else{ recoms.push(rand); }
  }
  msg = "Checkout these places!\n";
  for(let index of recoms){
    bus = businesses[index];
    msg += `<${bus.url}|${bus.name}>: ${bus.rating}\n`;
  }
  return msg;
}

module.exports = {
  getChoices: (term, location, callback) => {
    yelp.accessToken(CLIENT_ID, CLIENT_SECRET).then(response => {
      const client = yelp.client(response.jsonBody.access_token);
      client.search({
        term,
        location,
      }).then((response) => {
          msg = selectBusinesses(response.jsonBody.businesses);
          callback(msg);
      });
    }).catch(e => {
      console.log(e);
    });
  }
}
