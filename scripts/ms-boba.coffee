module.exports = (msBoba) ->

  msBoba.hear /\.boba/i, (res) ->
    takingOrder = msBoba.brain.get 'takingOrder'

    if takingOrder
      res.send "Order already in progress."
    else
      msBoba.brain.set 'takingOrder', true
      res.send "takingOrder: #{msBoba.brain.get 'takingOrder'}"
    
    res.send "Reply with `.add <your order here>` to add your order."

  msBoba.hear /\.add (.*)/i, (res) ->
    takingOrder = msBoba.brain.get 'takingOrder'
    # res.send "takingOrder: #{msBoba.brain.get 'takingOrder'}"
    if takingOrder
      newOrder = res.match[1]
      # res.send "newOrder: #{newOrder}"
      order = msBoba.brain.get 'order'
      sender = res.message.user.name

      unless order
        order = {}
        # res.reply "order: #{order}"

      order[sender] = newOrder
      msBoba.brain.set 'order', order
      res.send "Order received for #{sender}."
      res.send "order: #{order[sender]}"
    else
      res.send "Please start an order with `.boba`."

  msBoba.hear /\.cancel/i, (res) ->
    takingOrder = msBoba.brain.get 'takingOrder'

    if takingOrder
      msBoba.brain.set 'takingOrder', false
      # reset order here
      res.send "takingOrder: #{msBoba.brain.get 'takingOrder'}"
      res.send "Boba order cancelled."
    else
      res.send "No order in progress."

