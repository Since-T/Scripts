return {
    riot=true;
    id = 'SinceKogMaw';
    name = 'Since KogMaw';
    type = "Champion";
    load = function()
      return player.charName == "KogMaw"
    end;
}
