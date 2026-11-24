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
            '{C:money}$#1#{} for every card destroyed',
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
            '{C:green,E:1}#1# in #2#{} chance to give',
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
                if not SMODS.has_no_rank(context.scoring_hand[i]) then
                    if context.scoring_hand[i]:get_id() == 14 then
                        counter = counter + 1
                    else
                        counter = counter + context.scoring_hand[i]:get_id()
                    end
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
            '{C:green,E:1}#1# in #2#{} chance to level up a random',
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
                            context.full_hand[i]:set_seal()
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
            '{C:attention}2{}s, {C:attention}3{}s, {C:attention}4{}s and {C:attention}5{}s',
            'have a {C:green,E:1}#1# in #2#{} chance to',
            'give {C:red}+#3#{} Mult, {C:chips}+#4#{} Chips',
            'and {C:money}$#5#{} individually'
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

    config = { extra = { odds = 3, mult = 3, chips = 20, dollars = 4 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "fat_and_ugly")
        return { vars = { numerator, denominator, card.ability.extra.mult, card.ability.extra.chips, card.ability.extra.dollars } }
    end,

    calculate = function (self, card, context)
        if context.cardarea == G.play and context.individual and context.other_card then
            if context.other_card:get_id() == 2 or context.other_card:get_id() == 3 or context.other_card:get_id() == 4 or context.other_card:get_id() == 5 then
                local ret = {}
                if SMODS.pseudorandom_probability(card, 'fat_and_ugly', 1, card.ability.extra.odds) then
                    ret.mult = card.ability.extra.mult
                end
                if SMODS.pseudorandom_probability(card, 'fat_and_ugly', 1, card.ability.extra.odds) then
                    ret.chips = card.ability.extra.chips
                end
                if SMODS.pseudorandom_probability(card, 'fat_and_ugly', 1, card.ability.extra.odds) then
                    ret.dollars = card.ability.extra.dollars
                end
                return ret
            end
        end
    end
}

SMODS.Joker {
    key = 'incredible_homer',
    loc_txt = {
        name = 'The Incredible Homer',
        text = {
            '{C:green,E:1}#1# in #2#{} to create an {C:attention}enhanced{}',
            '{C:attention}face{} card when a card is {C:attention}destroyed{}',
            '{C:inactive}(Cards are added when setting blind){}',
            '{C:inactive}(Currently{} {C:attention}#3#{} {C:inactive}cards to add){}',
        }
    },
    blueprint_compat = false,
    rarity = 1,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 5, y = 3 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { odds = 3, removed = 0 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "greenman")
        return { vars = { numerator, denominator, card.ability.extra.removed } }
    end,

    calculate = function (self, card, context)
        if context.remove_playing_cards then
            for i = 1, #context.removed do
                if SMODS.pseudorandom_probability(card, 'greenman', 1, card.ability.extra.odds) then
                    card.ability.extra.removed = card.ability.extra.removed + 1
                end
            end
        end
        if context.setting_blind then
            for i = 1, card.ability.extra.removed do
                local cen_pool = {}
                for _, enhancement_center in pairs(G.P_CENTER_POOLS["Enhanced"]) do
                    if enhancement_center.key ~= 'm_stone' and not enhancement_center.overrides_base_rank then
                        cen_pool[#cen_pool + 1] = enhancement_center
                    end
                end
                local enhancement = pseudorandom_element(cen_pool, 'spe_card')
                local ranks = {"King", "Queen", "Jack"}
                local stone_card = SMODS.add_card { set = "Base", rank = ranks[pseudorandom("toptenny", 1,3)], enhancement = enhancement.key, area = G.deck }
                func = function()
                    SMODS.calculate_context({ playing_card_added = true, cards = { stone_card } })
                end
            end
            if card.ability.extra.removed > 0 then
                SMODS.calculate_effect({message = "HOMER MAD", colour = G.C.GREEN }, card)
            end
            card.ability.extra.removed = 0
        end
    end
}

SMODS.Joker {
    key = 'daredevil_bart',
    loc_txt = {
        name = 'Bart the Daredevil',
        text = {
            '{C:chips}+#1#{} Chips',
            '{C:attention}#2#{} Joker slots'
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 1, y = 4 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { chips = 280, slots = -1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.slots } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            return { chips = card.ability.extra.chips }
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.slots
                return true
            end
        }))
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.slots
                return true
            end
        }))
    end
}

SMODS.Joker {
    key = 'bartman',
    loc_txt = {
        name = 'Bartman',
        text = {
            '{X:red,C:white}X#1#{} Mult for every card',
            'discarded this {C:attention}ante{}',
            '{C:inactive}(Currently{} {X:red,C:white}X#2#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 2, y = 4 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { xmult = 1, xmult_gain = 0.07 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_gain, card.ability.extra.xmult } }
    end,

    calculate = function (self, card, context)
        if context.discard and not context.blueprint and context.other_card then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
            SMODS.calculate_effect({message = "X"..card.ability.extra.xmult, colour = G.C.RED}, card)
        end
        if context.end_of_round and context.game_over == false and context.main_eval and G.GAME.blind.boss and not context.blueprint then
            card.ability.extra.xmult = 1
            return {
                message = "Reset!",
                colour = G.C.RED
            }
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}

SMODS.Joker {
    key = 'el_barto',
    loc_txt = {
        name = 'El Barto',
        text = {
            '{X:red,C:white}X#1#{} for every',
            'Mult card in deck',
            '{C:inactive}(Currently{} {X:red,C:white}X#2#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 3, y = 4 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { xmult_gain = 0.2 } },

    loc_vars = function(self, info_queue, card)
        local enhanced_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_mult') then
                    enhanced_tally = enhanced_tally + 1 
                end
            end
        end
        return { vars = { card.ability.extra.xmult_gain, (enhanced_tally * card.ability.extra.xmult_gain) + 1 } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            local enhanced_tally = 0
            if G.playing_cards then
                for _, playing_card in ipairs(G.playing_cards) do
                    if SMODS.has_enhancement(playing_card, 'm_mult') then
                        enhanced_tally = enhanced_tally + 1 
                    end
                end
            end
            return { xmult = (enhanced_tally * card.ability.extra.xmult_gain) + 1 }
        end
    end,

    in_pool = function(self, args)
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_mult') then
                return true
            end
        end
        return false
    end
}

SMODS.Joker {
    key = 'char_hugo_simpson',
    loc_txt = {
        name = 'Hugo Simpson',
        text = {
            'Gains {C:chips}+#1#{} Chips when a',
            '{V:1}Simpsons Trading Card{} is used',
            'or {C:chips}+#3#{} Chips when a {C:red}Duff{}',
            '{C:red}Card{} is used',
            '{C:inactive}(Currently{}{C:chips} +#2#{} {C:inactive}Chips){}',
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = false,
    atlas = 'SimpsDups',
    pos = { x = 4, y = 4 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Twin', 'Secret', 'Crazy'},

    config = { extra = { chips = 0, chips_gain = 5, chips_gain_duff = 15 } },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS['c_simpson_duff']
        return { vars = { card.ability.extra.chips_gain, card.ability.extra.chips, card.ability.extra.chips_gain_duff, colours = { HEX(G_C_SIMPSONS_TRADING_CARD)} } }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and context.consumeable.config.center.set == 'SimpsonsTrading' and not context.blueprint then
            if context.consumeable.config.center.key == 'c_simpson_duff' then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_gain_duff
                return {
                    message = 'Upgrade!',
                    colour = G.C.CHIPS
                }
            else
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_gain
                return {
                    message = 'Upgrade!',
                    colour = G.C.CHIPS
                }
            end
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
            }
        end
    end,
}

SMODS.Joker {
    key = 'cupcake_kid',
    loc_txt = {
        name = 'Cupcake Kid',
        text = {
            '{C:chips}+#1#{} Chips for each',
            'blind {C:attention}skipped{} this run',
            '{C:inactive}(Currently{}{C:chips} +#2#{} {C:inactive}Chips){}',
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 5, y = 4 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { chips_gain = 40 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips_gain, (G.GAME.skips * card.ability.extra.chips_gain) or 0 } }
    end,

    calculate = function (self, card, context)
        if context.skip_blind and not context.blueprint then
            SMODS.calculate_effect({message = "+"..(G.GAME.skips * card.ability.extra.chips_gain), colour = G.C.CHIPS }, card)
        end
        if context.joker_main then
            return { chips = (G.GAME.skips * card.ability.extra.chips_gain) or 0 }
        end
    end
}

SMODS.Joker {
    key = 'vampire_bart',
    loc_txt = {
        name = 'Bart the Vampire',
        text = {
            'All cards lose {C:chips}#1#{} Chips and',
            'gain {C:red}+#2#{} Mult when played'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 1, y = 5 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { chip_gain = -2, mult = 1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chip_gain, card.ability.extra.mult } }
    end,

    calculate = function (self, card, context)
        if context.cardarea == G.play and context.individual and context.other_card then
            context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + card.ability.extra.chip_gain
            context.other_card.ability.perma_mult = (context.other_card.ability.perma_mult or 0) + card.ability.extra.mult
            return {
                message = 'Sucked!',
                colour = G.C.RED
            }
        end
    end
}

SMODS.Joker {
    key = 'bort',
    loc_txt = {
        name = 'Bort',
        text = {
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
    pos = { x = 2, y = 5 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { chips = 40 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            return { chips = card.ability.extra.chips }
        end
    end
}

SMODS.Joker {
    key = 'fat_bart',
    loc_txt = {
        name = 'Fat Bart',
        text = {
            'Gains {X:red,C:white}X#1#{} every {C:attention}2{}',
            '{C:purple}Tarot{} Cards used',
            '{C:inactive}(Currently{} {X:red,C:white}X#2#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = false,
    atlas = 'SimpsDups',
    pos = { x = 3, y = 5 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { xmult_gain = 0.4, xmult = 1, counter = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_gain, card.ability.extra.xmult } }
    end,

    calculate = function (self, card, context)
        if context.using_consumeable and not context.blueprint and context.consumeable.ability.set == ("Tarot") then
            card.ability.extra.counter = card.ability.extra.counter + 1
            if card.ability.extra.counter == 2 then
                card.ability.extra.xmult = card.ability.extra.xmult - card.ability.extra.xmult_gain
                card.ability.extra.counter = 0
                return {
                    message = "Upgrade!",
                    colour = G.C.RED
                }
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}

SMODS.Joker {
    key = 'shadow_knight',
    loc_txt = {
        name = 'Shadow Knight',
        text = {
            'Gains {X:red,C:white}X#1#{} every',
            '{C:attention}3{} Cards sold',
            '{C:inactive}(Currently{} {X:red,C:white}X#2#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 4, y = 5 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { xmult_gain = 0.5, xmult = 1, counter = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_gain, card.ability.extra.xmult } }
    end,

    calculate = function (self, card, context)
        if context.selling_card and not context.blueprint then
            card.ability.extra.counter = card.ability.extra.counter + 1
            if card.ability.extra.counter == 3 then
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
                card.ability.extra.counter = 0
                return {
                    message = 'Upgrade!',
                    colour = G.C.RED
                }
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}

SMODS.Joker {
    key = 'retro_bart',
    loc_txt = {
        name = 'Retro Bart',
        text = {
            'Earn {C:money}$#1#{} at the',
            'end of the round',
            'Gains {C:money}$#2#{} every {C:attention}#3#{}',
            'cards discarded',
            '{C:inactive}({}{C:attention}#4#{} {C:inactive}cards remaining){}'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 5, y = 5 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { dollars = 2, dollar_gain = 1, cards = 40, counter = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.dollar_gain, card.ability.extra.cards, (card.ability.extra.cards - card.ability.extra.counter) } }
    end,

    calculate = function (self, card, context)
        if context.discard and not context.blueprint and context.other_card then
            card.ability.extra.counter = card.ability.extra.counter + 1
            if card.ability.extra.counter == card.ability.extra.cards then
                card.ability.extra.dollars = card.ability.extra.dollars + card.ability.extra.dollar_gain
                card.ability.extra.counter = 0
                return { message = "Upgrade!", colour = G.C.MONEY }
            end
        end
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end
}

SMODS.Joker {
    key = 'bart_general',
    loc_txt = {
        name = 'Bart the General',
        text = {
            'Played {C:attention}5{}s and {C:attention}10{}s',
            'give {C:red}+#1#{} Mult'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 1, y = 6 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { mult = 4 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function (self, card, context)
        if context.other_card and context.individual and context.cardarea == G.play and (context.other_card:get_id() == 5 or context.other_card:get_id() == 10) then
            return { 
                mult = card.ability.extra.mult
            }
        end
    end
}

SMODS.Joker {
    key = 'fortnite_bart',
    loc_txt = {
        name = 'Bart-le Royale',
        text = {
            'Lose {C:money}$#1#{} and gains',
            '{X:red,C:white}X#2#{} Mult when selecting',
            'a blind',
            '{C:inactive}(Currently{} {X:red,C:white}X#3#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 2, y = 6 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { dollar_loss = 5, xmult = 1, xmult_gain = 0.2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollar_loss, card.ability.extra.xmult_gain, card.ability.extra.xmult } }
    end,

    calculate = function (self, card, context)
        if context.setting_blind then
            if not context.blueprint then
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
            end
            return {
                dollars = -card.ability.extra.dollar_loss
            }
        end
        if context.joker_main then
            return { xmult = card.ability.extra.xmult }
        end
    end
}

SMODS.Joker {
    key = 'older_bart',
    loc_txt = {
        name = 'Moocher',
        text = {
            'Create a random {V:1}Simpsons{}',
            '{V:1}Trading Card{} if hand played',
            'with {C:money}$#1#{} or less'
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 9,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 3, y = 6 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { dollars = 4 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, colours = { HEX(G_C_SIMPSONS_TRADING_CARD) } } } 
    end,

    calculate = function (self, card, context)
        if context.joker_main and
            #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            if G.GAME.dollars <= card.ability.extra.dollars then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = (function()
                        SMODS.add_card {
                            set = 'SimpsonsTrading',
                        }
                        G.GAME.consumeable_buffer = 0
                        return true
                    end)
                }))
                SMODS.calculate_effect({ message = '+1 Trading Card', colour = HEX(G_C_SIMPSONS_TRADING_CARD) }, context.blueprint_card or card)
            end
        end
    end
}

SMODS.Joker {
    key = 'lego_bart',
    loc_txt = {
        name = 'LEGO Bart',
        text = {
            'Create a random {C:purple}Tarot{} card',
            'when any cards are destroyed'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 4, y = 6 },
    pools = { ['SpringfieldJokers'] = true },

    calculate = function (self, card, context)
        if context.remove_playing_cards then
            for i = 1, #context.removed do
                if i == #context.removed and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        func = (function()
                            SMODS.add_card {
                                set = 'Tarot',
                            }
                            G.GAME.consumeable_buffer = 0
                            return true
                        end)
                    }))
                    return {
                        message = localize('k_plus_tarot'),
                    }
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'fat_bart_again',
    loc_txt = {
        name = 'VERY Fat Bart',
        text = {
            'Earn {C:money}$#1#{} every {C:attention}#2#{}',
            '{V:1}Simpsons Trading Cards{} used'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsDups',
    pos = { x = 5, y = 6 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { dollars = 10, cards = 4, counter = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.cards, colours = { HEX(G_C_SIMPSONS_TRADING_CARD) } } }
    end,

    calculate = function (self, card, context)
        if context.using_consumeable and context.consumeable.config.center.set == 'SimpsonsTrading' then
            card.ability.extra.counter = card.ability.extra.counter + 1
            if card.ability.extra.counter == card.ability.extra.cards then
                card.ability.extra.counter = 0
                return {
                    dollars = card.ability.extra.dollars
                }
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