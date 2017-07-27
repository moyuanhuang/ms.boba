START_ORDER_STRING = "Please start an order with `.boba`."
ADD_ORDER_STRING = "Reply with `.add <your order here>` to add your order."

module.exports = (msBoba) ->

  msBoba.hear /\.boba/i, (res) ->
    takingOrder = msBoba.brain.get 'takingOrder'

    if takingOrder
      res.send "Order already in progress."
    else
      msBoba.brain.set 'takingOrder', true

    res.send ADD_ORDER_STRING

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

  msBoba.hear /\.order/i, (res) ->
    takingOrder = msBoba.brain.get 'takingOrder'

    if takingOrder
      order = msBoba.brain.get 'order'

      if order
        list = "Final orders:\n"

        for username, item of order
          list += "@#{username} : #{item}\n"
        res.send list
        stopOrder()
        # TODO: maybe send private message to everyone?
      else
        res.send "No one has ordered milk tea."
        res.send ADD_ORDER_STRING
    else
      res.send START_ORDER_STRING



  msBoba.hear /\.cancel/i, (res) ->
    takingOrder = msBoba.brain.get 'takingOrder'

    if takingOrder
      stopOrder()
      res.send "Boba order cancelled."
    else
      res.send "No order in progress."

  stopOrder = () ->
    msBoba.brain.set 'order', null
    msBoba.brain.set 'takingOrder', false

