function simplify_size(size_in) {
  if(size_in)
    size_in = size_in[0].toLowerCase()
    if(size_in === "large")
      return size_in;
  return "regular";
}

function simplify_sugar(sugar_in){
  // need to deal with regex
  return sugar_in;
}

function simplify_ice(ice_in){
  // need to deal with regex
  return ice_in;
}

function simplify_addon(addon_in){
  addon = null
  if(addon_in)
    addon = addon_in[0].toLowerCase();
  return addon
}

module.exports = {
  parseOrder: (order) => {
    size = simplify_size(order.match(/(large|medium|regular)/i));
    // sugar = simplify_sugar(order.match(/ (.?) sugar/i));
    // ice = simplify_ice(order.match(/ (.?) ice/i));
    addon = simplify_addon(order.match(/(grass jelly|boba)/i));
    return { size, addon };
  }
}
