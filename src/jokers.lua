--Atlas
SMODS.Atlas {
    key = 'SimpsJokers',
    path = 'springjokers.png',
    px = 71,
    py = 95
}

--Pool
SMODS.ObjectType({
	key = 'SpringfieldJokers',
	default = 'j_simpson_char_homer',
	cards = {},
	inject = function(self)
		SMODS.ObjectType.inject(self)
	end,
})

--Jokers
SMODS.Joker {
    key = 'char_homer',
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
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = false,
    atlas = 'SimpsJokers',
    pos = { x = 1, y = 1 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Fat', 'Bald', 'Simpson'},

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
    key = 'char_bart',
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
    hints = {'Boy', 'Slingshot', 'Simpson'},

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
    key = 'char_lisa',
    loc_txt = {
        name = 'Lisa Simpson',
        text = {
            'First {C:attention}2{} cards in',
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
    hints = {'Girl', 'Simpson', 'Saxaphone'},

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
                if amount < 2 then
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
    key = 'char_maggie',
    loc_txt = {
        name = 'Maggie Simpson',
        text = {
            'Played {C:attention}face{} cards give',
            '{C:chips}+#1#{} Chips and {C:red}+#2#{} Mult',
            'when scored'
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
    hints = {'Girl', 'Baby', 'Simpson'},

    config = { extra = { chips = 20, mult = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.other_card and context.individual and context.cardarea == G.play and context.other_card:is_face(true) then
            return { chips = card.ability.extra.chips, mult = card.ability.extra.mult }
        end
    end
}

SMODS.Joker {
    key = 'char_marge',
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
    hints = {'Simpson', 'Mother', 'Blue hair'},

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
    key = 'char_lenny',
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
    hints = {'Skinny', "Moe's", 'Man'},

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
    key = 'char_carl',
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
    hints = {'Skinny', "Moe's", 'Black'},

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
    key = 'char_groening',
    loc_txt = {
        name = 'Matt Groening',
        text = {
            '{C:attention}Yellow Cards give',
            'an additional {X:red,C:white}X#1#{} Mult'
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
    hints = {'Man', 'Important', 'Creator'},

    config = { extra = { xmult = 1.3 } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS['m_simpson_yellow']
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.other_card and context.individual and context.cardarea == G.play and SMODS.has_enhancement(context.other_card, 'm_simpson_yellow') then
            return { xmult = card.ability.extra.xmult }
        end
    end,

    in_pool = function(self, args)
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_simpson_yellow') then
                return true
            end
        end
        return false
    end
}

SMODS.Joker {
    key = 'char_santashelper',
    loc_txt = {
        name = "Santa's Little Helper",
        text = {
            'Faster you play your',
            'hand the better {C:red}Mult{}',
            'you receive!'
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
    hints = {'Animal', 'Dog', 'Simpson'},

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
    key = 'char_snowball2',
    loc_txt = {
        name = 'Snowball II',
        text = {
            'Creates a {C:red}Hairball',
            'when selecting a blind'
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
    hints = {'Cat', 'Black', 'Simpson'},

    config = { extra = {  } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS['c_simpson_hairball']
        return { vars = {  } }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = (function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            SMODS.add_card {
                                key = 'c_simpson_hairball'
                            }
                            G.GAME.consumeable_buffer = 0
                            return true
                        end
                    }))
                    SMODS.calculate_effect({ message = 'Bluegh!', colour = G.C.RED }, context.blueprint_card or card)
                    return true
                end)
            }))
            return nil, true
        end
    end,
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
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = false,
    atlas = 'SimpsJokers',
    pos = { x = 1, y = 3 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Man', 'Important', 'Clown'},

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
    key = 'char_skinner',
    loc_txt = {
        name = 'Principal Skinner',
        text = {
            'If hand played scores more than',
            '{C:attention}50%{} of required blind score,',
            'gain a random {C:purple}Tarot{} card'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 2, y = 3 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Man', 'Head', 'School'},

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
    key = 'char_flanders',
    loc_txt = {
        name = 'Ned Flanders',
        text = {
            '{C:green}#1# in #2#{} chance to enchance the {C:attention}2{}',
            'last scored cards when {C:attention}5{} cards are played'
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
    hints = {'Man', 'Friendly', 'Neighbourino'},

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
    key = 'char_burns',
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
    hints = {'Man', 'Important', 'Old'},

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
                G.GAME.discount_percent = 0
                for _, v in pairs(G.I.CARD) do
                    if v.set_cost then v:set_cost() end
                end
                return true
            end
        }))
    end
}

SMODS.Joker {
    key = 'char_apu',
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
    hints = {'Man', 'Business Owner', 'Loves to Listen'},

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
    key = 'char_moe',
    loc_txt = {
        name = 'Moe',
        text = {
            'Earn {C:money}$#2#{} at the end of the round',
            'Gains {C:money}$#1#{} when a {C:red}Duff{} Card is used',
        }
    },
    blueprint_compat = false,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 1, y = 4 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {"It's Moe", "It's Moe", "It's Moe"},

    config = { extra = { dollar_gain = 1, dollars = 1 } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS['c_simpson_duff']
        return { vars = { card.ability.extra.dollar_gain, card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and context.consumeable.config.center.set == 'SimpsonsTrading' and context.consumeable.config.center.key == 'c_simpson_duff' and not context.blueprint then
            card.ability.extra.dollars = card.ability.extra.dollars + card.ability.extra.dollar_gain
            return {
                message = 'Upgrade!',
                colour = G.C.MONEY
            }
        end
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end
}

SMODS.Joker {
    key = 'char_abe',
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
    hints = {'Man', 'Old', 'Simpsons'},

    config = { extra = { counter = 0, levels = 1 } },

    calculate = function (self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval then
            if card.ability.extra.counter == 1 then
                local handy = pseudorandom_element(G.handlist, 'abesimpson')
                SMODS.upgrade_poker_hands({hands = {handy}, level_up = 1, from = card})
            end
            card.ability.extra.counter = card.ability.extra.counter + 1
            if card.ability.extra.counter == 2 then
                card.ability.extra.counter = 0
            end
        end
    end
}

SMODS.Joker {
    key = 'char_diamondjoe',
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
    hints = {'Man', 'Important', 'Mayor'},

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
    key = 'char_smithers',
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
    hints = {'Man', 'Loyal', 'Gay'},

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
    key = 'char_wiggum',
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
    hints = {'Police', 'Man', 'Fat'},

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
    key = 'char_barney',
    loc_txt = {
        name = 'Barney',
        text = {
            'Retrigger all played',
            '{C:attention}Alcoholic{} Cards'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 1, y = 5 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {"Moe's", 'Drunk', 'Like, REALLY Drunk'},

    config = { extra = { repetitions = 1 } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS['m_simpson_alcohol']
        return { vars = { } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and SMODS.has_enhancement(context.other_card, 'm_simpson_alcohol') then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
    end,
    in_pool = function(self, args)
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_simpson_alcohol') then
                return true
            end
        end
        return false
    end
}

SMODS.Joker {
    key = 'char_hibbert',
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
    hints = {'Man', 'Friendly', 'Doctor'},

    config = { extra = { odds = 4 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "hibbert")
        return { vars = { numerator, denominator } }
    end,

    calculate = function (self, card, context)
        if context.before and not context.blueprint then
            for i = 1, #context.scoring_hand do
                if SMODS.pseudorandom_probability(card, "hibbert", 1, card.ability.extra.odds) and not context.scoring_hand[i]:get_seal() then
                    context.scoring_hand[i]:set_seal(SMODS.poll_seal({key = 'supercharge', guaranteed = true}), nil, true)
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'char_milhouse',
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
    hints = {'Useless', 'Unimportant', 'Friend'},

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
    key = 'char_nelson',
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
    hints = {'Boy', 'Interesting', 'Bully'},

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
    key = 'char_lovejoy',
    loc_txt = {
        name = 'Rev. Lovejoy',
        text = {
            'First {C:attention}#1#{} cards in {C:attention}first{}',
            'played hand are made {C:attention}Leatherbound{}',
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
    hints = {'Man', 'Important', 'Christian'},

    config = { extra = { cards = 3 } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS['m_simpson_leatherbound']
        return { vars = { card.ability.extra.cards } }
    end,

    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local eval = function() return G.GAME.current_round.hands_played == 0 and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
        end
        if context.before and context.main_eval and not context.blueprint and G.GAME.current_round.hands_played == 0 then
            local amount = 0
            local enhanced = false
            for _, scored_card in ipairs(context.scoring_hand) do
                if amount < card.ability.extra.cards then
                    scored_card:set_ability('m_simpson_leatherbound', nil, true)
                    enhanced = true
                end
                amount = amount + 1
            end
            if enhanced == true then
                SMODS.calculate_effect({message = 'Amen.'}, card)
            end
        end
    end
}

SMODS.Joker {
    key = 'char_troy',
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
    hints = {'Man', 'Washed', 'Famous'},

    in_pool = function(self, args)
        return false
    end
}

SMODS.Joker {
    key = 'char_chalmers',
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
    hints = {'Man', 'Important', 'School'},

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
    key = 'char_ralph',
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
    hints = {'Boy', 'Silly', 'Likes Men Now'},

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
    key = 'char_martin',
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
    hints = {'School', 'Boy', 'Smart'},

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
    key = 'char_spiderpig',
    loc_txt = {
        name = 'Spider Pig',
        text = {
            'Played {C:attention}Aces{} give',
            '{C:red}+#1#{} Mult and are',
            'retriggered'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 5, y = 6 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Animal', 'Love', 'Movie'},

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
    key = 'char_nerds',
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
    hints = {'School', '"Men"', 'School!'},

    config = { extra = { mult = 3 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card then
            local prime = true
            local n = context.other_card:get_id()
            for i = 2, n^(1/2) do
                if (n % i) == 0 then
                    prime = false
                end
            end
            if prime then
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
    end,
}

SMODS.Joker {
    key = 'char_hutz',
    loc_txt = {
        name = 'Lionel Hutz',
        text = {
            'All played cards in first',
            'hand are converted to {V:1}#1#{}',
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
    hints = {'Man', '"Important"', '"Smart"'},

    config = { extra = { suit = 'Hearts' } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.suit, colours = { G.C.SUITS[card.ability.extra.suit] } } }
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
        if context.end_of_round and context.game_over == false and context.main_eval and G.GAME.blind.boss and not context.blueprint then
            card.ability.extra.suit = pseudorandom_element(SMODS.Suits, 'hutz').key
        end
    end
}

SMODS.Joker {
    key = 'char_willie',
    loc_txt = {
        name = 'Groundskeeper Willie',
        text = {
            'Earn {C:money}$#1#{} when',
            'a {V:1}Simpsons Trading',
            '{V:1}Card{} is used'
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
    hints = {'Man', 'Blue-Collar', 'School'},

    config = { extra = { dollars = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, colours = {HEX(G_C_SIMPSONS_TRADING_CARD)} } }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint and context.consumeable.config.center.set == 'SimpsonsTrading' then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
            return {
                dollars = card.ability.extra.dollars,
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
    end,
}

SMODS.Joker {
    key = 'char_grimey',
    loc_txt = {
        name = 'Frank Grimes',
        text = {
            '{C:red}+#1#{} Mult',
            'Mult is {C:attention}exponentiated{} by',
            '{C:blue}#2#{} at the end of the round',
            'Joker destroyed if Mult exceeds {C:red}+#3#',
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
    hints = {'Man', 'Subversive', 'Power Plant'},

    config = { extra = { mult = 3, exponent = 1.2, max = 60 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.exponent, card.ability.extra.max } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.mult = card.ability.extra.mult^1.2
            if card.ability.extra.mult > card.ability.extra.max then
                card:remove()
                return {
                    message = "I'm Homer Simpson!"
                }
            end
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

SMODS.Joker {
    key = 'char_bob',
    loc_txt = {
        name = 'Sideshow Bob',
        text = {
            'Gains {C:red}+#1#{} Mult',
            'when a {C:attention}Joker{} is sold',
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
    pos = { x = 5, y = 7 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Man', 'Dangerous', 'Rake'},

    config = { extra = { mult_gain = 6, mult = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_gain, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.selling_card and context.card.ability and context.card.ability.set == 'Joker' and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
            return {
                message = 'Upgrade!'
            }
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
            }
        end
    end
}

SMODS.Joker {
    key = 'char_nick',
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
    hints = {'Doctor', 'Dangerous', 'Cheap'},

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
                G.GAME.discount_percent = 0
                for _, v in pairs(G.I.CARD) do
                    if v.set_cost then v:set_cost() end
                end
                return true
            end
        }))
    end
}



SMODS.Joker {
    key = 'char_comicbook',
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
    hints = {'Loser', 'Man', 'Comics'},

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
    key = 'char_fat_tony',
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
    hints = {'Dangerous', 'Man', 'Important'},

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
    key = 'char_moleman',
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
    eternal_compat = false,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 4, y = 8 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Small', 'Old', 'Like, REALLY Old'},

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
    key = 'char_mel',
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
    hints = {'Man', 'Partner', 'Clown'},
    
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
    key = 'char_brockman',
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
    hints = {'Man', 'Important', 'News'},

    config = { extra = { dollars = 1, dollar_gain = 1, discards = 25, discards_remaining = 25 } },

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
    key = 'char_frink',
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
    hints = {'Man', 'Smart', 'Weird'},

    config = { extra = { chips = 0, chip_gain = 7 } },

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
    key = 'char_bluehair',
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
    hints = {'Man', 'Important', 'Law'},

    config = { extra = { dollars = 1 } },

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
    key = 'char_wolfcastle',
    loc_txt = {
        name = 'Rainier Wolfcastle',
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
    hints = {'Man', 'Important', 'Actor'},

    config = { extra = { mult = 15 } },

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
    key = 'char_rodntodd',
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
    hints = {'Kids', 'Friendly', 'Neighbourino'},

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

SMODS.Joker {
    key = 'char_bleedinggums',
    loc_txt = {
        name = 'Bleeding Gums Murphy',
        text = {
            '{C:red}+#3#{} Mult',
            'Gains between {C:red}+#4#{} and {C:red}+#5#{} Mult',
            'at the end of the round',
            '{C:green}#1# in #2#{} chance to die',
            'at the end of a {C:attention}Boss blind{}'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 6, y = 1 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Friendly', 'Music', 'Man'},

    config = { extra = { odds = 5, mult = 5, mult_min = 1, mult_max = 4 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "gums")
        return { vars = { numerator, denominator, card.ability.extra.mult, card.ability.extra.mult_min, card.ability.extra.mult_max } }
    end,
    
    calculate = function (self, card, context)
        if context.joker_main then
            return { mult = card.ability.extra.mult }
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint and not G.GAME.blind.boss then
            card.ability.extra.mult = card.ability.extra.mult + pseudorandom('bleeding', card.ability.extra.mult_min, card.ability.extra.mult_max)
            return {
                message = "Upgrade!"
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint and G.GAME.blind.boss then
            if SMODS.pseudorandom_probability(card, "gums", 1, card.ability.extra.odds) then
                card:remove()
                return {
                    message = "Goodbye, Lisa"
                }
            else
                card.ability.extra.mult = card.ability.extra.mult + pseudorandom('bleeding', card.ability.extra.mult_min, card.ability.extra.mult_max)
                return {
                    message = "Upgrade!"
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'char_mother',
    loc_txt = {
        name = 'Mona Simpson',
        text = {
            '{C:chips}+#1#{} Chips if hand',
            'contains a {C:attention}Queen{} and a {C:attention}Jack{}'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 7, y = 1 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Mother', 'Friendly', 'Simpson'},

    config = { extra = { chips = 30 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            local jack = false
            local queen = false
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i]:get_id() == 11 then
                    jack = true
                end
                if context.scoring_hand[i]:get_id() == 12 then
                    queen = true
                end
            end
            if jack and queen then
                return {
                    chips = card.ability.extra.chips
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'char_itchy_scratchy',
    loc_txt = {
        name = 'Itchy & Scratchy',
        text = {
            'Gains {C:red}+#1#{} Mult when',
            'a card is {C:attention}destroyed',
            '{C:inactive}(Currently{}{C:red} +#2#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 8, y = 1 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Animals', 'Dangerous', 'Cartoon'},

    config = { extra = { mult = 0, mult_gain = 1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_gain, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            for i = 1, #context.removed do
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
                SMODS.calculate_effect({message = "Upgrade!"}, card)
            end
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

SMODS.Joker {
    key = 'char_jackson',
    loc_txt = {
        name = 'Michael Jackson',
        text = {
            'All drawn cards with {V:1}#1#{} suit',
            'are made {C:attention}Wild{}',
            "All drawn {C:attention}Wild{} cards that aren't",
            "{V:1}#1#{} suit stop being {C:attention}Wild{}",
            '{C:inactive}(Suit changes at the end of the ante)'
        }
    },
    blueprint_compat = false,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 9, y = 1 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Man', 'Odd', 'Crazy'},

    config = { extra = { suit = 'Diamonds' } },

    loc_vars = function(self, info_queue, card)
        local probabilities_normal, odds = SMODS.get_probability_vars(card, 1, card.ability.odds, "DR_ERAM")
		if math.fmod(os.time(), 16) == 0  then
			return {
				key = "j_simpson_kompowsky",
				vars = { probabilities_normal, odds }
			}
		end
        info_queue[#info_queue + 1] = G.P_CENTERS['m_wild']
		return { vars = { card.ability.extra.suit, probabilities_normal, odds, colours = { G.C.SUITS[card.ability.extra.suit] } } }
    end,

    calculate = function (self, card, context)
        if context.hand_drawn and not context.blueprint then
            for i = 1, #G.hand.cards do
                if G.hand.cards[i].config.center.key == 'm_wild' then
                    G.hand.cards[i]:set_ability('c_base', nil, true)
                end
            end
            for i = 1, #G.hand.cards do
                if G.hand.cards[i].config.center.key == 'c_base' and G.hand.cards[i]:is_suit(card.ability.extra.suit) then
                    G.hand.cards[i]:set_ability('m_wild', nil, true)
                end
            end
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint and G.GAME.blind.boss then
            card.ability.extra.suit = pseudorandom_element(SMODS.Suits, 'jackson').key
        end
    end
}

SMODS.Joker { --dummy
	key = "kompowsky",
	loc_txt = {
		name = "Leon Kompowsky",
		text = {
			"I'm not Michael Jackson"
		}
	},
	no_collection = true,
	in_pool = function(self, args)
		return false
	end,
}

SMODS.Joker {
    key = 'char_herb',
    loc_txt = {
        name = 'Uncle Herb',
        text = {
            '{C:red}+#1#{} Mult',
            'Gains {C:red}+#2#{} Mult and',
            'lose a third of Mult as {C:money}$',
            'at the end of the round'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 10, y = 1 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Cars', 'Business', 'Brother'},

    config = { extra = { mult = 4, mult_gain = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.mult_gain } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            return { mult = card.ability.extra.mult }
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + math.floor(card.ability.extra.mult/3)
            return {
                dollars = -math.floor(card.ability.extra.mult/3),
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
    key = 'char_otto',
    loc_txt = {
        name = 'Otto',
        text = {
            'Earn {C:money}$#1#{} when a card',
            'is {C:attention}destroyed',
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 6, y = 2 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Man', 'Freaky', 'School'},

    config = { extra = { dollars = 1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.remove_playing_cards then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + (card.ability.extra.dollars * #context.removed)
            return {
                dollars = (card.ability.extra.dollars * #context.removed),
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
    key = 'char_krabappel',
    loc_txt = {
        name = 'Mrs. Krabappel',
        text = {
            'Gains {C:chips}+#2#{} Chips if',
            'hand contains a {C:attention}Pair',
            '{C:inactive}(Currently{} {C:chips}+#1#{} {C:inactive}Chips){}',
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 7, y = 2 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Woman', 'Tired', 'School'},

    config = { extra = { chips = 0, chip_gain = 5 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chip_gain } }
    end,

    calculate = function (self, card, context)
        if context.before then
            if next(context.poker_hands["Pair"]) and not context.blueprint then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
                SMODS.calculate_effect({message = "Upgrade!"}, card)
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
    key = 'char_hoover',
    loc_txt = {
        name = 'Miss Hoover',
        text = {
            'Gains {C:chips}+#2#{} Chips if hand',
            'contains a {C:attention}Three of a Kind',
            '{C:inactive}(Currently{} {C:chips}+#1#{} {C:inactive}Chips){}',
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 8, y = 2 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Woman', 'Lisa', 'School'},

    config = { extra = { chips = 0, chip_gain = 7 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chip_gain } }
    end,

    calculate = function (self, card, context)
        if context.before then
            if next(context.poker_hands["Three of a Kind"]) and not context.blueprint then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
                SMODS.calculate_effect({message = "Upgrade!"}, card)
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
    key = 'char_agnes',
    loc_txt = {
        name = 'Agnes Skinner',
        text = {
            '{X:red,C:white}X#1#{} Mult if hand',
            'contains a {C:attention}#3#{}',
            '{X:red,C:white}X#2#{} Mult if hand',
            'does not contain a {C:attention}#3#{}',
            '{C:inactive}(Hand type changes after',
            '{C:inactive}a hand is played)'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 9, y = 2 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Mother', 'Old', 'School'},

    config = { extra = { xmult_good = 2, xmult_bad = 0.7, hand = 'Pair' } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_good, card.ability.extra.xmult_bad, card.ability.extra.hand } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            if next(context.poker_hands[card.ability.extra.hand]) then
                card.ability.extra.hand = pseudorandom_element(G.handlist, 'mother!')
                return {
                    xmult = card.ability.extra.xmult_good
                }
            else
                card.ability.extra.hand = pseudorandom_element(G.handlist, 'mother!')
                return {
                    xmult = card.ability.extra.xmult_bad
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'char_cleetus',
    loc_txt = {
        name = 'Cletus the Slack Jawed Yokel',
        text = {
            'Gains {C:chips}+#1#{} Chips when a',
            '{V:1}Simpsons Trading Card{} is sold',
            '{C:inactive}(Currently{} {C:chips}+#2#{} {C:inactive}Chips){}',
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 10, y = 2 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Man', 'Stupid', 'Family'},

    config = { extra = { chip_gain = 4, chips = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chip_gain, card.ability.extra.chips, colours = {HEX(G_C_SIMPSONS_TRADING_CARD)} } }
    end,

    calculate = function(self, card, context)
        if context.selling_card and context.card.ability and context.card.config.center.set == 'SimpsonsTrading' and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
            return {
                message = 'Upgrade!'
            }
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
            }
        end
    end
}

SMODS.Joker {
    key = 'char_chester',
    loc_txt = {
        name = 'Chester Lampwick',
        text = {
            'If played hand contains {C:attention}#1#{} cards,',
            '{C:attention}first{} card is enhanced to a {C:chips}Bonus{} Card',
            'and {C:attention}last{} card is enhanced to a {C:red}Mult{} Card',
            '{C:inactive}"Liver and Onions!"'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 6, y = 3 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Cartoon', 'Important', 'Old'},

    config = { extra = { card_size = 4 } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS['m_bonus']
        info_queue[#info_queue + 1] = G.P_CENTERS['m_mult']
        return { vars = { card.ability.extra.card_size } }
    end,

    calculate = function(self, card, context)
        if context.before and context.main_eval and not context.blueprint then
            if #context.scoring_hand == card.ability.extra.card_size then
                for i = 1, #context.scoring_hand do
                    if i == 1 then
                        context.scoring_hand[i]:set_ability('m_bonus', nil, true)
                    end
                    if i == 4 then
                        context.scoring_hand[i]:set_ability('m_mult', nil, true)
                    end
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'char_patty',
    loc_txt = {
        name = 'Patty',
        text = {
            'Most {C:attention}common{} card rank',
            'in played hand gives {C:red}+#1#{} Mult'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 7, y = 3 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Sister', 'Grumpy', 'Cigarettes'},

    config = { extra = { mult = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card then
            local ranks = {}
            for i = 1, #context.scoring_hand do
                ranks[#ranks + 1] = context.scoring_hand[i]:get_id()
            end
            local counts = {}
            local maxCount = 0
            local mode = nil
            for _, value in ipairs(ranks) do
                counts[value] = (counts[value] or 0) + 1
                if counts[value] > maxCount then
                    maxCount = counts[value]
                    mode = value
                end
            end
            if context.other_card:get_id() == mode then
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'char_selma',
    loc_txt = {
        name = 'Selma',
        text = {
            'Most {C:attention}common{} card rank',
            'in played hand gives {C:chips}+#1#{} Chips'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 8, y = 3 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Sister', 'Grumpy', 'Cigarettes'},

    config = { extra = { chips = 15 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card then
            local ranks = {}
            for i = 1, #context.scoring_hand do
                ranks[#ranks + 1] = context.scoring_hand[i]:get_id()
            end
            local counts = {}
            local maxCount = 0
            local mode = nil
            for _, value in ipairs(ranks) do
                counts[value] = (counts[value] or 0) + 1
                if counts[value] > maxCount then
                    maxCount = counts[value]
                    mode = value
                end
            end
            if context.other_card:get_id() == mode then
                return {
                    chips = card.ability.extra.chips
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'char_helen',
    loc_txt = {
        name = 'Helen Lovejoy',
        text = {
            'All played cards gain',
            '{C:red}+#1#{} Mult when scored',
            '{C:attention}Debuff{} all cards with {C:attention}#2#{}',
            'rank or lower'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 9, y = 3 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Woman', 'Important', 'Church'},

    config = { extra = { mult_gain = 0.5, rank = 7 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_gain, card.ability.extra.rank } }
    end,

    calculate = function (self, card, context)
        if context.cardarea == G.play and context.individual and context.other_card then
            context.other_card.ability.perma_mult = (context.other_card.ability.perma_mult or 0) + card.ability.extra.mult_gain
            return {
                message = 'Upgrade!'
            }
        end
        if context.setting_blind and not context.blueprint then
            for k, v in pairs(G.playing_cards) do
                if v:get_id() <= 7 then
                    SMODS.debuff_card(v, true, "helen_debuff")
                end
            end
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            for k, v in pairs(G.playing_cards) do
                if v:get_id() <= 7 then
                    SMODS.debuff_card(v, false, "helen_debuff")
                end
            end
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        for k, v in pairs(G.playing_cards) do
            if v:get_id() <= 7 then
                SMODS.debuff_card(v, true, "helen_debuff")
            end
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        for k, v in pairs(G.playing_cards) do
            if v:get_id() <= 7 then
                SMODS.debuff_card(v, false, "helen_debuff")
            end
        end
    end
}

SMODS.Joker {
    key = 'char_mccallister',
    loc_txt = {
        name = 'Captain McCallister',
        text = {
            '{X:red,C:white}X#1#{} Mult',
            'loses {X:red,C:white}X#2#{} Mult if',
            'score {C:attention}catches fire'
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 10, y = 3 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Man', 'Hard', 'Sea'},

    config = { extra = { xmult = 3, xmult_loss = 0.25 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_loss } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
        if context.final_scoring_step and not context.blueprint then
            if G.GAME.blind.chips - (hand_chips * mult) <= 0 then
                card.ability.extra.xmult = card.ability.extra.xmult - card.ability.extra.xmult_loss
                if card.ability.extra.xmult <= 0 then
                    card:remove()
                end
                return {
                    message = 'Arrggh!'
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'char_scorpio',
    loc_txt = {
        name = 'Hank Scorpio',
        text = {
            '{C:money}$#1#{} for every {C:attention}Joker{} on',
            'the {C:attention}final{} hand of round'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 6, y = 4 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Man', 'Important', 'Crazy'},

    config = { extra = { dollars = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function (self, card, context)
        if context.other_joker and G.GAME.current_round.hands_left == 0 then
            return {
                dollars = card.ability.extra.dollars
            }
        end
    end
}

SMODS.Joker {
    key = 'char_meyers',
    loc_txt = {
        name = 'Roger Meyers Jr.',
        text = {
            'Earn {C:money}$#3#{} at the',
            'end of the round',
            '{C:green}#1# in #2#{} chance to',
            'gain {C:money}$#4#{} when a card',
            'is {C:attention}destroyed{}'
        }
    },
    blueprint_compat = false,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 7, y = 4 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Cartoon', 'Important', 'Business'},

    config = { extra = { odds = 3, dollars = 4, dollar_gain = 1 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "meyers")
        return { vars = { numerator, denominator, card.ability.extra.dollars, card.ability.extra.dollar_gain } }
    end,

    calculate = function (self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            for i = 1, #context.removed do
                if SMODS.pseudorandom_probability(card, "meyers", 1, card.ability.extra.odds) then
                    card.ability.extra.dollars = card.ability.extra.dollars + card.ability.extra.dollar_gain
                    SMODS.calculate_effect({ message = "Upgrade!", colour = G.C.MONEY }, card)
                end
            end
        end
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end
}

SMODS.Sound({key = "planet", path = "planet-needs.mp3",})

SMODS.Joker {
    key = 'char_poochie',
    loc_txt = {
        name = 'Poochie',
        text = {
            '{C:red}+#3#{} Mult',
            '{C:green}#1# in #2#{} chance to',
            'go back to his {C:attention}home planet',
            'when starting the {C:attention}shop'

        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 8, y = 4 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Cartoon', 'Cool', 'Animal'},

    config = { extra = { odds = 4, mult = 21 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "poochie")
        return { vars = { numerator, denominator, card.ability.extra.mult } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
        if context.starting_shop and not context.blueprint then
            if SMODS.pseudorandom_probability(card, "poochie", 1, card.ability.extra.odds) and not context.blueprint then
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 15,
                    func = function()
                        play_sound("simpson_planet", 1, 0.6)
                        return true
                    end
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0,
                    func = function()
                        card:remove()
                        return true
                    end
                }))
            end
        end
    end
}

SMODS.Joker {
    key = 'char_duffman',
    loc_txt = {
        name = 'Duff Man',
        text = {
            'Gains {C:red}+#1#{} Mult when',
            'a {C:red}Duff Card{} is used',
            '{C:inactive}(Currently{}{C:red} +#2#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = false,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 9, y = 4 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Cool', 'Mascot', 'Man'},

    config = { extra = { mult = 0, mult_gain = 3 } },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS['c_simpson_duff']
        return { vars = { card.ability.extra.mult_gain, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and context.consumeable.config.center.set == 'SimpsonsTrading' and context.consumeable.config.center.key == 'c_simpson_duff' and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
            return {
                message = 'Upgrade!',
                colour = G.C.RED
            }
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
            }
        end
    end,
}

SMODS.Joker {
    key = 'char_discostu',
    loc_txt = {
        name = 'Disco Stu',
        text = {
            '{C:chips}+#1#{} Chips for every card',
            'in your {C:attention}deck{} with an {C:purple}Edition',
            '{C:inactive}(Currently{} {C:chips}+#2#{} {C:inactive}Chips){}',

        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 10, y = 4 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Cool', 'Music', 'Man'},

    config = { extra = { chips = 10 } },

    loc_vars = function(self, info_queue, card)
        local edition_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card.edition then 
                    edition_tally = edition_tally + 1 
                end
            end
        end
        return { vars = { card.ability.extra.chips, edition_tally * card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local edition_tally = 0
            if G.playing_cards then
                for _, playing_card in ipairs(G.playing_cards) do
                    if playing_card.edition then 
                        edition_tally = edition_tally + 1 
                    end
                end
            end
            return {
                chips = edition_tally * card.ability.extra.chips
            }
        end
    end,
    in_pool = function(self, args)
        for _, playing_card in ipairs(G.playing_cards) do
            if playing_card.edition then 
                return true
            end
        end
        return false
    end
}

SMODS.Joker {
    key = 'char_snake',
    loc_txt = {
        name = 'Snake',
        text = {
            '{C:blue}Planet{} Cards level up by {C:attention}#1#',
            'Lose {C:money}$#2#{} when a {C:blue}Planet{} Card is used'
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 6, y = 5 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Dangerous', 'Criminal', 'Man'},

    config = { extra = { levels = 2, dollars = 10 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.levels, card.ability.extra.dollars } }
    end,

    calculate = function (self, card, context)
        if context.using_consumeable and context.consumeable.ability.set == ("Planet") then
			local key = context.consumeable.config.center.key
			local hand_type = nil
			for i = 1, #G.P_CENTER_POOLS.Planet do
				if key == G.P_CENTER_POOLS.Planet[i].key then
					if not G.GAME.hands[G.P_CENTER_POOLS.Planet[i].config.hand_type] then return end --protecting against any modded planet cards with no hand_type
					hand_type = G.GAME.hands[G.P_CENTER_POOLS.Planet[i].config.hand_type]
				end
			end
            SMODS.upgrade_poker_hands({hands = {hand_type.key}, level_up = card.ability.extra.levels - 1, from = card})
            return {
                dollars = -card.ability.extra.dollars
            }
        end
    end
}

SMODS.Joker {
    key = 'char_jimbojones',
    loc_txt = {
        name = 'Jimbo Jones',
        text = {
            'Removes {C:attention}enhancements',
            'from all {C:attention}played{} cards',
            'Earn {C:money}$#1#{} for every',
            '{C:attention}enhancement{} removed',
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = false,
    atlas = 'SimpsJokers',
    pos = { x = 7, y = 5 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'School', 'Gang', 'Bully'},

    config = { extra = { dollars = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
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
                return {
                    dollars = card.ability.extra.dollars * amount,
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'char_kearney',
    loc_txt = {
        name = 'Kearney Matthew Zzyzwicz, Sr.',
        text = {
            '{X:red,C:white}X#1#{} Mult if any playing',
            'cards were {C:attention}destroyed{} this {C:attention}Ante'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 8, y = 5 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'School', 'Gang', 'Bully'},

    config = { extra = { xmult = 2, destroyed = false } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function (self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            card.ability.extra.destroyed = true
        end
        if context.end_of_round and context.game_over == false and context.main_eval and G.GAME.blind.boss and not context.blueprint then
            card.ability.extra.destroyed = false
        end
        if context.joker_main then
            if card.ability.extra.destroyed then
                return {
                    xmult = card.ability.extra.xmult
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'char_dolph',
    loc_txt = {
        name = 'Dolph Starbeam',
        text = {
            'Destroy all played {C:attention}Wild{} Cards',
            'Earn {C:money}$#1#{} every {C:attention}#2#{} Wild',
            'Cards destoryed'
        }
    },
    blueprint_compat = false,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 9, y = 5 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'School', 'Gang', 'Bully'},

    config = { extra = { dollars = 3, cards = 2, counter = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.cards } }
    end,

    calculate = function (self, card, context)
        if context.destroy_card and context.cardarea == G.play and not context.blueprint then
            if context.destroy_card.config.center.key == 'm_wild' then
                return {
                    remove = true
                }
            end
        end
        if context.remove_playing_cards and not context.blueprint then
            local second_counter = 0
            for i = 1, #context.removed do
                card.ability.extra.counter = card.ability.extra.counter + 1
                if card.ability.extra.counter == 2 then
                    card.ability.extra.counter = 0
                    second_counter = second_counter + 1
                end
            end
            if second_counter > 0 then
                return {
                    dollars = card.ability.extra.dollars * second_counter
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'char_herman',
    loc_txt = {
        name = 'Herman',
        text = {
            'Gains {C:chips}+#1#{} Chips when',
            'an {C:attention}Enhanced{} Card is scored',
            '{C:inactive}(Currently{} {C:chips}+#2#{} {C:inactive}Chips){}',
            '{C:inactive}Includes Seals and Editions'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 10, y = 5 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Dangerous', 'Business', 'Man'},

    config = { extra = { chips_gain = 2, chips = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips_gain, card.ability.extra.chips } }
    end,

    calculate = function (self, card, context)
        if context.other_card and (context.other_card.config.center.key ~= 'c_base' or context.other_card:get_seal() or context.other_card.edition) and context.cardarea == G.play and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_gain
            return {
                message = 'Upgrade!',
                colour = G.C.CHIPS
            }
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}

SMODS.Joker {
    key = 'char_lou',
    loc_txt = {
        name = 'Officer Lou',
        text = {
            'Gain {C:red}+#1#{} Mult for every {C:attention}consecutive{}',
            'hand without playing a {C:attention}#3#{} or {C:attention}#4#{}',
            '{C:inactive}(Currently{} {C:red}+#2#{} {C:inactive}Mult){}',
            '{C:inactive}(Hand Types change at the end of the round)',
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 6, y = 6 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Police', 'Man', 'Strong'},

    config = { extra = { mult_gain = 1, mult = 0, hand_type = 'Three of a Kind', hand_type_2 = 'Flush' } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_gain, card.ability.extra.mult, card.ability.extra.hand_type, card.ability.extra.hand_type_2 } }
    end,

    calculate = function (self, card, context)
        if context.before and not context.blueprint then
            if context.scoring_name == card.ability.extra.hand_type then
                card.ability.extra.mult = 0
                return {
                    message = 'Reset!',
                    colour = G.C.RED
                }
            else
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
                return {
                    message = 'Upgrade!',
                    colour = G.C.RED
                }
            end
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            card.ability.extra.hand_type = pseudorandom_element(G.handlist, 'lou')
            card.ability.extra.hand_type_2 = pseudorandom_element(G.handlist, 'lou')
        end
    end
}

SMODS.Joker {
    key = 'char_eddie',
    loc_txt = {
        name = 'Officer Eddie',
        text = {
            'Gain {X:red,C:white}X#1#{} Mult per hand played',
            'Lose {X:red,C:white}X#1#{} Mult per discard',
            '{C:inactive}(Currently{} {X:red,C:white}X#2#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 7, y = 6 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Police', 'Man', 'Dumb'},

    config = { extra = { difference = 0.1, xmult = 1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.difference, card.ability.extra.xmult } }
    end,

    calculate = function (self, card, context)
        if context.discard and not context.blueprint and context.other_card == context.full_hand[#context.full_hand] then
            card.ability.extra.xmult = math.max(1, card.ability.extra.xmult - card.ability.extra.difference)
            if card.ability.extra.xmult ~= 1 then
                return {
                    message = '-X' .. card.ability.extra.difference,
                    colour = G.C.RED
                }
            end
        end
        if context.before and context.main_eval and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.difference
            return {
                message = 'X' .. card.ability.extra.difference,
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
    key = 'char_snyder',
    loc_txt = {
        name = 'Judge Snyder',
        text = {
            'Not allowed to play any hands',
            'that contain a {C:attention}#2#{}',
            'Earn {C:money}$#1#{} at the',
            'end of the round'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 8, y = 6 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Important', 'Law', 'Rich'},

    config = { extra = { dollars = 6, hand = 'Pair' } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.hand } }
    end,

    calculate = function (self, card, context)
        if context.debuff_hand and not context.blueprint then
            local ranks = {}
            for i = 1, #context.scoring_hand do
                ranks[#ranks + 1] = context.scoring_hand[i]:get_id()
            end
            local counts = {}
            local maxCount = 0
            local mode = nil
            for _, value in ipairs(ranks) do
                counts[value] = (counts[value] or 0) + 1
                if counts[value] > maxCount then
                    maxCount = counts[value]
                    mode = value
                end
            end
            if counts[mode] >= 2 then
                return {
                    debuff = true
                }
            else
                return {
                    debuff = false
                }
            end
        end
    end,
    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end
}

SMODS.Joker {
    key = 'char_louie',
    loc_txt = {
        name = 'Louie',
        text = {
            'Earn {C:money}$#1#{} at the',
            'end of the round',
            'Destroy the {C:attention}Joker{} to the',
            'right and add a {C:attention}third{} of',
            'its {C:money}sell value{} to the cashout'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 9, y = 6 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Dangerous', 'Gang', 'Criminal'},

    config = { extra = { dollars = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,
    calculate = function (self, card, context)
        if context.setting_blind and not context.blueprint then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    my_pos = i
                    break
                end
            end
            if my_pos and G.jokers.cards[my_pos + 1] and not SMODS.is_eternal(G.jokers.cards[my_pos + 1], card) and not G.jokers.cards[my_pos + 1].getting_sliced then
                local sliced_card = G.jokers.cards[my_pos + 1]
                sliced_card.getting_sliced = true
                G.GAME.joker_buffer = G.GAME.joker_buffer - 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.GAME.joker_buffer = 0
                        if math.floor(sliced_card.sell_cost / 3) < 1 then
                            card.ability.extra.dollars = card.ability.extra.dollars + 1
                        else
                            card.ability.extra.dollars = card.ability.extra.dollars + math.floor(sliced_card.sell_cost / 3)
                        end
                        card:juice_up(0.8, 0.8)
                        sliced_card:start_dissolve({ HEX("57ecab") }, nil, 1.6)
                        play_sound('slice1', 0.96 + math.random() * 0.08)
                        return true
                    end
                }))
                return {
                    message = "$"..card.ability.extra.dollars,
                    colour = G.C.MONEY,
                    no_juice = true
                }
            end
        end
    end,
    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end
}

SMODS.Joker {
    key = 'char_marvin',
    loc_txt = {
        name = 'Dr. Marvin Monroe',
        text = {
            'Copies ability of the',
            'Joker {C:attention}2{} spaces',
            'to the right'
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 10,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 10, y = 6 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Doctor', 'Man', 'Dead'},

    config = { extra = {  } },

    loc_vars = function(self, info_queue, card)
        if card.area and card.area == G.jokers then
            local other_joker
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i + 2] end
            end
            local compatible = other_joker and other_joker ~= card and other_joker.config.center.blueprint_compat
            main_end = {
                {
                    n = G.UIT.C,
                    config = { align = "bm", minh = 0.4 },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = { ref_table = card, align = "m", colour = compatible and mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8) or mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8), r = 0.05, padding = 0.06 },
                            nodes = {
                                { n = G.UIT.T, config = { text = ' ' .. localize('k_' .. (compatible and 'compatible' or 'incompatible')) .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 } },
                            }
                        }
                    }
                }
            }
            return { main_end = main_end }
        end
    end,

    calculate = function (self, card, context)
        local other_joker = nil
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i + 2] end
        end
        return SMODS.blueprint_effect(card, other_joker, context)
    end
}

SMODS.Joker {
    key = 'char_bumblebee',
    loc_txt = {
        name = 'Bumblebee Man',
        text = {
            '{C:red}+#1#{} Mult {C:chips}+#2#{} Chips',
            'if hand contains',
            'a {V:2}Diamond{} and {V:1}Spade{}'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 6, y = 7 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Funny', 'Actor', '"Animal"'},

    config = { extra = { mult = 3, chips = 20, suit1 = 'Spades', suit2 = 'Diamonds' } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.chips, colours = { G.C.SUITS[card.ability.extra.suit1], G.C.SUITS[card.ability.extra.suit2] } } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            local spade = false
            local diamond = false
            for i = 1, #context.scoring_hand do
                if spade == false or diamond == false then
                    if context.scoring_hand[i]:is_suit(card.ability.extra.suit1) then
                        spade = true
                    end
                    if context.scoring_hand[i]:is_suit(card.ability.extra.suit2) then
                        diamond = true
                    end
                end
            end
            if diamond and spade then
                return {
                    mult = card.ability.extra.mult,
                    chips = card.ability.extra.chips
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'char_gil',
    loc_txt = {
        name = 'Gil Gunderson',
        text = {
            'Earn {C:money}$1{} at the end of the',
            'round for every {C:attention}#2#{} {V:1}Simpsons',
            '{V:1}Trading Cards{} used this run',
            '{C:inactive}(Currently{} {C:money}$#1#{}{C:inactive}){}',
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 7, y = 7 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Business', 'Desperate', 'Man'},

    config = { extra = { division = 3 } },

    loc_vars = function(self, info_queue, card)
        local dollars = math.floor((G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.simpsonstrading or 0)/card.ability.extra.division) + 1
        return { vars = { dollars, card.ability.extra.division, colours = {HEX(G_C_SIMPSONS_TRADING_CARD)} } }
    end,

    calc_dollar_bonus = function(self, card)
        local dollars = math.floor((G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.simpsonstrading or 0)/card.ability.extra.division) + 1
        return dollars
    end
}

SMODS.Joker {
    key = 'char_squeaky',
    loc_txt = {
        name = 'Squeaky Voiced Teen',
        text = {
            'Earn {C:money}$#3#{} at the',
            'end of the round',
            '{C:green}#1# in #2#{} chance',
            'earn {C:money}$#4#{} at the',
            'end of the round'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 8, y = 7 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Young', 'Business', 'Boy'},

    config = { extra = { odds = 3, dollars = 1, dollars_bonus = 10 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "sir")
        return { vars = { numerator, denominator, card.ability.extra.dollars, card.ability.extra.dollars_bonus } }
    end,
    
    calc_dollar_bonus = function(self, card)
        if SMODS.pseudorandom_probability(card, "sir", 1, card.ability.extra.odds) then
            return card.ability.extra.dollars_bonus
        else
            return card.ability.extra.dollars
        end
    end
}

SMODS.Joker {
    key = 'char_jacqueline',
    loc_txt = {
        name = 'Jacqueline Bouvier',
        text = {
            '{C:green}#1# in #2#{} chance for each played',
            '{C:attention}face{} card to give {X:red,C:white}X#3#{} Mult'
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 9, y = 7 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Mother', 'Old', 'Hair'},

    config = { extra = { odds = 2, xmult = 1.6 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "jacqueline")
        return { vars = { numerator, denominator, card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.other_card and context.individual and context.cardarea == G.play and context.other_card:is_face() then
            if SMODS.pseudorandom_probability(card, "jacqueline", 1, card.ability.extra.odds) then
                return { xmult = card.ability.extra.xmult }
            end
        end
    end
}


SMODS.Joker {
    key = 'char_jasper',
    loc_txt = {
        name = 'Jasper Beardley',
        text = {
            '{X:red,C:white}X#1#{} Mult',
            'Lose {C:money}-$#2#{} when any',
            '{C:attention}consumeable{} is used'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 10, y = 7 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Old', 'Man', 'Paddle'},

    config = { extra = { xmult = 2, dollars = 5 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.dollars } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
        if context.using_consumeable then
            print(G.GAME.consumeable_usage_total)
            return {
                dollars = -card.ability.extra.dollars
            }
        end
    end
}

SMODS.Joker {
    key = 'char_luigi',
    loc_txt = {
        name = 'Luigi Risotto',
        text = {
            'Gains {C:chips}+#1#{} Chip',
            'for every {C:money}$1{} spent',
            'in the shop',
            '{C:inactive}(Currently{} {C:chips}+#2#{} {C:inactive}Chips){}',
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 1,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 6, y = 8 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Business', 'Stereotype', 'Food'},

    config = { extra = { chips = SIMPSON_DOLLARS_SPENT, chip_gain = 1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chip_gain, SIMPSON_DOLLARS_SPENT } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            return {
                chips = SIMPSON_DOLLARS_SPENT
            }
        end
    end
}

SMODS.Joker {
    key = 'char_maude',
    loc_txt = {
        name = 'Maude Flanders',
        text = {
            'Gains {C:red}+#1#{} Mult when an',
            '{C:attention}enhanced{} card is {C:attention}destroyed',
            '{C:inactive}(Currently{} {C:red}+#2#{} {C:inactive}Mult){}',
            '{C:inactive}Includes Seals and Editions'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 7, y = 8 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Mother', 'Dead', 'Neighbourino'},

    config = { extra = { mult = 0, mult_gain = 4 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_gain, card.ability.extra.mult } }
    end,

    calculate = function (self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            for i = 1, #context.removed do
                if context.removed[i]:get_seal() or context.removed[i].edition or context.removed[i].config.center.key ~= 'c_base' then
                    card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
                    SMODS.calculate_effect({message = "Upgrade!", colour = G.C.RED}, card)
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

SMODS.Joker {
    key = 'char_god',
    loc_txt = {
        name = 'God',
        text = {
            'Gains {X:red,C:white}X#1#{} Mult for every',
            'card {C:attention}destroyed{} during the run',
            '{C:inactive}(Currently{} {X:red,C:white}X#2#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 9,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 8, y = 8 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'He Must Have Deserved It', 'Creator of All Things', 'Has Big Feet'},

    config = { extra = { xmult_gain = 0.2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_gain, (SIMPSON_CARDS_DESTROYED_RUN * card.ability.extra.xmult_gain) + 1 } }
    end,

    calculate = function (self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            SMODS.calculate_effect({message = "Upgrade!", colour = G.C.RED}, card)
        end
        if context.joker_main then
            return {
                xmult = (SIMPSON_CARDS_DESTROYED_RUN * card.ability.extra.xmult_gain) + 1
            }
        end
    end
}

SMODS.Joker {
    key = 'char_lurleen',
    loc_txt = {
        name = 'Lurleen',
        text = {
            '{X:red,C:white}X#1#{} Mult',
            'loses {X:red,C:white}X#2#{} Mult',
            'when hand played',
            'Resets at the end',
            'of the round'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 9, y = 8 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Music', 'Woman', 'Desperate'},

    config = { extra = { xmult = 2.5, xmult_loss = 0.5 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_loss } }
    end,

    calculate = function (self, card, context)
        if context.after and context.main_eval and not context.blueprint then
            if card.ability.extra.xmult > 1 then
                card.ability.extra.xmult = card.ability.extra.xmult - card.ability.extra.xmult_loss
                SMODS.calculate_effect({message = "X"..card.ability.extra.xmult, colour = G.C.RED}, card)
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            card.ability.extra.xmult = 2.5
            SMODS.calculate_effect({message = "Reset", colour = G.C.RED}, card)
        end
    end
}

SMODS.Joker {
    key = 'char_mindy',
    loc_txt = {
        name = 'Mindy Simmons',
        text = {
            '{X:red,C:white}X#1#{} Mult if played',
            'hand contains a {C:attention}King{} and {C:attention}Queen{}',
            'of different suits'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 10, y = 8 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Subversive', 'Power Plant', 'Woman'},

    config = { extra = { xmult = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            local king = false
			local queen = false
			local kingsuits = {}
			local queensuits = {}
			for i = 1, #context.scoring_hand do
				if context.scoring_hand[i]:get_id() == 13 or context.scoring_hand[i]:get_id() == 12 then
					if context.scoring_hand[i]:get_id() == 13 then
						if not king then
							king = true
						end
						for k, v in pairs(SMODS.Suits) do
							if context.scoring_hand[i]:is_suit(k, nil, true) then
								local contained = false
								for i = 1, #kingsuits do
									if k == kingsuits[i] then
										contained = true
									end
								end
								if not contained then
									kingsuits[#kingsuits + 1] = k
								end
							end
						end
					else
						if not queen then
							queen = true
						end
						for k, v in pairs(SMODS.Suits) do
							if context.scoring_hand[i]:is_suit(k, nil, true) then
								local contained = false
								for i = 1, #queensuits do
									if k == queensuits[i] then
										contained = true
									end
								end
								if not contained then
									queensuits[#queensuits + 1] = k
								end
							end
						end
					end
				end
				if king and queen then
					if
						(#kingsuits > 1 or #queensuits > 1)
						or (#kingsuits == 1 and #queensuits == 1 and kingsuits[1] ~= queensuits[1])
					then
						return {
                            xmult = card.ability.extra.xmult
                        }
					end
				end
			end
        end
    end
}

SMODS.Joker {
    key = 'char_blinky',
    loc_txt = {
        name = 'Blinky the Fish',
        text = {
            'Create a random {C:purple}Tarot',
            'card if hand contains a',
            '{C:attention}#1#'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 6, y = 9 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Animal', 'Sea', 'Power Plant'},

    config = { extra = { type = 'Three of a Kind' } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.type } }
    end,

    calculate = function (self, card, context)
        if context.joker_main and next(context.poker_hands[card.ability.extra.type]) then
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
                    SMODS.calculate_effect({message = "Blub!", colour = G.C.PURPLE}, card)
                    return true
                end)
            }))
            return nil, true
        end
    end
}

SMODS.Joker {
    key = 'char_squirrel',
    loc_txt = {
        name = 'Mutated Squirrel',
        text = {
            '{C:red}+#1#{} Mult for',
            'every card with a',
            '{V:1}Pollution{} Seal',
            '{C:inactive}(Currently{} {C:red}+#2#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 7, y = 9 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Animal', 'Power Plant', 'Movie'},

    config = { extra = { mult = 2 } },

    loc_vars = function(self, info_queue, card)
        local pollution_tally = 0
        local mult = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card.seal and playing_card.seal == 'simpson_pollution' then pollution_tally = pollution_tally + 1 end
            end
        end
        mult = pollution_tally * card.ability.extra.mult
        return { vars = { card.ability.extra.mult, mult, colours = {HEX("bfae00")} } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            local pollution_tally = 0
            local mult = 0
            if G.playing_cards then
                for _, playing_card in ipairs(G.playing_cards) do
                    if playing_card.seal and playing_card.seal == 'simpson_pollution' then pollution_tally = pollution_tally + 1 end
                end
            end
            mult = pollution_tally * card.ability.extra.mult
            return { 
                mult = mult 
            }
        end
    end,
    in_pool = function(self, args)
        for _, playing_card in ipairs(G.playing_cards) do
            if playing_card.seal and playing_card.seal == 'simpson_pollution' then 
                return true
            end
        end
        return false
    end
}

SMODS.Joker {
    key = 'char_krustofsky',
    loc_txt = {
        name = 'Rabbi Hyman Krustofsky',
        text = {
            '{X:red,C:white}X#1#{} Mult for',
            'every {C:attention}empty space{}',
            'in played hand',
            '{C:inactive}(Ex: #3# played cards > {X:red,C:white}X#2#{})'
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 8, y = 9 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Father', 'Religious', 'Old'},

    config = { extra = { xmult = 0.3, amount = 3 } },

    loc_vars = function(self, info_queue, card)
        local example = (card.ability.extra.xmult * (5 - card.ability.extra.amount)) + 1
        return { vars = { card.ability.extra.xmult, example, card.ability.extra.amount } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            return {
                xmult = (card.ability.extra.xmult * (G.GAME.starting_params.play_limit - #context.full_hand)) + 1
            }
        end
    end
}

SMODS.Joker {
    key = 'char_jewish_man',
    loc_txt = {
        name = 'Old Jewish Man',
        text = {
            '{C:green}#1# in #2#{} chance of',
            'creating {C:attention}#3#{} copies of a',
            'card when it is {C:attention}destroyed'
        }
    },
    blueprint_compat = false,
    rarity = 3,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 9, y = 9 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Religious?', 'Old', 'Man'},

    config = { extra = { odds = 3, amount = 2 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "jew!")
        return { vars = { numerator, denominator, card.ability.extra.amount } }
    end,

    calculate = function (self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            for i = 1, #context.removed do
                if SMODS.pseudorandom_probability(card, 'jew!', 1, card.ability.extra.odds) then
                    for i = 1, card.ability.extra.amount do
                        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                        local copy_card = copy_card(context.removed[i], nil, nil, G.playing_card)
                        copy_card:add_to_deck()
                        G.deck.config.card_limit = G.deck.config.card_limit + 1
                        table.insert(G.playing_cards, copy_card)
                        G.hand:emplace(copy_card)
                        copy_card.states.visible = nil

                        G.E_MANAGER:add_event(Event({
                            func = function()
                                copy_card:start_materialize()
                                return true
                            end
                        }))
                        return {
                            message = localize('k_copied_ex'),
                            colour = G.C.CHIPS,
                            func = function() -- This is for timing purposes, it runs after the message
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        SMODS.calculate_context({ playing_card_added = true, cards = { copy_card } })
                                        return true
                                    end
                                }))
                            end
                        }
                    end
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'char_jebidiah',
    loc_txt = {
        name = 'Jebidiah Springfield',
        text = {
            '{C:green}#1# in #2#{} chance to',
            'level up hand {C:attention}above{} and {C:attention}below{}',
            'the hand played'
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 8,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 10, y = 9 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Father', 'Important', 'Dead'},

    config = { extra = { odds = 4 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'jebby')
        return { vars = { numerator, denominator } }
    end,

    calculate = function(self, card, context)
        if context.before and context.main_eval and SMODS.pseudorandom_probability(card, 'jebby', 1, card.ability.extra.odds) then
            local order = nil
            for hand_key, hand in pairs(G.GAME.hands) do
                if hand_key == context.scoring_name then
                    order = hand.order
                end
            end
            print(order)
            for hand_key, hand in pairs(G.GAME.hands) do
                if (hand.order == order + 1) or (hand.order == order - 1) then
                    SMODS.upgrade_poker_hands({hands = {hand_key}, level_up = 1, from = card})
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'char_artie',
    loc_txt = {
        name = 'Artie Ziff',
        text = {
            '{C:attention}Queens{} give {C:red}+#1#{} Mult',
            'when scored'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 11, y = 1 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Man', 'Rival', 'Love Interest'},

    config = { extra = { mult = 4 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:get_id() == 12 then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

SMODS.Joker {
    key = 'char_baby_gerald',
    loc_txt = {
        name = 'Baby Gerald',
        text = {
            '{C:attention}Mult{} Cards give {C:chips}+#1#',
            'Chips when scored'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 12, y = 1 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Baby', 'Dangerous', 'Rival'},

    config = { extra = { chips = 40 } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS['m_mult']
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card.config.center.key == 'm_mult' then
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}

SMODS.Joker {
    key = 'char_laddie',
    loc_txt = {
        name = 'Laddie',
        text = {
            'Get a random {C:purple}Tarot{}, {C:planet}Planet{},',
            '{C:spectral}Spectral{}, or {V:1}Simpsons Trading{}',
            'Card when selecting a {C:attention}Blind'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 13, y = 1 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Dog', 'Rival', 'Pretty'},

    config = { extra = {  } },

    loc_vars = function(self, info_queue, card)
        return { vars = { colours = { HEX(G_C_SIMPSONS_TRADING_CARD) } } }
    end,

    calculate = function (self, card, context)
        if context.setting_blind and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            local types = {'Tarot', 'Planet', 'Spectral', 'SimpsonsTrading'}
            local names = {'Tarot  Card', 'Planet  Card', 'Spectral  Card', 'Simpsons Trading Card'}
            local colours = {G.C.PURPLE, G.C.PLANET, G.C.SPECTRAL, HEX(G_C_SIMPSONS_TRADING_CARD)}
            local i = pseudorandom('laddiebestdogever', 1, #types)
            print(types[i])
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = (function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            SMODS.add_card { set = types[i], }
                            G.GAME.consumeable_buffer = 0
                            return true
                        end
                    }))
                    SMODS.calculate_effect({ message = '+1 '..names[i], colour = colours[i] }, context.blueprint_card or card)
                    return true
                end)
            }))
            return nil, true 
        end
    end
}

SMODS.Joker {
    key = 'char_lyle',
    loc_txt = {
        name = 'Lyle Lanley',
        text = {
            '{C:green}#1# in #2#{} chance to destroy each',
            'purchased {C:purple}Tarot{} or {C:planet}Planet{} Card',
            'and gain {X:red,C:white}X#3#{} Mult',
            '{C:inactive}(Currently{} {X:red,C:white}X#4#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 14, y = 1 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Con-man', 'Business', 'Rival'},

    config = { extra = { odds = 2, xmult_gain = 0.4, xmult = 1 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'lyle')
        return { vars = { numerator, denominator, card.ability.extra.xmult_gain, card.ability.extra.xmult } }
    end,

    calculate = function (self, card, context)
        if context.buying_card and not context.blueprint and context.card.ability and context.card.ability.set ~= 'Voucher' and context.card.ability.set ~= 'Booster' then
            if SMODS.pseudorandom_probability(card, "lyle", 1, card.ability.extra.odds) and (context.card.ability.set == 'Tarot' or context.card.ability.set == 'Planet') then
                SMODS.destroy_cards(context.card)
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
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
    key = 'char_cargill',
    loc_txt = {
        name = 'Russ Cargill',
        text = {
            '{C:green}#1# in #2#{} chance for',
            'each played {C:attention}unsealed{} card to',
            'be given a {V:1}Pollution{} Seal after play',
            'Retrigger all cards with a {V:1}Pollution{} Seal'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 15, y = 1 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Important', 'Government', 'Dangerous'},

    config = { extra = { odds = 3 } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_SEALS['simpson_pollution']
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'cargill')
        return { vars = { numerator, denominator, colours = {HEX("bfae00")} } }
    end,

    calculate = function (self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card.seal and context.other_card.seal == 'simpson_pollution' then
            return {
                repetitions = 1
            }
        end
        if context.final_scoring_step and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                func = (function()
                    for i = 1, #context.full_hand do
                        if SMODS.pseudorandom_probability(card, "cargill", 1, card.ability.extra.odds) and not context.full_hand[i].seal then
                            context.full_hand[i]:set_seal('simpson_pollution')
                        end
                    end
                    return true
                end)
            }))
        end
    end
}

SMODS.Joker {
    key = 'char_crazy_cat',
    loc_txt = {
        name = 'Crazy Cat Lady',
        text = {
            '{X:red,C:white}X#1#{} for every {C:attention}enhanced',
            'card in your deck',
            '{C:inactive}(Currently{} {X:red,C:white}X#2#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 11, y = 2 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Crazy', 'Woman', 'Cats'},

    config = { extra = { xmult_gain = 0.05 } },

    loc_vars = function(self, info_queue, card)
        local enhanced_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card.config.center.key ~= 'c_base' then 
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
                    if playing_card.config.center.key ~= 'c_base' then 
                        enhanced_tally = enhanced_tally + 1 
                    end
                end
            end
            return {
                xmult = (enhanced_tally * card.ability.extra.xmult_gain) + 1
            }
        end
    end,

    in_pool = function(self, args)
        for _, playing_card in ipairs(G.playing_cards) do
            if playing_card.config.center.key ~= 'c_base' then 
                return true
            end
        end
        return false
    end
}

SMODS.Joker {
    key = 'char_sherri',
    loc_txt = {
        name = 'Sherri and Terri',
        text = {
            'Earn {C:money}$#1#{} if',
            'played hand contains',
            'a {C:attention}Pair{}'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 12, y = 2 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Twins', 'School', 'Girl'},

    config = { extra = { dollars = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function (self, card, context)
        if context.before and next(context.poker_hands['Pair']) then
            return {
                dollars = card.ability.extra.dollars
            }
        end
    end
}

SMODS.Joker {
    key = 'char_doris',
    loc_txt = {
        name = 'Lunchlady Doris',
        text = {
            'All cards in hand get',
            'a random {C:attention}Seal{} on the {C:attention}final',
            'hand of round'
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 13, y = 2 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'School', 'Food', 'Blue-Collar'},

    config = { extra = {  } },

    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,

    calculate = function (self, card, context)
        if context.before and not context.blueprint and G.GAME.current_round.hands_left == 0 then
            for i = 1, #context.scoring_hand do
                if not context.scoring_hand[i]:get_seal() then
                    context.scoring_hand[i]:set_seal(SMODS.poll_seal({key = 'supercharge', guaranteed = true}), nil, true)
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'char_drederick',
    loc_txt = {
        name = 'Drederick Tatum',
        text = {
            '{X:red,C:white}X#1#{} Mult',
            'If round takes over {C:attention}#2# minute{} to',
            'beat, then lose all {C:money}cashout money{}',
            '{C:attention}#3#{} {C:inactive}Seconds Remaining'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 14, y = 2 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Famous', 'Entertainer', 'Sportsman'},

    config = { extra = { xmult = 2, time = 1, seconds = 0, counter = 0, money = 0, failed = false } },

    loc_vars = function(self, info_queue, card)
        local remaining = (card.ability.extra.time * 60) - card.ability.extra.seconds
        if remaining < 0 then remaining = 0 end
        return { vars = { card.ability.extra.xmult, card.ability.extra.time, remaining } }
    end,

    calculate = function (self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.failed = false
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            card.ability.extra.money = G.GAME.dollars
            if card.ability.extra.seconds >= (card.ability.extra.time * 60) then
                card.ability.extra.failed = true
            end
            card.ability.extra.seconds = 0
        end
        if context.starting_shop and not context.blueprint and card.ability.extra.failed then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + -(G.GAME.dollars - card.ability.extra.money)
            return {
                dollars = -(G.GAME.dollars - card.ability.extra.money),
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
    end,

    update = function(self, card, dt)
        if next(SMODS.find_card('j_simpson_char_drederick')) and G.STATE == 1 then
            card.ability.extra.counter = card.ability.extra.counter + (dt/G.SETTINGS.GAMESPEED)
            if card.ability.extra.counter >= 1 then
                card.ability.extra.seconds = card.ability.extra.seconds + 1
                card.ability.extra.counter = 0
            end
        end
    end
}

SMODS.Joker {
    key = 'fox_censor',
    loc_txt = {
        name = 'Fox Censor',
        text = {
            '{X:red,C:white}X#1#{} Mult',
            'Debuffs {C:attention}#2#s{}, {C:attention}#3#s{}, and {C:attention}#4#s{}',
            '{C:inactive}Ranks change at the end',
            '{C:inactive}of the round'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 15, y = 2 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { xmult = 1.5, ranks = {3, 4, 5}, rank_display = {3, 4, 5} } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.rank_display[1],card.ability.extra.rank_display[2], card.ability.extra.rank_display[3] } }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            for k, v in pairs(G.playing_cards) do
                if v:get_id() == card.ability.extra.ranks[1] or v:get_id() == card.ability.extra.ranks[2] or v:get_id() == card.ability.extra.ranks[3] then
                    SMODS.debuff_card(v, true, "censorship")
                end
            end
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            for k, v in pairs(G.playing_cards) do
                if v:get_id() == card.ability.extra.ranks[1] or v:get_id() == card.ability.extra.ranks[2] or v:get_id() == card.ability.extra.ranks[3] then
                    SMODS.debuff_card(v, false, "censorship")
                end
            end
            for i = 1, #card.ability.extra.ranks do
                local ranks = {}
                for p = 2, 14 do
                    if card.ability.extra.ranks[i - 1] ~= p then
                        ranks[#ranks + 1] = p
                    end
                end
                card.ability.extra.ranks[i] = pseudorandom_element(ranks, 'hahaha_no')
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        for i = 1, #card.ability.extra.ranks do
            local ranks = {}
            for p = 2, 14 do
                if card.ability.extra.ranks[i - 1] ~= p then
                    ranks[#ranks + 1] = p
                end
            end
            card.ability.extra.ranks[i] = pseudorandom_element(ranks, 'hahaha_no')
        end
        for k, v in pairs(G.playing_cards) do
            if v:get_id() == card.ability.extra.ranks[1] or v:get_id() == card.ability.extra.ranks[2] or v:get_id() == card.ability.extra.ranks[3] then
                SMODS.debuff_card(v, true, "censorship")
            end
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        for k, v in pairs(G.playing_cards) do
            if v:get_id() == card.ability.extra.ranks[1] or v:get_id() == card.ability.extra.ranks[2] or v:get_id() == card.ability.extra.ranks[3] then
                SMODS.debuff_card(v, false, "censorship")
            end
        end
    end,

    update = function(self, card, dt)
        for i = 1, #card.ability.extra.ranks do
            if card.ability.extra.ranks[i] > 10 and card.ability.extra.ranks[i] < 15 then
                if card.ability.extra.ranks[i] == 14 then
                    card.ability.extra.rank_display[i] = 'A'
                end
                if card.ability.extra.ranks[i] == 13 then
                    card.ability.extra.rank_display[i] = 'K'
                end
                if card.ability.extra.ranks[i] == 12 then
                    card.ability.extra.rank_display[i] = 'Q'
                end
                if card.ability.extra.ranks[i] == 11 then
                    card.ability.extra.rank_display[i] = 'J'
                end
            else
                card.ability.extra.rank_display[i] = card.ability.extra.ranks[i]
            end
        end
    end
}

SMODS.Joker {
    key = 'char_kirk',
    loc_txt = {
        name = 'Kirk Van Houten',
        text = {
            '{X:red,C:white}X#1#{} Mult',
            'Lose {X:red,C:white}X#2#{} Mult when an',
            '{C:attention}enhanced{} card is discarded'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 11, y = 3 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Father', 'Divorced', 'Failure'},

    config = { extra = { xmult = 3, xmult_loss = 0.2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_loss } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
        if context.discard and not context.blueprint and context.other_card and context.other_card.config.center.key ~= 'c_base' then
            card.ability.extra.xmult = card.ability.extra.xmult - card.ability.extra.xmult_loss
            if card.ability.extra.xmult <= 0 then
                card:remove()
                return {
                    message = 'Get off my property'
                }
            else
                return {
                    message = 'X' .. card.ability.extra.xmult,
                    colour = G.C.RED
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'char_luann',
    loc_txt = {
        name = 'Luann Van Houten',
        text = {
            '{C:green}#1# in #2#{} chance to',
            'create an {C:uncommon}Uncommon{} Tag',
            'at the end of the round'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 12, y = 3 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Mother', 'Divorced', 'Blue-Haired'},

    config = { extra = { odds = 3 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "luann")
        return { vars = { numerator, denominator } }
    end,

    calculate = function (self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and SMODS.pseudorandom_probability(card, "luann", 1, card.ability.extra.odds) then
            G.E_MANAGER:add_event(Event({
                func = (function()
                    add_tag(Tag('tag_uncommon'))
                    play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                    return true
                end)
            }))
            return nil, true
        end
    end
}

SMODS.Joker {
    key = 'char_wegman',
    loc_txt = {
        name = 'Mike Wegman',
        text = {
            '{C:green}#1# in #2#{} chance to destroy',
            'each card held in hand and',
            'gain {X:red,C:white}X#3#{} Mult for each',
            'card destroyed',
            '{C:inactive}(Currently{} {X:red,C:white}X#4#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 13, y = 3 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Power Plant', 'Ginger', 'Tosser'},

    config = { extra = { odds = 3, xmult = 1, xmult_gain = 0.3 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "wegman")
        return { vars = { numerator, denominator, card.ability.extra.xmult_gain, card.ability.extra.xmult } }
    end,

    calculate = function (self, card, context)
        if context.final_scoring_step and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = (function()
                    for i = 1, #G.hand.cards do
                        if SMODS.pseudorandom_probability(card, "wegman", 1, card.ability.extra.odds) then
                            G.hand.cards[i]:start_dissolve()
                            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
                            card:juice_up(0.3,1)
                            play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                        end
                    end
                    return true
                end)
            }))
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}

SMODS.Joker {
    key = 'char_raph',
    loc_txt = {
        name = 'Raphael',
        text = {
            '{C:chips}+#1#{} Chips',
            '{C:chips}-#2#{} Chips when a',
            '{C:tarot}Tarot{} Card is used'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 14, y = 3 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Worker', 'Blue-Collar', 'Everywhere'},

    config = { extra = { chips = 150, chip_loss = 15 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chip_loss } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
        if context.using_consumeable and not context.blueprint and context.consumeable.ability.set == ("Tarot") then
            card.ability.extra.chips = card.ability.extra.chips - card.ability.extra.chip_loss
            if card.ability.extra.chips > 0 then
                return {
                    message = 'Whoops!',
                    colour = G.C.CHIPS
                }
            else
                card:remove()
                return {
                    message = 'Whoops!',
                    colour = G.C.PURPLE
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'char_stampy',
    loc_txt = {
        name = 'Stampy the Elephant',
        text = {
            '{C:chips}+#1#{} Chips',
            '{C:money}-$#2#{} when a card',
            'is scored'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 1,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 15, y = 3 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Animal', 'HUGE', 'Bart\'s'},

    config = { extra = { chips = 150, dollars = 1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.dollars } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
        if context.other_card and context.individual and context.cardarea == G.play then
            return { 
                dollars = -card.ability.extra.dollars,
            }
        end
    end
}

SMODS.Joker {
    key = 'char_zaius',
    loc_txt = {
        name = 'Dr. Zaius',
        text = {
            '{C:green}#1# in #2#{} chance to retrigger',
            'each played {C:attention}face{} card {C:attention}#3#{} times'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 11, y = 4 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Character', 'Monkey', 'Doctor'},

    config = { extra = { odds = 2, repetitions = 2 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "hecantalk")
        return { vars = { numerator, denominator, card.ability.extra.repetitions } }
    end,

    calculate = function (self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card:is_face() and SMODS.pseudorandom_probability(card, "hecantalk", 1, card.ability.extra.odds) then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
    end
}

SMODS.Joker {
    key = 'joey_jojo',
    loc_txt = {
        name = 'Joey Jo-Jo Junior Shabadoo',
        text = {
            'Retrigger scored {C:attention}Purple{}',
            'and {C:attention}Yellow{} cards'
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 12, y = 4 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = {  } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS['m_simpson_purple']
        return { vars = {  } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and 
        (SMODS.has_enhancement(context.other_card, 'm_simpson_yellow') or SMODS.has_enhancement(context.other_card, 'm_simpson_purple')) then
            return {
                repetitions = 1
            }
        end
    end,

    in_pool = function(self, args)
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if (SMODS.has_enhancement(playing_card, 'm_simpson_yellow') or SMODS.has_enhancement(playing_card, 'm_simpson_purple')) then
                return true
            end
        end
        return false
    end
}

SMODS.Joker {
    key = 'giant_hand',
    loc_txt = {
        name = 'Man With One Giant Hand',
        text = {
            '{X:red,C:white}X#1#{} Mult',
            '{C:blue}Hands{} reduced to {C:attention}#2#{}',
            '{C:attention}+#3#{} Hand Size',
            '{C:attention}+#4#{} Discards',
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 13, y = 4 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { xmult = 1.5, h_size = 4, discards = 3 } },

    loc_vars = function(self, info_queue, card)
        local hands = 1
        return { vars = { card.ability.extra.xmult, hands, card.ability.extra.h_size, card.ability.extra.discards } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return { xmult = card.ability.extra.xmult }
        end
        if context.setting_blind then
            G.E_MANAGER:add_event(Event({
                func = function()
                    ease_discard(card.ability.extra.discards, nil, true)
                    ease_hands_played(-(G.GAME.round_resets.hands - 1))
                    SMODS.calculate_effect({ message = 'Huge!'}, context.blueprint_card or card)
                    return true
                end
            }))
            return nil, true
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(card.ability.extra.h_size)
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.h_size)
    end
}

SMODS.Joker {
    key = 'char_yes_guy',
    loc_txt = {
        name = 'Yes Guy',
        text = {
            '{C:red}+#1#{} Mult'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 14, y = 4 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Yes?', 'Worker', 'Fancy'},

    config = { extra = { mult = 8 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            return { mult = card.ability.extra.mult }
        end
    end
}

SMODS.Joker {
    key = 'rex_banner',
    loc_txt = {
        name = 'Rex Banner',
        text = {
            '{C:attention}#3#{} consumeable slot',
            'Gains {X:red,C:white}X#2#{} Mult when a {V:1}Simpsons{}',
            '{V:1}Trading Card{} is used',
            '{C:inactive}(Currently{} {X:red,C:white}X#1#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 8,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 15, y = 4 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { xmult = 1, xmult_gain = 0.3, slots = -1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_gain, card.ability.extra.slots ,colours = {HEX(G_C_SIMPSONS_TRADING_CARD)} } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            return { xmult = card.ability.extra.xmult }
        end
        if context.using_consumeable and context.consumeable.config.center.set == 'SimpsonsTrading' and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
            return {
                message = 'Upgrade!',
                colour = G.C.RED
            }
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.consumeables.config.card_limit = G.consumeables.config.card_limit + card.ability.extra.slots
                return true
            end
        }))
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.consumeables.config.card_limit = G.consumeables.config.card_limit - card.ability.extra.slots
                return true
            end
        }))
    end
}

SMODS.Joker {
    key = 'hugh_jass',
    loc_txt = {
        name = 'Hugh Jass',
        text = {
            '{C:chips}+#1#{} Chips for every',
            'consumeable used this run',
            '{C:inactive}(Currently{} {C:chips}+#2#{} {C:inactive}Chips){}',
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 11, y = 5 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { chip_part = 4 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chip_part, SIMPSON_CONSUMEABLES_USED * card.ability.extra.chip_part } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            return { chips = SIMPSON_CONSUMEABLES_USED * card.ability.extra.chip_part }
        end
        if context.using_consumeable then
            return { message = 'Upgrade!', colour = G.C.CHIPS }
        end
    end
}

SMODS.Joker {
    key = 'ian',
    loc_txt = {
        name = 'Ian',
        text = {
            '{C:money}$#1#{} for every {C:attention}#2#%{} of',
            '{C:chips}chips{} over the {C:attention}blind requirement{}'
        }
    },
    blueprint_compat = false,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 12, y = 5 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { dollars = 1, percent = 10 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.percent } }
    end,

    calculate = function (self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            local ten_percent = math.floor(G.GAME.blind.chips / (100/card.ability.extra.percent))
            local difference = hand_chips - G.GAME.blind.chips
            card.ability.extra.dollars = math.floor(difference / ten_percent)
        end
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end
}

SMODS.Joker {
    key = 'john_gay',
    loc_txt = {
        name = 'John',
        text = {
            '{X:red,C:white}X#1#{} Mult if played hand',
            'contains {C:attention}2{} or more',
            'identical cards',
            '{C:inactive}(Only considers rank, suit and enhancement)'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 13, y = 5 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { xmult = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            for i = 1, #context.scoring_hand do
                local suit = context.scoring_hand[i].base.suit
                local rank = context.scoring_hand[i]:get_id()
                local enhancement = context.scoring_hand[i].config.center.key
                for p = 1, #context.scoring_hand do
                    if i ~= p then
                        if suit == context.scoring_hand[p].base.suit then
                            if rank == context.scoring_hand[p]:get_id() then
                                if enhancement == context.scoring_hand[p].config.center.key then
                                    return { xmult = card.ability.extra.xmult }
                                end
                            end
                        end
                    end
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'mr_mcgreg',
    loc_txt = {
        name = 'Mr. McGreg',
        text = {
            '{C:attention}Wild{} cards are given random',
            'enhancements after play'
        }
    },
    blueprint_compat = false,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 14, y = 5 },
    pools = { ['SpringfieldJokers'] = true },

    calculate = function (self, card, context)
        if context.final_scoring_step and not context.blueprint then
            local cen_pool = {}
            for _, enhancement_center in pairs(G.P_CENTER_POOLS["Enhanced"]) do
                if enhancement_center.key ~= 'm_stone' and enhancement_center.key ~= 'm_wild' and not enhancement_center.overrides_base_rank then
                    cen_pool[#cen_pool + 1] = enhancement_center
                end
            end
            local enhanced = false
            for _, scored_card in ipairs(context.scoring_hand) do
                if scored_card.config.center.key == 'm_wild' then
                    scored_card:set_ability(pseudorandom_element(cen_pool, 'spe_card').key, nil, true)
                    enhanced = true
                end
            end
            if enhanced == true then
                messages = {'An arm for a leg', 'A leg for an arm'}
                SMODS.calculate_effect({message = pseudorandom_element(messages, 'myoldfriend')}, card)
            end
        end
    end
}

SMODS.Joker {
    key = 'char_larry_burns',
    loc_txt = {
        name = 'Larry Burns',
        text = {
            '{C:chips}-#1#{} Chips',
            'All items in the {C:money}shop{}',
            'cost {C:attention}#2#%{} less'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 15, y = 5 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Son', 'Estranged', 'Poor'},

    config = { extra = { chips = -40, discount = 15 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { -card.ability.extra.chips, card.ability.extra.discount } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
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
                G.GAME.discount_percent = 0
                for _, v in pairs(G.I.CARD) do
                    if v.set_cost then v:set_cost() end
                end
                return true
            end
        }))
    end
}

SMODS.Joker {
    key = 'mccartney',
    loc_txt = {
        name = 'Sir James Paul McCartney',
        text = {
            '{C:chips}Bonus{} Cards give',
            '{C:money}$#1#{} when scored'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 11, y = 6 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { dollars = 3 } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS['m_bonus']
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function (self, card, context)
        if context.other_card and context.individual and context.cardarea == G.play and SMODS.has_enhancement(context.other_card, 'm_bonus') then
            return { dollars = card.ability.extra.dollars }
        end
    end
}

SMODS.Joker {
    key = 'char_kang',
    loc_txt = {
        name = 'Kang',
        text = {
            'Retrigger all cards with',
            '{V:1}#1#{} Suit',
            '{C:inactive}(Suit changes after{}',
            '{C:inactive}every hand){}'
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 12, y = 6 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Alien', 'Green', 'Evil'},

    config = { extra = { suit = 'Hearts', repetitions = 1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.suit, colours = { G.C.SUITS[card.ability.extra.suit] } } }
    end,

    calculate = function (self, card, context)
        if context.repetition and context.other_card:is_suit(card.ability.extra.suit) then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
        if context.final_scoring_step and not context.blueprint then
            card.ability.extra.suit = pseudorandom_element(SMODS.Suits, 'kang').key
        end
    end
}

SMODS.Joker {
    key = 'char_kodos',
    loc_txt = {
        name = 'Kodos',
        text = {
            '{C:attention}#1#{}s, {C:attention}#2#{}s, and {C:attention}#3#{}s give',
            '{C:chips}+#4#{} Chips when scored',
            '{C:inactive}(Ranks change at the',
            '{C:inactive}end of the round)'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 13, y = 6 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'Alien', 'Green', 'Evil'},

    config = { extra = { rank = {2, 4, 6}, rank_display = {2, 4, 6}, chips = 20 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rank_display[1], card.ability.extra.rank_display[2], card.ability.extra.rank_display[3], card.ability.extra.chips } }
    end,

    calculate = function (self, card, context)
        if context.other_card and context.individual and context.cardarea == G.play and 
        (context.other_card:get_id() == card.ability.extra.rank[1] or context.other_card:get_id() == card.ability.extra.rank[2] or context.other_card:get_id() == card.ability.extra.rank[3] ) then
            return { chips = card.ability.extra.chips }
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            for i = 1, #card.ability.extra.rank do
                card.ability.extra.rank[i] = pseudorandom('kodos_chips', 2, 14)
            end
        end
    end,

    update = function(self, card, dt)
        for i = 1, #card.ability.extra.rank do
            if card.ability.extra.rank[i] > 10 and card.ability.extra.rank[i] < 15 then
                if card.ability.extra.rank[i] == 14 then
                    card.ability.extra.rank_display[i] = 'A'
                end
                if card.ability.extra.rank[i] == 13 then
                    card.ability.extra.rank_display[i] = 'K'
                end
                if card.ability.extra.rank[i] == 12 then
                    card.ability.extra.rank_display[i] = 'Q'
                end
                if card.ability.extra.rank[i] == 11 then
                    card.ability.extra.rank_display[i] = 'J'
                end
            else
                card.ability.extra.rank_display[i] = card.ability.extra.rank[i]
            end
        end
    end
}

SMODS.Joker {
    key = 'leprechaun',
    loc_txt = {
        name = 'Ralph\'s Leprechaun',
        text = {
            'Level up {C:attention}third{} played',
            'hand at the end of the',
            'round'
        }
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 7,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 14, y = 6 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { third_played = nil } },

    calculate = function (self, card, context)
        if context.setting_blind and not context.bluepring then
            card.ability.extra.third_played = nil
        end
        if context.before and G.GAME.current_round.hands_played == 2 and not context.blueprint then
            card.ability.extra.third_played = context.scoring_name
        end
        if context.end_of_round and context.game_over == false and context.main_eval and card.ability.extra.third_played ~= nil then
            SMODS.upgrade_poker_hands({hands = {card.ability.extra.third_played}, level_up = 1, from = card})
        end
    end,

    in_pool = function(self, args)
        if G.GAME.round_resets.hands <= 3 then
            return true
        end
        return false
    end
}

SMODS.Joker {
    key = 'peanuts',
    loc_txt = {
        name = 'Peanut Factory Manager',
        text = {
            'Earn an extra {C:money}$#1#{}',
            'when a card is sold'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 15, y = 6 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { dollars = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function (self, card, context)
        if context.selling_card then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
            return {
                dollars = card.ability.extra.dollars,
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
    atlas = 'SimpsJokers',
    pos = { x = 0, y = 0 },
    pools = { ['SpringfieldJokers'] = true },
    hints = {'1', '2', '3'},

    config = { extra = {  } },

    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,

    calculate = function (self, card, context)
    
    end
}
]]



SMODS.Joker {
    key = 'who_shot',
    loc_txt = {
        name = 'Who Shot Mr. Burns?',
        text = {
            'Perpetrator: {C:attention}#1#{}',
            'Hint: {C:attention}#2#{}',
            'Hint: {C:attention}#3#{}',
            'Hint: {C:attention}#4#{}',
            '---',
            'Find the perp for {X:red,C:white}X#5#{} Mult',
            '{C:attention}+#6#{} card slot available in shop',
            '{C:inactive}Hints given at the end',
            '{C:inactive}of a Boss Blind'
        }
    },
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 0, y = 0 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { perp = '???', hints = {'???', '???', '???'}, xmult = 3, real_perp = nil, found = false, real_hints = {}, shop_size = 1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.perp, card.ability.extra.hints[1], card.ability.extra.hints[2], card.ability.extra.hints[3], card.ability.extra.xmult, card.ability.extra.shop_size } }
    end,

    calculate = function (self, card, context)
        if context.joker_main and card.ability.extra.found then
            return { xmult = card.ability.extra.xmult }
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            local done = false
            if G.GAME.blind.boss and card.ability.extra.found == false and done == false then
                for i = 1, #card.ability.extra.hints do
                    if card.ability.extra.hints[i] == '???' then
                        card.ability.extra.hints[i] = card.ability.extra.real_hints[i]
                        return {
                            message = 'Update!'
                        }
                    end
                end
            end
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        if card.ability.extra.real_perp == nil then
            local jokers = {}
            local rarities = {'Common', 'Common', 'Common', 'Common', 'Uncommon', 'Uncommon','Uncommon', 'Rare' }
            local rarity = pseudorandom_element(rarities, 'mrbruns')
            for i = 1, #SMODS.get_clean_pool('Joker', rarity) do
                if string.find(SMODS.get_clean_pool('Joker', rarity)[i], "j_simpson_char") then
                    jokers[#jokers + 1] = SMODS.get_clean_pool('Joker', rarity)[i]
                end
            end
            card.ability.extra.real_perp = pseudorandom_element(jokers, 'mrbruns')
            print(card.ability.extra.real_perp)
            card.ability.extra.real_hints = G.P_CENTERS[card.ability.extra.real_perp].hints
            G.E_MANAGER:add_event(Event({
                func = function()
                    change_shop_size(card.ability.extra.shop_size)
                    return true
                end
            }))
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                change_shop_size(-card.ability.extra.shop_size)
                return true
            end
        }))
    end,

    update = function(self, card, dt)
        if card.ability.extra.found == false and next(SMODS.find_card(card.ability.extra.real_perp)) then
            card.ability.extra.found = true
            card.ability.extra.perp = G.P_CENTERS[card.ability.extra.real_perp].loc_txt.name
            SMODS.calculate_effect({message = "Found them!"}, card)
            print('Found it!')
        end
    end
}