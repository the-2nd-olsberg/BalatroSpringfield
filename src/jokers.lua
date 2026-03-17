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
    blueprint_compat = true,
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

    config = { extra = { chips_gain = 5, mult_gain = 1, chips = 0, mult = 0 } },

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
            'Retrigger each played',
            '{C:attention}6{}, {C:attention}7{} and {C:attention}8{}'
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

    config = { extra = { xmult = 3, discount = -60 } },

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

    remove_from_deck = function(self, card, from_debuff)
         G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.discount_percent = 37.5
                for _, v in pairs(G.I.CARD) do
                    if v.set_cost then v:set_cost() end
                end
                return true
            end
        }))
    end
}

SMODS.Joker {
    key = 'apu',
    loc_txt = {
        name = 'Apu Nahasapeemapetilon',
        text = {
            'Earn {C:money}$#2#{} at the end of the',
            'round for every {C:attention}third{} {C:green}Reroll',
            '{C:inactive}(Currently{} {C:money}$#1#{}{C:inactive}){}',
        }
    },
    blueprint_compat = false,
    rarity = 1,
    cost = 4,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 5, y = 3 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { thirdrerolls = 0, current_rerolls = 0, three = 3 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.thirdrerolls * card.ability.extra.three, card.ability.extra.three } }
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
        return card.ability.extra.thirdrerolls * card.ability.extra.three
    end
}

SMODS.Joker {
    key = 'moe',
    loc_txt = {
        name = 'Moe',
        text = {
            'Earn {C:money}$#2#{} at the end of the round',
            'Gains {C:money}$#1#{} when a {C:red}Duff{} Card is used',
            'TBC'
        }
    },
    blueprint_compat = false,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 1, y = 4 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { dollar_gain = 1, dollars = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollar_gain, card.ability.extra.dollar } }
    end,

    calculate = function(self, card, context)
        
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end
}

SMODS.Joker {
    key = 'abe',
    loc_txt = {
        name = 'Abe Simpson',
        text = {
            'Level up a random',
            'hand every {C:attention}2{} rounds'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 2, y = 4 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { counter = 0 } },

    calculate = function (self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval then
            if card.ability.extra.counter == 1 then
                SMODS.smart_level_up_hand(card, pseudorandom_element(G.handlist, 'abesimpson'), nil, levels)
            end
            card.ability.extra.counter = card.ability.extra.counter + 1
            if card.ability.extra.counter == 2 then
                card.ability.extra.counter = 0
            end
        end
    end
}

SMODS.Joker {
    key = 'diamondjoe',
    loc_txt = {
        name = 'Mayor Quimby',
        text = {
            'Retrigger played',
            '{C:attention}Queens{} twice'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 3, y = 4 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { repetitions = 2 } },
    
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card:get_id() == 12 then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
    end,
}

SMODS.Joker {
    key = 'smithers',
    loc_txt = {
        name = 'Smithers',
        text = {
            'Retrigger played {C:attention}Kings{}',
            'once and {C:attention}Jacks{} twice'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 4, y = 4 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { jackrepetitions = 2, kingrepetitions = 1 } },
    
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card:get_id() == 13 then
            return {
                repetitions = card.ability.extra.kingrepetitions
            }
        end
        if context.repetition and context.cardarea == G.play and context.other_card:get_id() == 11 then
            return {
                repetitions = card.ability.extra.jackrepetitions
            }
        end
    end,
}

SMODS.Joker {
    key = 'wiggum',
    loc_txt = {
        name = 'Chief Wiggum',
        text = {
            '{X:red,C:white}X#1#{} Mult',
            'Debuff {C:attention}#2#',
            'Gain {X:red,C:white}X#3#{} Mult if {C:attention}#2#{} is played',
            '{C:inactive}(Hand Type changes at the start of the round)'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = false,
    atlas = 'SimpsJokers',
    pos = { x = 5, y = 4 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { xmult = 1, hand_type = 'Pair', xmult_gain = 0.3, me_debuffing = false } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.hand_type, card.ability.extra.xmult_gain } }
    end,

    calculate = function (self, card, context)
        if context.debuff_hand and not context.blueprint then
            if context.scoring_name == card.ability.extra.hand_type then
                card.ability.extra.me_debuffing = true
                return {
                    debuff = true
                }
            end
        end
        if context.debuffed_hand and not context.blueprint and card.ability.extra.me_debuffing then
            card.ability.extra.me_debuffing = false
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
            return {
                message = 'Upgrade!'
            }
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
        if context.setting_blind and not context.blueprint then
            card.ability.extra.hand_type = pseudorandom_element(G.handlist, 'wiggum')
        end
    end
}

SMODS.Joker {
    key = 'barney',
    loc_txt = {
        name = 'Barney',
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
    pos = { x = 1, y = 5 },
    pools = { ['SpringfieldJokers'] = true },
}

SMODS.Joker {
    key = 'hibbert',
    loc_txt = {
        name = 'Dr. Hibbert',
        text = {
            '{C:green}#1# in #2#{} chance to give',
            'each played card a random {C:attention}Seal'
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 2, y = 5 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { odds = 3 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "hibbert")
        return { vars = { numerator, denominator } }
    end,

    calculate = function (self, card, context)
        if context.cardarea == G.play and context.individual and context.other_card and not context.blueprint then
            if SMODS.pseudorandom_probability(card, "hibbert", 1, card.ability.extra.odds) then
                context.other_card:set_seal(SMODS.poll_seal({key = 'supercharge', guaranteed = true}), nil, true)
            end
        end        
    end
}

SMODS.Joker {
    key = 'milhouse',
    loc_txt = {
        name = 'Milhouse',
        text = {
            'Played {C:attention}2{}-{C:attention}7{}s gain {C:chips}+#1#{} Chips when scored',
            'Played {C:attention}8{}-{C:attention}A{}s lose {C:chips}-#2#{} Chips when scored'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 3, y = 5 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { chip_gain = 7, chip_loss = 3 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chip_gain, card.ability.extra.chip_loss } }
    end,

    calculate = function (self, card, context)
        if context.cardarea == G.play and context.individual and context.other_card then
            if context.other_card:get_id() <= 7 then
                context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + card.ability.extra.chip_gain
                return {
                    message = 'Upgrade!'
                }
            end
            if context.other_card:get_id() >= 8 then
                context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) - card.ability.extra.chip_loss
                return {
                    message = 'Downgrade!'
                }
            end
        end    
    end
}

SMODS.Joker {
    key = 'nelson',
    loc_txt = {
        name = 'Nelson',
        text = {
            '{C:red}+#1#{} Mult for every',
            '{C:attention}Debuffed{} card in played hand'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 4, y = 5 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { mult = 5 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            local debuffed_cards = 0
            for i = 1, #context.full_hand do
                if context.full_hand[i].debuff then
                    debuffed_cards = debuffed_cards + 1
                end
            end
            return {
                mult = card.ability.extra.mult * debuffed_cards
            }
        end
    end
}

SMODS.Joker {
    key = 'lovejoy',
    loc_txt = {
        name = 'Rev. Lovejoy',
        text = {
            'All cards in {C:attention}first{}',
            'played hand are made {C:attention}Leatherbound{}',
            'TBC'
        }
    },
    blueprint_compat = false,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 5, y = 5 },
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
    key = 'troy',
    loc_txt = {
        name = 'Troy McClure',
        text = {
            'TBC'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 1, y = 6 },
    pools = { ['SpringfieldJokers'] = true },
}

SMODS.Joker {
    key = 'chalmers',
    loc_txt = {
        name = 'Superintendent Chalmers',
        text = {
            '{C:green}#1# in #2#{} chance for each played',
            '{V:1}Club{} to give {X:red,C:white}X#3#{} Mult'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 2, y = 6 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { odds = 2, xmult = 1.5 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "chalmers")
        return { vars = { numerator, denominator, card.ability.extra.xmult, colours = { G.C.SUITS.Clubs } } }
    end,

    calculate = function(self, card, context)
        if context.other_card and context.individual and context.cardarea == G.play and context.other_card:is_suit('Clubs') then
            if SMODS.pseudorandom_probability(card, "chalmers", 1, card.ability.extra.odds) then
                return { xmult = card.ability.extra.xmult }
            end
        end
    end
}

SMODS.Joker {
    key = 'ralph',
    loc_txt = {
        name = 'Ralph Wiggum',
        text = {
            'All played cards give',
            'between {C:chips}+#1#{} and {C:chips}+#2#{} Chips'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 3,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 3, y = 6 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { chip_b = 5, chip_t = 20 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chip_b, card.ability.extra.chip_t } }
    end,

    calculate = function(self, card, context)
        if context.other_card and context.individual and context.cardarea == G.play and context.other_card then
            return {
                chips = pseudorandom('ralphie', card.ability.extra.chip_b, card.ability.extra.chip_t)
            }
        end
    end
}

SMODS.Joker {
    key = 'martin',
    loc_txt = {
        name = 'Martin',
        text = {
            'All ranks of played cards',
            'added up and given as {C:chips}Chips'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 4, y = 6 },
    pools = { ['SpringfieldJokers'] = true },

    calculate = function(self, card, context)
        if context.joker_main then
            local ranks_add = 0
            for i = 1, #context.scoring_hand do
                ranks_add = ranks_add + context.scoring_hand[i]:get_id()
            end
            return {
                chips = ranks_add
            }
        end
    end
}

SMODS.Joker {
    key = 'spiderpig',
    loc_txt = {
        name = 'Spider Pig',
        text = {
            'Played {C:attention}Aces{} give',
            '{C:red}+#1#{} Mult and are',
            'retriggered'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 5, y = 6 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { mult = 2, repetitions = 1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card:get_id() == 14 then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 14 then
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
    end,
}

SMODS.Joker {
    key = 'nerds',
    loc_txt = {
        name = 'College Nerds',
        text = {
            'Played cards with a {C:attention}Prime{}',
            'rank give {C:red}+#1#{} Mult'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 1, y = 7 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { mult = 3 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card then
            local n = context.other_card:get_id()
            for i = 2, n^(1/2) do
                if (n % i) == 0 then
                    return {
                        mult = 0
                    }
                end
            end
            return {
                mult = card.ability.extra.mult
            }
        end
    end,
}

SMODS.Joker {
    key = 'hutz',
    loc_txt = {
        name = 'Lionel Hutz',
        text = {
            'All played cards in first',
            'hand are converted to {C:attention}#1#{}',
            '{C:inactive}(Suit changes at the end of the ante)'
        }
    },
    blueprint_compat = false,
    rarity = 3,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 2, y = 7 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { suit = 'Hearts' } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.suit } }
    end,

    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local eval = function() return G.GAME.current_round.hands_played == 0 and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
        end
        if context.before and context.main_eval and not context.blueprint and G.GAME.current_round.hands_played == 0 then
            for i = 1, #context.full_hand do
            local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    context.full_hand[i]:flip()
                    play_sound('card1', percent)
                    context.full_hand[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
            end
            local _suit = card.ability.extra.suit
            for i = 1, #context.full_hand do
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local _card = context.full_hand[i]
                        assert(SMODS.change_base(_card, _suit))
                        return true
                    end
                }))
            end
            for i = 1, #context.full_hand do
                local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        context.full_hand[i]:flip()
                        play_sound('tarot2', percent, 0.6)
                        context.full_hand[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
        end
        if context.end_of_round and context.game_over == false and context.main_eval and G.GAME.blind.boss then
            card.ability.extra.suit = pseudorandom_element(SMODS.Suits, 'hutz').key
        end
    end
}

SMODS.Joker {
    key = 'willie',
    loc_txt = {
        name = 'Groundskeeper Willie',
        text = {
            'Gain {C:money}$#1#{} when a',
            '{C:attention}Simpsons Trading Card{} is used',
            'TBC: Currently does Tarots'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 3, y = 7 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { dollars = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint and context.consumeable.ability.set == ("Tarot") then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
            return {
                dollars = card.ability.extra.dollars,
                func = function() -- This is for timing purposes, this goes after the dollar modification
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.GAME.dollar_buffer = 0
                            return true
                        end
                    }))
                end
            }
        end
    end,
}

SMODS.Joker {
    key = 'grimey',
    loc_txt = {
        name = 'Frank Grimes',
        text = {
            '{C:red}+#1#{} Mult',
            'Mult is {C:attention}exponentiated{} by',
            '{C:blue}#2#{} at the end of the round',
            'Joker destroyed if Mult exceeds {C:red}+60',
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 8,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 4, y = 7 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { mult = 3, exponent = 1.2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.exponent } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.mult = card.ability.extra.mult^1.2
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

SMODS.Joker {
    key = 'bob',
    loc_txt = {
        name = 'Sideshow Bob',
        text = {
            'Gains {C:red}+#1#{} Mult',
            'when a {C:attention}Joker{} is sold',
            '{C:inactive}(Currently{} {C:red}+#3#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 5, y = 7 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { chip_gain = 6, mult_gain = 4, chips = 0, mult = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chip_gain, card.ability.extra.mult_gain, card.ability.extra.chips, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.selling_card and context.card.ability and context.card.ability.set == 'Joker' and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
            return {
                message = 'Upgrade!'
            }
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.chips,
            }
        end
    end
}

SMODS.Joker {
    key = 'nick',
    loc_txt = {
        name = 'Dr. Nick',
        text = {
            'All items in the {C:money}shop{}',
            'cost {C:attention}#3#%{} less',
            '{C:green}#1# in #2#{} chance for every',
            'purchased card to be {C:attention}destroyed'
        }
    },
    blueprint_compat = false,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 1, y = 8 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { odds = 3, discount = 35 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "hieverybody")
        return { vars = { numerator, denominator, card.ability.extra.discount } }
    end,

    calculate = function(self, card, context)
        if context.buying_card and not context.blueprint and context.card.ability and context.card.ability.set ~= 'Voucher' and context.card.ability.set ~= 'Booster' then
            if SMODS.pseudorandom_probability(card, "hieverybody", 1, card.ability.extra.odds) then
                SMODS.destroy_cards(context.card)
            end
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

    remove_from_deck = function(self, card, from_debuff)
         G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.discount_percent = 53.8462
                for _, v in pairs(G.I.CARD) do
                    if v.set_cost then v:set_cost() end
                end
                return true
            end
        }))
    end
}



SMODS.Joker {
    key = 'comicbook',
    loc_txt = {
        name = 'Comic Book Guy',
        text = {
            'All Jokers with an {C:attention}Edition{} gain',
            '{C:money}$#1#{} in sell value at the end of the round',
            'All scored cards with an {C:attention}Edition{} give {C:money}$#2#{}',
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 2, y = 8 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { sell_value = 2, dollars = 3 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.sell_value, card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            for _, area in ipairs({ G.jokers, G.consumeables }) do
                for _, other_card in ipairs(area.cards) do
                    if other_card.set_cost and other_card.ability and other_card.ability.set == 'Joker' and other_card.edition then
                        other_card.ability.extra_value = (other_card.ability.extra_value or 0) +
                            card.ability.extra.sell_value
                        other_card:set_cost()
                    end
                end
            end
            return {
                message = localize('k_val_up'),
                colour = G.C.MONEY
            }
        end
        if context.individual and context.cardarea == G.play and context.other_card and context.other_card.edition then
            return {
                dollars = card.ability.extra.dollars
            }
        end
    end
}

SMODS.Joker {
    key = 'fat_tony',
    loc_txt = {
        name = 'Fat Tony',
        text = {
            '{C:green}#1# in #2#{} chance of destroying each',
            '{C:attention}played card{} and giving {C:money}$#3#',
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 3, y = 8 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { odds = 4, dollars = 4 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'fatman')
        return { vars = { numerator, denominator, card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.destroy_card and context.cardarea == G.play and SMODS.pseudorandom_probability(card, 'fatman', 1, card.ability.extra.odds) and not context.blueprint then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
            return { 
                remove = true,
                message = "Sleeping with the fishes",
                dollars = card.ability.extra.dollars,
                func = function() -- This is for timing purposes, this goes after the dollar modification
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
    key = 'moleman',
    loc_txt = {
        name = 'Hans Moleman',
        text = {
            'Sell this {C:attention}Joker{} to lower',
            '{C:attention}Blind{} requirement by {C:attention}#1#%'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 4,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 4, y = 8 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { percent = 35 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.percent } }
    end,

    calculate = function(self, card, context)
        if context.selling_self then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = function()
                    G.GAME.blind.chips =  G.GAME.blind.chips - (G.GAME.blind.chips * (card.ability.extra.percent/100) )
                    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                    return true
                end
            }))
        end
    end
}

SMODS.Joker {
    key = 'mel',
    loc_txt = {
        name = 'Sideshow Mel',
        text = {
            '{X:red,C:white}X#1#{} Mult',
            'loses {X:red,C:white}X#2#{} Mult',
            'every reroll'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 5, y = 8 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { xmult = 1.6, xmult_loss = 0.05 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_loss } }
    end,

    calculate = function(self, card, context)
        if context.reroll_shop and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult - card.ability.extra.xmult_loss
            return {
                message = 'Loss!',
                colour = G.C.MULT
            }
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,
}

SMODS.Joker {
    key = 'brockman',
    loc_txt = {
        name = 'Kent Brockman',
        text = {
            'Earn {C:money}$#1#{} at the end of the round',
            'Gains {C:money}$#2#{} after every {C:attention}#3#{}',
            'cards {C:attention}discarded',
            '{C:inactive}(#4# discards remaining)'
        }
    },
    blueprint_compat = false,
    rarity = 2,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 1, y = 9 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { dollars = 1, dollar_gain = 1, discards = 15, discards_remaining = 15 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.dollar_gain, card.ability.extra.discards, card.ability.extra.discards_remaining } }
    end,

    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            if card.ability.extra.discards_remaining <= 1 then
                card.ability.extra.discards_remaining = card.ability.extra.discards
                card.ability.extra.dollars = card.ability.extra.dollars + card.ability.extra.dollar_gain
                return {
                    message = 'Upgrade!',
                    colour = G.C.MONEY
                }
            else
                card.ability.extra.discards_remaining = card.ability.extra.discards_remaining - 1
                return nil, true
            end
        end
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end
}

SMODS.Joker {
    key = 'frink',
    loc_txt = {
        name = 'Professor Frink',
        text = {
            'Gains {C:chips}+#2#{} Chips when',
            'a {C:blue}Planet{} card is used',
            '{C:inactive}(Currently{} {C:chips}+#1#{} {C:inactive}Chips){}',
        }
    },
    blueprint_compat = false,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 2, y = 9 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { chips = 0, chip_gain = 5 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chip_gain } }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint and context.consumeable.ability.set == ("Planet") then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
            return {
                message = 'Glavin!'
            }
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
            }
        end
    end,
}

SMODS.Joker {
    key = 'bluehair',
    loc_txt = {
        name = 'Blue Haired Lawyer',
        text = {
            'All scored {V:1}Clubs{} give {C:money}$#1#{}',
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 3, y = 9 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { dollars = 3 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, colours = { G.C.SUITS.Clubs } } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card and context.other_card:is_suit('Clubs') then
            return {
                dollars = card.ability.extra.dollars
            }
        end
    end
}

SMODS.Joker {
    key = 'mcbain',
    loc_txt = {
        name = 'McBain',
        text = {
            'Played {C:attention}face{} cards give',
            '{C:red}+#1#{} Mult and are destroyed'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 4, y = 9 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { mult = 8 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.other_card and context.individual and context.cardarea == G.play and context.other_card:is_face(true) then
            return { mult = card.ability.extra.mult }
        end
        if context.destroy_card and context.cardarea == G.play and context.destroy_card:is_face() and not context.blueprint then
            return { remove = true }
        end
    end
}

SMODS.Joker {
    key = 'rodntodd',
    loc_txt = {
        name = 'Rod and Todd',
        text = {
            'This Joker gains {C:red}+#1#{} Mult per',
            '{C:attention}consecutive{} hand played while',
            'scoring a {C:attention}face{} card',
            '{C:inactive}(Currently{} {C:red}+#2#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 5, y = 9 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { mult_gain = 1, mult = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_gain, card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.before and context.main_eval and not context.blueprint then
            local faces = false
            for _, playing_card in ipairs(context.scoring_hand) do
                if playing_card:is_face() then
                    faces = true
                end
            end
            if faces then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
            else
                local last_mult = card.ability.extra.mult
                card.ability.extra.mult = 0
                if last_mult > 0 then
                    return {
                        message = localize('k_reset')
                    }
                end
            end
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}