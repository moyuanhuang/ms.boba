module.exports = {
  displayMenu: (bus) => {
    var json = require("../menus/boba_bar.json");
    msg = `Menu from ${bus.name}\n`;
    for(let item of json.drinks)
      msg += `${item[0]} \$${item[1]}\n`;
    return msg;
  }
}
