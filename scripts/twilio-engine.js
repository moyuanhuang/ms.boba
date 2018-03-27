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

const client = require('twilio')(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_ACCOUNT_TOKEN);

module.exports = {
  sms: (to, body, callback) => {
    twilio.messages.create({
      to,
      from: process.env.TWILIO_PHONE_NUMBER,
      body,
    }, callback);
  },

  call: (to, url, callback) => {
    twilio.calls.create({
      url,
      to,
      from: process.env.TWILIO_PHONE_NUMBER,
    }, callback);
  },
};
