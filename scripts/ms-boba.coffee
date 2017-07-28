Twilio = require('./twilio-engine.js')
yelp = require('./yelp-engine.js')

START_ORDER_STRING = "Please start an order with `.boba`."
ADD_ORDER_STRING = "Reply with `.add <your order here>` to add your order."
WHITE_LIST = [ "mark.huang", "boba", "dean.park" ]

LOCATION = 'convoy street, san diego, ca, 92111'
TERM = 'milk tea'

module.exports = (msBoba) ->

  msBoba.hear /\.boba/i, (res) ->
    takingOrder = msBoba.brain.get 'takingOrder'

    if takingOrder
      res.send "Order already in progress."
    else
      msBoba.brain.set 'takingOrder', true

    sendChoices = (msg) ->
      msg += "type .more for more choices!"
      res.send msg

    yelp.getChoices(TERM, LOCATION, sendChoices)
    res.send ADD_ORDER_STRING

  msBoba.hear /\.more/i, (res) ->
    sendChoices = (msg) ->
      res.send msg
    yelp.getChoices(TERM, LOCATION, sendChoices)

  msBoba.hear /\.add (.*)/i, (res) ->
    takingOrder = msBoba.brain.get 'takingOrder'

    if takingOrder
      newOrder = res.match[1]
      order = msBoba.brain.get 'order'
      sender = res.message.user.name

      unless order
        order = {}

      order[sender] = newOrder
      msBoba.brain.set 'order', order
      res.send "Order received for #{sender}."
    else
      res.send START_ORDER_STRING

  msBoba.hear /\.myorder/i, (res) ->
    takingOrder = msBoba.brain.get 'takingOrder'

    if takingOrder
      order = msBoba.brain.get 'order'
      sender = res.message.user.name
      myOrder = order && order[sender]

      if myOrder
        msBoba.messageRoom "@#{sender}", "You ordered #{myOrder}."
      else
        msBoba.messageRoom "@#{sender}", "You have no order."
    else
      msBoba.messageRoom "@#{sender}", START_ORDER_STRING

  msBoba.hear /\.status/i, (res) ->
    takingOrder = msBoba.brain.get 'takingOrder'

    if takingOrder
      bus = msBoba.brain.get 'orderLocation'
      locationMsg = "\nOrder will send to "
      if bus
        locationMsg += "<#{bus.url}|#{bus.name}>: #{bus.phone}\n"
        locationMsg += "#{bus.location.display_address}"
      else
        locationMsg += "#{process.env.TEST_PHONE_NUMBER}"
      res.send locationMsg

      order = msBoba.brain.get 'order'

      if order
        list = "Current orders:\n"

        for username, item of order
          list += "@#{username} : #{item}\n"
        res.send list
      else
        res.send "No one has ordered milk tea."
        res.send ADD_ORDER_STRING
    else
      res.send START_ORDER_STRING

  msBoba.hear /\.pick (.*)/i, (res) ->
    takingOrder = msBoba.brain.get 'takingOrder'

    if takingOrder
      business = res.match[1]
      if business
        yelp.getBusinessByName(
          business,
          LOCATION,
          (bus) ->
            res.send "<#{bus.url}|#{bus.name}>: #{bus.phone}\n"
            msBoba.brain.set 'orderLocation', bus
        )
    else
      res.send START_ORDER_STRING

  msBoba.hear /\.vote (.*)/i, (res) ->
    takingOrder = msBoba.brain.get 'takingOrder'
    if !takingOrder
      res.send START_ORDER_STRING
      return
      
    voting = msBoba.brain.get 'voting'
    voted_list = msBoba.brain.get 'voted_list'
    sender = res.message.user.name
    business_name = res.match[1]

    unless voting
      voting = {}
    unless voted_list
      voted_list = []
    if sender in voted_list
      res.send "#{sender} has already voted!"
      return

    if business_name
      yelp.getBusinessByName(
        business_name,
        LOCATION,
        (bus) ->
          unless voting[bus.name]
            voting[bus.name] = []
          voting[bus.name].push(sender)
          voted_list.push(sender)
          res.send "#{sender} voted for #{bus.name}! current voting: #{voting[bus.name].length}"
          msBoba.brain.set 'voting', voting
          msBoba.brain.set 'voted_list', voted_list
      )
    else
      res.send "#{business_name} not found in yelp."

  msBoba.hear /\.order/i, (res) ->
    takingOrder = msBoba.brain.get 'takingOrder'

    if takingOrder
      order = msBoba.brain.get 'order'

      if order
        list = "Final orders:\n"

        for username, item of order
          list += "@#{username} : #{item}\n"

        bus = msBoba.brain.get 'orderLocation'
        orderPhoneNumber = (bus && bus.phone) || process.env.TEST_PHONE_NUMBER;

        msBoba.brain.set 'orderSuccess', true

        Twilio.sms(
          orderPhoneNumber,
          list,
          (err, msg) ->
            if err
              console.log err
              res.send "Error sending order through SMS..."
              msBoba.brain.set 'orderSuccess', false
              return

            if msg
              console.log "SMS SENT - #{msg.sid}"
        )

        Twilio.call(
          orderPhoneNumber,
          process.env.MS_BOBA_CALL_MSG,
          (err, msg) ->
            if err
              console.log err
              res.send "Error calling in order..."
              msBoba.brain.set 'orderSuccess', false
              return

            if msg
              console.log "CALL PLACED - #{msg.sid}"
        )

        if (msBoba.brain.get 'orderSuccess')
          res.send list

          locationMsg = "\nOrder sent to "
          if bus
            locationMsg += "<#{bus.url}|#{bus.name}>: #{bus.phone}\n"
            locationMsg += "#{bus.location.display_address}"
          else
            locationMsg += "#{orderPhoneNumber}"
          res.send locationMsg

          user = _russianRoulette(Object.keys(order))
          res.send "@#{user}, go get it!"
          _stopOrder()
        # TODO: maybe send private message to everyone?
      else
        res.send "No one has ordered milk tea."
        res.send ADD_ORDER_STRING
    else
      res.send START_ORDER_STRING

  msBoba.hear /\.cancel/i, (res) ->
    takingOrder = msBoba.brain.get 'takingOrder'

    if takingOrder
      _stopOrder()
      res.send "Boba order cancelled."
    else
      res.send "No order in progress."

  _stopOrder = () ->
    msBoba.brain.set 'takingOrder', false
    msBoba.brain.set 'order', null
    msBoba.brain.set 'orderSuccess', null
    msBoba.brain.set 'orderLocation', null
    msBoba.brain.set 'voting', null
    msBoba.brain.set 'voted_list', null

  _applyWhiteList = (users) ->
    return (users.filter (u) -> WHITE_LIST.indexOf(u) == -1).length > 0

  _russianRoulette = (users) ->
    user = users[Math.floor(Math.random() * users.length)]

    if _applyWhiteList(users)
      while user in WHITE_LIST
        user = users[Math.floor(Math.random() * users.length)]

    return user
