return {
    riot=true;
    id = 'SinceKalista';
    name = 'Since Kalista';
    type = "Champion";
    load = function()
      return player.charName == "Kalista"
    end;
}
