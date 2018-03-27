require('dotenv').load();
const yelp = require('yelp-fusion');

const apiKey = process.env.YELP_API_KEY;
const client = yelp.client(apiKey);

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
    client.search({
      term,
      location,
      open_now: true,
    }).then((response) => {
        msg = selectBusinesses(response.jsonBody.businesses);
        callback(msg);
    });
  },

  getBusinessByName: (business_name, location, callback) => {
    client.search({
      term: business_name,
      location,
    }).then((response) => {
      businesses = response.jsonBody.businesses;
      callback(businesses[0]);
    });
  },
}
