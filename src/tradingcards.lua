SMODS.ConsumableType {
  object_type = "ConsumableType",
  key = 'SimpsonsTrading',
  default = 'c_simpson_duff',
  collection_rows = { 5,5 },
  primary_colour = HEX("f2df46"),
  secondary_colour = HEX("fd5f55"),
  loc_txt = {
      collection = 'Simpsons Trading Cards',
      name = 'Simpsons Trading Cards',
      label = 'Simpsons Trading Cards',
      },
  shop_rate = 4,
}

--Atlas
SMODS.Atlas {
    key = 'SimpsTrading',
    path = 'tradingcards.png',
    px = 71,
    py = 95
}

SMODS.Consumable {
    key = 'duff',
    loc_txt = {
        name = 'Duff',
        text = {
            "Enhances up to {C:attention}#1#{}",
            "selected cards into",
            "{C:attention}Alcoholic{} Cards",
        }
    },
    set = 'SimpsonsTrading',
    atlas = 'SimpsTrading',
    pos = { x = 1, y = 0 },
    discovered = true,
    config = { max_highlighted = 2, mod_conv = 'm_simpson_alcohol' },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted } }
    end,
}

SMODS.Consumable {
    key = 'elementary',
    loc_txt = {
        name = 'Springfield Elementary',
        text = {
            "Converts all cards in",
            "hand to {C:attention}random{} suits"
        }
    },
    set = 'SimpsonsTrading',
    atlas = 'SimpsTrading',
    pos = { x = 1, y = 1 },
    discovered = true,
    config = { },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.cards do
            local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip()
                    play_sound('card1', percent)
                    G.hand.cards[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        for i = 1, #G.hand.cards do
            G.E_MANAGER:add_event(Event({
                func = function()
                    local _suit = pseudorandom_element(SMODS.Suits, 'sigil')
                    local _card = G.hand.cards[i]
                    assert(SMODS.change_base(_card, _suit.key))
                    return true
                end
            }))
        end
        for i = 1, #G.hand.cards do
            local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.cards[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.5)
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end,
}

SMODS.Consumable {
    key = 'saxaphone',
    loc_txt = {
        name = "Lisa's Sax",
        text = {
            "Gives up to {C:attention}#1#{} random",
            "cards {C:attention}random{} enhancements"
        }
    },
    set = 'SimpsonsTrading',
    atlas = 'SimpsTrading',
    pos = { x = 3, y = 0 },
    discovered = true,
    config = { extra = { cards = 3 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cards } }
    end,
    use = function(self, card, area, copier)
        local pozes = {0, 0, 0}
        for i = 1, card.ability.extra.cards do
            pozes[i] = pseudorandom('saxxy', 1, #G.hand.cards)
            if pozes[i - 1] then
                if pozes[i] == pozes[i - 1] then
                    pozes[i] = pseudorandom('saxxy', 1, #G.hand.cards)
                    if pozes[i - 1] then
                        if pozes[i] == pozes[i - 1] then
                            pozes[i] = pseudorandom('saxxy', 1, #G.hand.cards)
                        end
                    end
                end
            end
        end
        for i = 1, #pozes do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.cards[pozes[i]]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.cards[pozes[i]]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        local cen_pool = {}
        for _, enhancement_center in pairs(G.P_CENTER_POOLS["Enhanced"]) do
            if enhancement_center.key ~= 'm_stone' and not enhancement_center.overrides_base_rank then
                cen_pool[#cen_pool + 1] = enhancement_center
            end
        end
        delay(0.2)
        for i = 1, #pozes do
            local enhancement = pseudorandom_element(cen_pool, 'spe_card')
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.cards[pozes[i]]:set_ability(enhancement.key)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #pozes do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.cards[pozes[i]]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.cards[pozes[i]]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end,
}

SMODS.Consumable {
    key = 'skateboard',
    loc_txt = {
        name = "Bart's Skateboard",
        text = {
            "Levels up {C:attention}second",
            "most played hand"
        }
    },
    set = 'SimpsonsTrading',
    atlas = 'SimpsTrading',
    pos = { x = 4, y = 0 },
    discovered = true,
    config = { extra = { levels = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,
    use = function(self, card, area, copier)
        local highest, second = -1, -1
        local highKey, secondKey = 'Pair', 'High Card'
        for hand_key, hand in pairs(G.GAME.hands) do
            if hand.played > highest then
                secondKey, second = highKey, highest
                highKey, highest = hand_key, hand.played
            elseif hand.played > second and hand.played < highest then
                secondKey, second = hand_key, hand.played
            end
        end
        if highest == 0 and second == 0 then
            secondKey = 'High Card'
        end
        delay(0.5)
        SMODS.smart_level_up_hand(card, secondKey, nil, card.ability.extra.levels)
    end,
    can_use = function(self, card)
        return true
    end,
}

SMODS.Consumable {
    key = 'springfield',
    loc_txt = {
        name = "Springfield",
        text = {
            "Create a random",
            "{C:attention}Springfield{} Joker"
        }
    },
    set = 'SimpsonsTrading',
    atlas = 'SimpsTrading',
    pos = { x = 1, y = 2 },
    discovered = true,
    config = { },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        SMODS.add_card({ set = 'SpringfieldJokers', legendary = false })
        play_sound("timpani")
    end,
    can_use = function(self, card)
        return #G.jokers.cards < G.jokers.config.card_limit or card.area == G.jokers
    end,
}

SMODS.Consumable {
    key = 'tyrefire',
    loc_txt = {
        name = 'Tyre Fire',
        text = {
            "Enhances {C:attention}#1#{}",
            "selected card into",
            "a {C:attention}Burnt{} Card",
        }
    },
    set = 'SimpsonsTrading',
    atlas = 'SimpsTrading',
    pos = { x = 2, y = 2 },
    discovered = true,
    config = { max_highlighted = 1, mod_conv = 'm_simpson_burnt' },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted } }
    end,
}

SMODS.Consumable {
    key = 'hams',
    loc_txt = {
        name = 'Steamed Hams',
        text = {
            "Enhances up to {C:attention}#1#{}",
            "selected cards into",
            "{C:attention}Grilled{} Cards",
        }
    },
    set = 'SimpsonsTrading',
    atlas = 'SimpsTrading',
    pos = { x = 3, y = 2 },
    discovered = true,
    config = { max_highlighted = 2, mod_conv = 'm_simpson_grilled' },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted } }
    end,
}

SMODS.Consumable {
    key = 'toaster1',
    loc_txt = {
        name = 'Time Travel Toaster',
        text = {
            "Enhances {C:attention}#1#{}",
            "selected card into",
            "a {C:attention}Yellow{} Card",
        }
    },
    set = 'SimpsonsTrading',
    atlas = 'SimpsTrading',
    pos = { x = 2, y = 1 },
    discovered = true,
    config = { max_highlighted = 1, mod_conv = 'm_simpson_yellow' },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted } }
    end,
}

SMODS.Consumable {
    key = 'purplehomersimpson',
    loc_txt = {
        name = 'The Curse',
        text = {
            "Enhances up to {C:attention}#1#{}",
            "selected cards into",
            "{C:attention}Purple{} Cards",
        }
    },
    set = 'SimpsonsTrading',
    atlas = 'SimpsTrading',
    pos = { x = 4, y = 1 },
    discovered = true,
    config = { max_highlighted = 2, mod_conv = 'm_simpson_purple' },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted } }
    end,
}

SMODS.Consumable {
    key = 'hairball',
    loc_txt = {
        name = 'Hairball',
        text = {
            'Gives {C:attention}#1#{} card',
            "a random enhancement",
        }
    },
    set = 'SimpsonsTrading',
    atlas = 'SimpsTrading',
    pos = { x = 4, y = 2 },
    discovered = true,
    config = { max_highlighted = 1 },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.max_highlighted } }
    end,
    use = function(self, card, area, copier)
        local cen_pool = {}
        for _, enhancement_center in pairs(G.P_CENTER_POOLS["Enhanced"]) do
            cen_pool[#cen_pool + 1] = enhancement_center
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            local enhancement = pseudorandom_element(cen_pool, 'spe_card')
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability(enhancement.key)
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end
}

SMODS.Consumable {
    key = 'radioactiveman',
    loc_txt = {
        name = 'Radioactive Man',
        text = {
            'Gives {C:attention}#1#{} cards',
            "an {V:1}Acid{} Seal",
        }
    },
    set = 'SimpsonsTrading',
    atlas = 'SimpsTrading',
    pos = { x = 2, y = 0 },
    discovered = true,
    config = { max_highlighted = 2 },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_SEALS['simpson_acid']
        return { vars = { card.ability.max_highlighted, colours = { HEX('96cc2e') } } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            G.hand.highlighted[i]:set_seal('simpson_acid', nil, true)
        end
        delay(0.2)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end
}