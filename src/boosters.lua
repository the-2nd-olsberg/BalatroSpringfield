--Atlas
SMODS.Atlas {
    key = 'SimpsBooster',
    path = 'boosters.png',
    px = 71,
    py = 95
}

SMODS.Booster {
    key = 'booster_1',
    loc_txt = {
        name = 'Simpsons Pack',
        text = {
            'Choose {C:attention}#1#{} of {C:attention}#2#{}',
            '{C:money}Springfield{} Jokers'
        },
        group_name = 'Homer at the Pack'
    },
    weight = 0.7,
    cost = 4,
    discovered = true,
    atlas = 'SimpsBooster',
    pos = { x = 0, y = 0 },
    config = { extra = 2, choose = 1 },
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra },
        }
    end,
    ease_background_colour = function(self)
        ease_background_colour_blind(G.STATES.BUFFOON_PACK)
    end,
    create_card = function(self, card, i)
        return { set = "SpringfieldJokers", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "sprungfeld" }
    end,
}

SMODS.Booster {
    key = 'booster_2',
    loc_txt = {
        name = 'Simpsons Pack',
        text = {
            'Choose {C:attention}#1#{} of {C:attention}#2#{}',
            '{C:money}Springfield{} Jokers'
        },
        group_name = 'Bart the Dealer'
    },
    weight = 0.7,
    cost = 4,
    discovered = true,
    atlas = 'SimpsBooster',
    pos = { x = 1, y = 0 },
    config = { extra = 2, choose = 1 },
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra },
        }
    end,
    ease_background_colour = function(self)
        ease_background_colour_blind(G.STATES.BUFFOON_PACK)
    end,
    create_card = function(self, card, i)
        return { set = "SpringfieldJokers", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "sprungfeld" }
    end,
}

SMODS.Booster {
    key = 'booster_3',
    loc_txt = {
        name = 'Jumbo Simpsons Pack',
        text = {
            'Choose {C:attention}#1#{} of {C:attention}#2#{}',
            '{C:money}Springfield{} Jokers'
        },
        group_name = 'Joking Lisa'
    },
    weight = 0.7,
    cost = 6,
    discovered = true,
    atlas = 'SimpsBooster',
    pos = { x = 0, y = 1 },
    config = { extra = 4, choose = 1 },
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra },
        }
    end,
    ease_background_colour = function(self)
        ease_background_colour_blind(G.STATES.BUFFOON_PACK)
    end,
    create_card = function(self, card, i)
        return { set = "SpringfieldJokers", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "sprungfeld" }
    end,
}

SMODS.Booster {
    key = 'booster_4',
    loc_txt = {
        name = 'Mega Simpsons Pack',
        text = {
            'Choose {C:attention}#1#{} of {C:attention}#2#{}',
            '{C:money}Springfield{} Jokers'
        },
        group_name = 'A Joker Pack Named Marge'
    },
    weight = 0.2,
    cost = 8,
    discovered = true,
    atlas = 'SimpsBooster',
    pos = { x = 1, y = 1 },
    config = { extra = 5, choose = 2 },
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra },
        }
    end,
    ease_background_colour = function(self)
        ease_background_colour_blind(G.STATES.BUFFOON_PACK)
    end,
    create_card = function(self, card, i)
        return { set = "SpringfieldJokers", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "sprungfeld" }
    end,
}

SMODS.Booster {
    key = 'trading_booster_1',
    loc_txt = {
        name = 'Trading Card Pack',
        text = {
            'Choose {C:attention}#1#{} of {C:attention}#2#{}',
            '{C:red}Simpsons Trading Cards',
            'to use immediately'
        },
        group_name = 'Trading Cards!?'
    },
    weight = 1,
    cost = 4,
    discovered = true,
    draw_hand = true,
    atlas = 'SimpsBooster',
    pos = { x = 2, y = 0 },
    config = { extra = 3, choose = 1 },
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra },
        }
    end,
    ease_background_colour = function(self)
        ease_background_colour_blind(G.STATES.TAROT_PACK)
    end,
    create_card = function(self, card, i)
        return { set = "SimpsonsTrading", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "sprungfeld" }
    end,
}

SMODS.Booster {
    key = 'trading_booster_2',
    loc_txt = {
        name = 'Trading Card Pack',
        text = {
            'Choose {C:attention}#1#{} of {C:attention}#2#{}',
            '{C:red}Simpsons Trading Cards',
            'to use immediately'
        },
        group_name = 'Trading Cards!?'
    },
    weight = 1,
    cost = 4,
    discovered = true,
    draw_hand = true,
    atlas = 'SimpsBooster',
    pos = { x = 3, y = 0 },
    config = { extra = 3, choose = 1 },
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra },
        }
    end,
    ease_background_colour = function(self)
        ease_background_colour_blind(G.STATES.TAROT_PACK)
    end,
    create_card = function(self, card, i)
        return { set = "SimpsonsTrading", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "sprungfeld" }
    end,
}

SMODS.Booster {
    key = 'trading_booster_3',
    loc_txt = {
        name = 'Jumbo Trading Card Pack',
        text = {
            'Choose {C:attention}#1#{} of {C:attention}#2#{}',
            '{C:red}Simpsons Trading Cards',
            'to use immediately'
        },
        group_name = 'Trading Cards!?'
    },
    weight = 1,
    cost = 6,
    discovered = true,
    draw_hand = true,
    atlas = 'SimpsBooster',
    pos = { x = 2, y = 1 },
    config = { extra = 5, choose = 1 },
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra },
        }
    end,
    ease_background_colour = function(self)
        ease_background_colour_blind(G.STATES.TAROT_PACK)
    end,
    create_card = function(self, card, i)
        return { set = "SimpsonsTrading", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "sprungfeld" }
    end,
}

SMODS.Booster {
    key = 'trading_booster_4',
    loc_txt = {
        name = 'Mega Trading Card Pack',
        text = {
            'Choose {C:attention}#1#{} of {C:attention}#2#{}',
            '{C:red}Simpsons Trading Cards',
            'to use immediately'
        },
        group_name = 'Trading Cards!?'
    },
    weight = 0.3,
    cost = 8,
    discovered = true,
    draw_hand = true,
    atlas = 'SimpsBooster',
    pos = { x = 3, y = 1 },
    config = { extra = 5, choose = 2 },
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra },
        }
    end,
    ease_background_colour = function(self)
        ease_background_colour_blind(G.STATES.TAROT_PACK)
    end,
    create_card = function(self, card, i)
        return { set = "SimpsonsTrading", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "sprungfeld" }
    end,
}