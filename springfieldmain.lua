if next(SMODS.find_mod("malverk")) then
  AltTexture({
    key = 'JimboSimpson',
    set = 'Joker', 
    path = 'joker.png',
    keys = { "j_joker" },
    loc_txt = { 
      name = 'Joker',
    }
  })

  AltTexture({
    key = 'BlueHomer',
    set = 'Joker', 
    path = 'blueprint.png',
    keys = { "j_blueprint" },
    loc_txt = { 
      name = 'Blueprint',
    }
  })

  AltTexture({
    key = 'Brainstorm',
    set = 'Joker', 
    path = 'brainstorm.png',
    keys = { "j_brainstorm" },
    loc_txt = { 
      name = 'Braistorm',
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
end

assert(SMODS.load_file("src/jokers.lua"))()
assert(SMODS.load_file("src/enhancements.lua"))()
assert(SMODS.load_file("src/tradingcards.lua"))()