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

SMODS.Atlas {
    key = 'modicon',
    path = 'modicon.png',
    px = 32,
    py = 32
}

assert(SMODS.load_file("src/jokers.lua"))()
assert(SMODS.load_file("src/legendaries.lua"))()
assert(SMODS.load_file("src/enhancements.lua"))()
assert(SMODS.load_file("src/tradingcards.lua"))()
assert(SMODS.load_file("src/boosters.lua"))()

SIMPSON_DOLLARS_SPENT = 0
SIMPSON_CARDS_DESTROYED_RUN = 0
SIMPSONS_FOOL_VARIABLE = nil
G_C_SIMPSONS_TRADING_CARD = "e1841d"

local oldstartrun = Game.start_run
function Game:start_run(args)
    local g = oldstartrun(self, args)
    SIMPSON_DOLLARS_SPENT = 0
    SIMPSON_CARDS_DESTROYED_RUN = 0
    SIMPSONS_FOOL_VARIABLE = nil
    return g
end

--Mod Stuff
SMODS.current_mod.calculate = function(self, context)
    if context.buying_card or context.open_booster then
        SIMPSON_DOLLARS_SPENT = SIMPSON_DOLLARS_SPENT + context.card.cost
    end
    if context.reroll_shop then
        SIMPSON_DOLLARS_SPENT = SIMPSON_DOLLARS_SPENT + context.cost
        print(G.GAME.consumeable_usage_total)
    end
    if context.remove_playing_cards then
        for i = 1, #context.removed do
            SIMPSON_CARDS_DESTROYED_RUN = SIMPSON_CARDS_DESTROYED_RUN + 1
        end
    end
    if context.using_consumeable and context.consumeable.config.center.set == 'SimpsonsTrading' and context.consumeable.config.center.key ~= 'c_simpson_doh' then
        SIMPSONS_FOOL_VARIABLE = context.consumeable.config.center.key
    end
end
