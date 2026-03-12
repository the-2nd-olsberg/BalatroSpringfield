--Atlas
SMODS.Atlas {
    key = 'SimpsJokers',
    path = 'jokers.png',
    px = 71,
    py = 95
    
}

--Pool
SMODS.ObjectType({
	key = 'SpringfieldJokers',
	default = 'j_simpson_homer',
	cards = {},
	inject = function(self)
		SMODS.ObjectType.inject(self)
	end,
})

--Jokers
SMODS.Joker {
    key = 'homer',
    loc_txt = {
        name = 'Homer Simpson',
        text = {
            'If hand contains {C:attention}5{} cards,',
            'destroy the last {C:attention}scored{} card',
            'and gain {C:red}+#1#{} Mult',
            '{C:inactive}(Currently{} {C:red}+#2#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = false,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = false,
    atlas = 'SimpsJokers',
    pos = { x = 1, y = 1 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { mult_gain = 4, mult = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_gain, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.destroy_card and context.scoring_hand and context.cardarea == G.play and 
        #context.full_hand == 5 and (context.destroy_card == context.scoring_hand[#context.scoring_hand])
        and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
            return {
                remove = true,
                message = 'Mmmm... cards...'
            }
        end

        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

SMODS.Joker {
    key = 'bart',
    loc_txt = {
        name = 'Bart Simpson',
        text = {
            '{X:red,C:white}X#1#{} Mult',
            'Debuff all {C:attention}face{} cards',
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 2, y = 1 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { xmult = 1.5 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            for k, v in pairs(G.playing_cards) do
                if v:is_face(true) then
                    SMODS.debuff_card(v, true, "bart_debuff")
                end
            end
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            for k, v in pairs(G.playing_cards) do
                if v:is_face(true) then
                    SMODS.debuff_card(v, false, "bart_debuff")
                end
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        for k, v in pairs(G.playing_cards) do
            if v:is_face(true) then
                SMODS.debuff_card(v, true, "bart_debuff")
            end
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        for k, v in pairs(G.playing_cards) do
            if v:is_face(true) then
                SMODS.debuff_card(v, false, "bart_debuff")
            end
        end
    end
}

SMODS.Joker{
    key = 'lisa',
    loc_txt = {
        name = 'Lisa Simpson',
        text = {
            'First {C:attention}two{} cards in',
            '{C:attention}first{} played hand are',
            'given random {C:attention}enhancements'
        }
    },
    blueprint_compat = false,
    rarity = 2,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 3, y = 1 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { cards = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,

    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local eval = function() return G.GAME.current_round.hands_played == 0 and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
        end
        if context.before and context.main_eval and not context.blueprint and G.GAME.current_round.hands_played == 0 then
            local cen_pool = {}
            for _, enhancement_center in pairs(G.P_CENTER_POOLS["Enhanced"]) do
                if enhancement_center.key ~= 'm_stone' and not enhancement_center.overrides_base_rank then
                    cen_pool[#cen_pool + 1] = enhancement_center
                end
            end
            local amount = 0
            local enhanced = false
            for _, scored_card in ipairs(context.scoring_hand) do
                if amount < 2 and scored_card.config.center.key == 'c_base' then
                    scored_card:set_ability(pseudorandom_element(cen_pool, 'spe_card').key, nil, true)
                    enhanced = true
                end
                amount = amount + 1
            end
            if enhanced == true then
                SMODS.calculate_effect({message = 'Lizard Queen'}, card)
            end
        end
    end
}

SMODS.Joker {
    key = 'maggie',
    loc_txt = {
        name = 'Maggie Simpson',
        text = {
            'Played {C:attention}face{} cards give',
            '{C:chips}+#1#{} Chips when scored'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 4, y = 1 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { chips = 20 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.other_card and context.individual and context.cardarea == G.play and context.other_card:is_face(true) then
            return { chips = card.ability.extra.chips }
        end
    end
}

SMODS.Joker {
    key = 'marge',
    loc_txt = {
        name = 'Marge Simpson',
        text = {
            'Removes {C:attention}enhancements',
            'from all {C:attention}played{} cards',
            'Gains {C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult',
            'for every {C:attention}enhancement{} removed',
            '{C:inactive}(Currently{} {C:chips}+#3#{} {C:inactive}Chips{}{C:red} +#4#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = false,
    atlas = 'SimpsJokers',
    pos = { x = 5, y = 1 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { chips_gain = 10, mult_gain = 0.5, chips = 0, mult = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips_gain, card.ability.extra.mult_gain, card.ability.extra.chips, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.before and context.main_eval and not context.blueprint then
            local amount = 0
            for _, scored_card in ipairs(context.scoring_hand) do
                if scored_card.config.center.key ~= 'c_base' then
                    scored_card:set_ability('c_base', nil, true)
                    amount = amount + 1
                end
            end
            if amount >= 1 then
                card.ability.extra.chips = card.ability.extra.chips + (card.ability.extra.chips_gain * amount)
                card.ability.extra.mult = card.ability.extra.mult + (card.ability.extra.mult_gain * amount)
                SMODS.calculate_effect({message = 'Cleaned!'}, card)
            end
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
                mult = card.ability.extra.mult
            }
        end
    end
}

SMODS.Joker {
    key = 'lenny',
    loc_txt = {
        name = 'Lenny',
        text = {
            'Played {V:1}Hearts{} and {V:2}Diamonds{}',
            'give {C:red}+#1#{} Mult when scored'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 1, y = 2 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { mult = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.mult,

            colours = { 
                G.C.SUITS.Hearts,
                G.C.SUITS.Diamonds
                }
            }       
        }
    end,

    calculate = function(self, card, context)
        if context.other_card and context.individual and context.cardarea == G.play and (context.other_card:is_suit('Hearts') or context.other_card:is_suit('Diamonds')) then
            return { mult = card.ability.extra.mult }
        end
    end
}

SMODS.Joker {
    key = 'carl',
    loc_txt = {
        name = 'Carl',
        text = {
            'Played {V:1}Clubs{} and {V:2}Spades{}',
            'give {C:red}+#1#{} Mult when scored'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 2, y = 2 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { mult = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.mult,

            colours = { 
                G.C.SUITS.Clubs,
                G.C.SUITS.Spades
                }
            }       
        }
    end,

    calculate = function(self, card, context)
        if context.other_card and context.individual and context.cardarea == G.play and (context.other_card:is_suit('Clubs') or context.other_card:is_suit('Spades')) then
            return { mult = card.ability.extra.mult }
        end
    end
}

SMODS.Joker {
    key = 'groening',
    loc_txt = {
        name = 'Matt Groening',
        text = {
            'TBC'
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 3, y = 2 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { mult = 2 } },
}

SMODS.Joker {
    key = 'santashelper',
    loc_txt = {
        name = "Santa's Little Helper",
        text = {
            'Faster you play your',
            'hand the better'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 4, y = 2 },
    pools = { ['SpringfieldJokers'] = true },

    config = { 
        extra = { 
            S_rank = {3, 1.5, 15},
            A_rank = {8, 10},
            B_rank = {15, 6},
            C_rank = {20, 4},
            D_rank = {30, 3},
            E_rank = {40, 2},
            F_rank = {45, 1},
            AFK = {46, 1},
            do_reset = 1,
            starting_time = 0,
            in_seconds_kinda = 0,
        } 
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.S_rank[2],
            card.ability.extra.S_rank[3],
            card.ability.extra.A_rank[2],
            card.ability.extra.B_rank[2],
            card.ability.extra.C_rank[2],
            card.ability.extra.D_rank[2],
            card.ability.extra.E_rank[2],
            card.ability.extra.F_rank[2],
            card.ability.extra.AFK[2],
        } }
    end,

    calculate = function(self, card, context)
        if context.hand_drawn then
            if card.ability.extra.do_reset == 1 then
                card.ability.extra.starting_time = os.time{year=tonumber(os.date("%Y")), month=tonumber(os.date("%m")), day=tonumber(os.date("%d")), 
                                                           hour=tonumber(os.date("%H")), min=tonumber(os.date("%M")), sec=tonumber(os.date("%S"))}
                return { message = 'Timer starts now!' }
            else
                return { message = 'Still counting!' }
            end
        end
        if context.discard then
            card.ability.extra.do_reset = 0
        end
        if context.joker_main then
            card.ability.extra.do_reset = 1
            local current_time = os.time{year=tonumber(os.date("%Y")), month=tonumber(os.date("%m")), day=tonumber(os.date("%d")), 
                                         hour=tonumber(os.date("%H")), min=tonumber(os.date("%M")), sec=tonumber(os.date("%S"))}
            card.ability.extra.in_seconds_kinda = os.difftime(current_time, card.ability.extra.starting_time)
            print(card.ability.extra.in_seconds_kinda)
            if card.ability.extra.in_seconds_kinda <= card.ability.extra.S_rank[1] then
                return {
                    xmult = card.ability.extra.S_rank[2],
                    mult = card.ability.extra.S_rank[3],
                    message = 'Super Fast!'
                }
            end
            if card.ability.extra.in_seconds_kinda <= card.ability.extra.A_rank[1] then
                return {
                    mult = card.ability.extra.A_rank[2],
                    message = 'Pretty Fast!'
                }
            end
            if card.ability.extra.in_seconds_kinda <= card.ability.extra.B_rank[1] then
                return {
                    mult = card.ability.extra.B_rank[2],
                    message = 'Fast!'
                }
            end
            if card.ability.extra.in_seconds_kinda <= card.ability.extra.C_rank[1] then
                return {
                    mult = card.ability.extra.C_rank[2],
                    message = 'Kinda falling behind!'
                }
            end
            if card.ability.extra.in_seconds_kinda <= card.ability.extra.D_rank[1] then
                return {
                    mult = card.ability.extra.D_rank[2],
                    message = 'Loser!'
                }
            end
            if card.ability.extra.in_seconds_kinda <= card.ability.extra.E_rank[1] then
                return {
                    mult = card.ability.extra.E_rank[2],
                    message = 'Give up!'
                }
            end
            if card.ability.extra.in_seconds_kinda <= card.ability.extra.F_rank[1] then
                return {
                    mult = card.ability.extra.F_rank[2],
                    message = "Bart's Dog Gets an F!"
                }
            end
            return {
                chips = card.ability.extra.AFK[2],
                message = 'Someone went AFK, huh?'
            }
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        card.ability.extra.starting_time = os.time{year=tonumber(os.date("%Y")), month=tonumber(os.date("%m")), day=tonumber(os.date("%d")), hour=tonumber(os.date("%H")), min=tonumber(os.date("%M")), sec=tonumber(os.date("%S"))}
    end,
}

SMODS.Joker {
    key = 'snowball2',
    loc_txt = {
        name = 'Snowball II',
        text = {
            'TBC'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 5, y = 2 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { mult = 2 } },
}

SMODS.Joker {
    key = "krusty",
    loc_txt = {
        name = 'Krusty the Clown',
        text = {
            'Retrigger all played',
            '{C:attention}6{}s, {C:attention}7{}s and {C:attention}8{}s'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = false,
    atlas = 'SimpsJokers',
    pos = { x = 1, y = 3 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { repetitions = 1 } },
    
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and (context.other_card:get_id() == 6 or context.other_card:get_id() == 7 or context.other_card:get_id() == 8) then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
    end,
}

SMODS.Joker {
    key = 'skinner',
    loc_txt = {
        name = 'Principal Skinner',
        text = {
            'If hand played scores more than',
            '{C:attention}50%{} of required blind score,',
            'gain a random {C:purple}Tarot{} card'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 2, y = 3 },
    pools = { ['SpringfieldJokers'] = true },

    calculate = function(self, card, context)
        if context.final_scoring_step then
            if hand_chips * mult >= (G.GAME.blind.chips / 2) and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = (function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                SMODS.add_card {
                                    set = 'Tarot',
                                }
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))
                        SMODS.calculate_effect({message = "Well done, student!"}, card)
                        return true
                    end)
                }))
                return nil, true
            end
        end
    end
}

SMODS.Joker {
    key = 'flanders',
    loc_txt = {
        name = 'Ned Flanders',
        text = {
            '{C:green}#1# in #2#{} chance to enchance the {C:attention}2{}',
            ' last scored cards when {C:attention}5{} cards are played'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 3, y = 3 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { odds = 3 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "neddy")
        return { vars = { numerator, denominator } }
    end,

    calculate = function(self, card, context)
        if context.before and context.main_eval and not context.blueprint and SMODS.pseudorandom_probability(card, "neddy", 1, card.ability.extra.odds) and #context.scoring_hand == 5 then
            local cen_pool = {}
            for _, enhancement_center in pairs(G.P_CENTER_POOLS["Enhanced"]) do
                if enhancement_center.key ~= 'm_stone' and not enhancement_center.overrides_base_rank then
                    cen_pool[#cen_pool + 1] = enhancement_center
                end
            end
            context.scoring_hand[5]:set_ability(pseudorandom_element(cen_pool, 'spe_card').key, nil, true)
            context.scoring_hand[4]:set_ability(pseudorandom_element(cen_pool, 'spe_card').key, nil, true)
            SMODS.calculate_effect({message = 'Howdilly doodily!'}, card)
        end
    end
}

SMODS.Joker {
    key = 'burns',
    loc_txt = {
        name = 'Mr. Burns',
        text = {
            '{X:red,C:white}X#1#{} Mult',
            'All items in the {C:money}shop{}',
            'cost {C:attention}#2#%{} more'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 4, y = 3 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { xmult = 3, discount = -75 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, -card.ability.extra.discount } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.discount_percent = card.ability.extra.discount
                for _, v in pairs(G.I.CARD) do
                    if v.set_cost then v:set_cost() end
                end
                return true
            end
        }))
    end,
}

SMODS.Joker {
    key = 'apu ',
    loc_txt = {
        name = 'Apu Nahasapeemapetilon',
        text = {
            'Earn {C:money}$3{} at the end of the',
            'round for every {C:attention}third{} {C:green}Reroll',
            '{C:inactive}(Currently{} {C:money}$#1#{}{C:inactive}){}',
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 5, y = 3 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { thirdrerolls = 0, current_rerolls = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.thirdrerolls * 3 } }
    end,

    calculate = function(self, card, context)
        if context.reroll_shop and not context.blueprint then
            card.ability.extra.current_rerolls = card.ability.extra.current_rerolls + 1
            if card.ability.extra.current_rerolls == 3 then
                card.ability.extra.current_rerolls = 0
                card.ability.extra.thirdrerolls = card.ability.extra.thirdrerolls + 1
                return {
                message = 'Upgrade!',
                colour = G.C.MONEY,
            }
            end
        end
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.thirdrerolls * 3
    end
}