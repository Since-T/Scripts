return {
    riot=true;
    id = 'SinceCorki';
    name = 'Since Corki';
    type = "Champion";
    load = function()
      return player.charName == "Corki"
    end;
}
