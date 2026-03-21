AltTexture({
  key = 'JimboSimpson',
  set = 'Joker', 
  path = 'joker.png',
  keys = { "j_joker" },
  loc_txt = { 
    name = 'Simpsons Joker',
  }
})

AltTexture({
  key = 'BlueHomer',
  set = 'Joker', 
  path = 'blueprint.png',
  keys = { "j_blueprint" },
  loc_txt = { 
    name = 'Simpsons Blueprint',
  }
})

AltTexture({
  key = 'Brainstorm',
  set = 'Joker', 
  path = 'brainstorm.png',
  keys = { "j_brainstorm" },
  loc_txt = { 
    name = 'Simpsons Braistorm',
  }
})

TexturePack({
    key = 'samsons',
    textures = {'simpson_JimboSimpson', 'simpson_BlueHomer', 'simpson_Brainstorm'},
    loc_txt = {
        name = 'Joker for BalatroSpringfield',
        text = {'Changes some jokers for Springfield'}
    }
})

assert(SMODS.load_file("src/jokers.lua"))()