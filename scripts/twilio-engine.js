// Description:
//   Allows Hubot to send text messages using Twilio API
//
// Dependencies:
//   None
//
// Configuration:
//   TWILIO_ACCOUNT_SID
//   TWILIO_ACCOUNT_TOKEN
//   TWILIO_PHONE_NUMBER

var twilio = require('twilio')(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_ACCOUNT_TOKEN);

module.exports = {
  sms: (to, body) => {
    twilio.messages.create({ 
      to, 
      from: process.env.TWILIO_PHONE_NUMBER, 
      body, 
    }, function(err, message) {
      if (err) {
        console.log(err);
        return;
      }

      if (message) {
        console.log(message.sid); 
      }
    });
  },

  call: (to, url) => {
    twilio.calls.create({
      url,
      to,
      from: process.env.TWILIO_PHONE_NUMBER,
    }, function(err, call) {
      process.stdout.write(call.sid);
    });
  },
};
