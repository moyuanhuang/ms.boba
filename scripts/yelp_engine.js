const yelp = require('yelp-fusion');

const clientId = 'fLyQHoVisv_RyZDy6cQzfQ';
const clientSecret = 'FLIXqlpldAYt0CIkBD6vcYn9furjEqKFRf8PhGfCWPO7X8SsgV4kUt4BmUQ8fqSy';

const num_businesses = 3
function selectChoices(businesses) {
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
  msg += "type .more for more choices!"
  return msg;
}

module.exports = (msBoba) => {
  msBoba.hear( /.send/i, (res) => {
    yelp.accessToken(clientId, clientSecret).then(response => {
      const client = yelp.client(response.jsonBody.access_token);

      client.search({
        term:'milk tea',
        location: 'convoy street, san diego, ca'
      }).then(response => {
          // console.log(response.jsonBody.businesses[0]);
          msg = selectChoices(response.jsonBody.businesses);
          res.send(msg);
      });
    }).catch(e => {
      console.log(e);
    });
  });
}

// module.exports = (msBoba) => {
//
// }
