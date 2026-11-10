--Atlas
SMODS.Atlas {
    key = 'SimpsDups',
    path = 'duplicates.png',
    px = 71,
    py = 95
}

--Jokers
SMODS.Joker {
    key = 'angry_dad',
    loc_txt = {
        name = 'Angry Dad',
        text = {
            'Destroys all played cards',
            'in first played hand',
            '{C:money}$#1#{} at the end of the round',
            'for every card destroyed',
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 1, y = 1 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { dollars = 1, active = true, cards = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function (self, card, context)
        if context.destroy_card and context.cardarea == G.play and not context.blueprint and G.GAME.current_round.hands_played == 0 then
            card.ability.extra.cards = #context.scoring_hand
            card.ability.extra.active = true
            return {
                remove = true
            }
        end
        if context.remove_playing_cards and card.ability.extra.active then
            card.ability.extra.active = false
            return { dollars = card.ability.extra.cards }
        end
    end
}

SMODS.Joker {
    key = 'evil_homer',
    loc_txt = {
        name = 'Evil Homer',
        text = {
            'Gives {C:money}$#1#{} for every',
            '{C:attention}#2#{} cards destroyed'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 2, y = 1 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { dollars = 2, cards = 4, counter = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.cards } }
    end,

    calculate = function (self, card, context)
        if context.remove_playing_cards then
            for i = 1, #context.removed do
                card.ability.extra.counter = card.ability.extra.counter + 1
                if card.ability.extra.counter % card.ability.extra.cards == 0 then
                    G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + (card.ability.extra.dollars)
                    return {
                        dollars = (card.ability.extra.dollars),
                        func = function()
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    G.GAME.dollar_buffer = 0
                                    return true
                                end
                            }))
                        end
                    }
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'guy_incognito',
    loc_txt = {
        name = 'Guy Incognito',
        text = {
            'Flips and shuffles all',
            'Jokers when setting blind',
            '{C:chips}+#1#{} Chips'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 3, y = 1 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { chips = 100 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function (self, card, context)
        if context.setting_blind and not context.blueprint then
            if #G.jokers.cards > 0 then
                G.jokers:unhighlight_all()
                for _, joker in ipairs(G.jokers.cards) do
                    joker:flip()
                end
                if #G.jokers.cards > 1 then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.2,
                        func = function()
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    G.jokers:shuffle('aajk')
                                    play_sound('cardSlide1', 0.85)
                                    return true
                                end,
                            }))
                            delay(0.15)
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    G.jokers:shuffle('aajk')
                                    play_sound('cardSlide1', 1.15)
                                    return true
                                end
                            }))
                            delay(0.15)
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    G.jokers:shuffle('aajk')
                                    play_sound('cardSlide1', 1)
                                    return true
                                end
                            }))
                            delay(0.5)
                            return true
                        end
                    }))
                end
            end
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint and G.GAME.blind.boss then
            if #G.jokers.cards > 0 then
                G.jokers:unhighlight_all()
                for _, joker in ipairs(G.jokers.cards) do
                    joker:flip()
                end
            end
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}

SMODS.Joker {
    key = 'pie_man',
    loc_txt = {
        name = 'Pie Man',
        text = {
            '{C:green}#1# in #2#{} chance to give',
            'a random {C:planet}Planet{} card when',
            'hand is played',
            '{C:inactive}(Chance changes based on how',
            '{C:inactive}many cards are played)'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 4, y = 1 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { odds = 1, playing_hand = false, planets = 1 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "pie")
        return { vars = { numerator, denominator } }
    end,

    calculate = function (self, card, context)
        if context.before and not context.blueprint then
            card.ability.extra.playing_hand = true
            card.ability.extra.odds = #context.full_hand
        end
        if context.after then
            if SMODS.pseudorandom_probability(card, "pie", 1, card.ability.extra.odds) then
                for i = 1, math.min(card.ability.extra.planets, G.consumeables.config.card_limit - #G.consumeables.cards) do
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.4,
                        func = function()
                            if G.consumeables.config.card_limit > #G.consumeables.cards then
                                play_sound('timpani')
                                SMODS.add_card({ set = 'Planet' })
                                card:juice_up(0.3, 0.5)
                            end
                            return true
                        end
                    }))
                end
                delay(0.6)
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    card.ability.extra.playing_hand = false
                    return true
                end
            }))
        end
    end,

    update = function(self, card, dt)
        if not card.ability.extra.playing_hand and G.STATE == 1 then
            card.ability.extra.odds = #G.hand.highlighted
        end
    end
}

SMODS.Joker {
    key = 'retro_homer',
    loc_txt = {
        name = 'Retro Homer',
        text = {
            '{C:attention}8{}s give {C:chips}+#1#{} Chips',
            'and {C:red}+#2#{} Mult when scored'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 5, y = 1 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { chips = 16, mult = 4 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.mult } }
    end,

    calculate = function (self, card, context)
        if context.other_card and context.individual and context.cardarea == G.play and context.other_card:get_id() == 8 then
            return { 
                chips = card.ability.extra.chips,
                mult = card.ability.extra.mult
            }
        end
    end
}

SMODS.Joker {
    key = 'king_homer',
    loc_txt = {
        name = 'King Homer',
        text = {
            '{C:attention}Face{} cards gain {C:chips}+#1#{} Chips',
            'when scored'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 1, y = 2 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { chip_gain = 7 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chip_gain } }
    end,

    calculate = function (self, card, context)
        if context.cardarea == G.play and context.individual and context.other_card then
            if context.other_card:is_face() then
                context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + card.ability.extra.chip_gain
                return {
                    message = 'Upgrade!',
                    colour = G.C.CHIPS
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'king_sized_homer',
    loc_txt = {
        name = 'King Sized Homer',
        text = {
            '{C:red}+#1#{} Mult for every',
            'card in scoring hand'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 2, y = 2 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { mult = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult * #context.scoring_hand
            }
        end
    end
}

SMODS.Joker {
    key = 'senator_homer',
    loc_txt = {
        name = 'Senator Homer',
        text = {
            'Earn {C:money}$#1#{} if any',
            'purchased item is free'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 3, y = 2 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { dollars = 5 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function (self, card, context)
        if context.buying_card and context.card.cost == 0 then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + (card.ability.extra.dollars)
            return {
                dollars = (card.ability.extra.dollars),
                func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.GAME.dollar_buffer = 0
                            return true
                        end
                    }))
                end
            }
        end
    end
}

SMODS.Joker {
    key = 'teen_homer',
    loc_txt = {
        name = 'Teen Homer',
        text = {
            '{C:red}+#1#{} Mult if all ranks added',
            'together in {C:attention}scoring{} hand',
            'become a teen',
            '{C:inactive}(Between 13 and 19)'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 4, y = 2 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { mult = 7 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            local counter = 0
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i]:get_id() == 14 then
                    counter = counter + 1
                else
                    counter = counter + context.scoring_hand[i]:get_id()
                end
            end
            if counter > 12 and counter < 20 then
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'astronaut_homer',
    loc_txt = {
        name = 'Deep Space Homer',
        text = {
            '{C:green}#1# in #2#{} chance to level up a random',
            'hand when a {C:planet}Planet{} card is used'
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 5, y = 2 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { odds = 2 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "space")
        return { vars = { numerator, denominator } }
    end,

    calculate = function (self, card, context)
        if context.using_consumeable and not context.blueprint and context.consumeable.ability.set == ("Planet") and SMODS.pseudorandom_probability(card, "space", 1, card.ability.extra.odds) then
            local handy = pseudorandom_element(G.handlist, 'space_homer')
            SMODS.upgrade_poker_hands({hands = {handy}, level_up = 1, from = card})
        end
    end
}

SMODS.Joker {
    key = 'mr_plow',
    loc_txt = {
        name = 'Mr. Plow',
        text = {
            'Remove Seals from all',
            'played cards after scoring',
            '{C:money}$#1#{} for every Seal removed'
        }
    },
    blueprint_compat = false,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 1, y = 3 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { dollars = 4 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function (self, card, context)
        if context.final_scoring_step and not context.blueprint then
            local counter = 0
            G.E_MANAGER:add_event(Event({
                func = (function()
                    for i = 1, #context.full_hand do
                        if context.full_hand[i].seal then
                            counter = counter + 1
                            card:set_seal()
                        end
                    end
                    return true
                end)
            }))
        end
    end
}

SMODS.Joker {
    key = 'homer3',
    loc_txt = {
        name = 'Homer3',
        text = {
            '{X:red,C:white}X#1#{} Mult on third',
            'hand of the round'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 2, y = 3 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { xmult = 3 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function (self, card, context)
        if context.joker_main and G.GAME.current_round.hands_played == 2 then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}

SMODS.Joker {
    key = 'lego_homer',
    loc_txt = {
        name = 'LEGO Homer',
        text = {
            'Every Joker gives',
            '{C:chips}+#1#{} Chips'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 3, y = 3 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { chips = 15 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function (self, card, context)
        if context.other_joker then
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}

SMODS.Joker {
    key = 'large_baby',
    loc_txt = {
        name = 'Unusually Large, Ugly Baby',
        text = {
            '{C:attention}#3#{}s, {C:attention}#4#{}s, {C:attention}#5#{}s and {C:attention}#6#{}s',
            'have a {C:green}#1# in #2#{} chance to',
            'give {C:red}+#7#{} Mult, {C:chips}#8#{} Chips',
            'and {C:money}$#9#{} individually'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 4, y = 3 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { odds = 3, ranks = {2, 3, 4, 5}, mult = 3, chips = 20, dollars = 4 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "fat_and_ugly")
        return { vars = { numerator, denominator, card.ability.extra.ranks[1], card.ability.extra.ranks[2], card.ability.extra.ranks[3], card.ability.extra.ranks[4], card.ability.extra.mult, card.ability.extra.chips, card.ability.extra.dollars } }
    end,

    calculate = function (self, card, context)
        if context.cardarea == G.play and context.individual and context.other_card then
            if context.other_card:get_id() == card.ability.extra.ranks[1] or context.other_card:get_id() == card.ability.extra.ranks[2] or context.other_card:get_id() == card.ability.extra.ranks[3] or context.other_card:get_id() == card.ability.extra.ranks[4] then
                local ret = {}
                if SMODS.pseudorandom_probability(card, 'fat_and_ugly', 1, card.ability.extra.mult_odds) then
                    ret.mult = card.ability.extra.mult
                end
                if SMODS.pseudorandom_probability(card, 'fat_and_ugly', 1, card.ability.extra.mult_odds) then
                    ret.chips = card.ability.extra.chips
                end
                if SMODS.pseudorandom_probability(card, 'fat_and_ugly', 1, card.ability.extra.dollars_odds) then
                    ret.dollars = card.ability.extra.dollars
                end
                return ret
            end
        end
    end
}

--[[
SMODS.Joker {
    key = '',
    loc_txt = {
        name = '',
        text = {
            ''
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 1,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 0, y = 0 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = {  } },

    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,

    calculate = function (self, card, context)
    
    end
}
]]