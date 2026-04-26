--Atlas
SMODS.Atlas {
    key = 'SimpsEnhance',
    path = 'enhances.png',
    px = 71,
    py = 95
}

--Enhancements
SMODS.Enhancement {
    key = 'yellow',
    loc_txt = {
        name = "Yellow Card",
        text = {
            "{X:red,C:white}X#1#{} Mult",
        }
    },
    atlas = 'SimpsEnhance',
    pos = { x = 1, y = 0 },
    config = { extra = { xmult = 1.2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}

SMODS.Enhancement {
    key = 'purple',
    loc_txt = {
        name = "Purple Card",
        text = {
            "{C:chips}+#4#{} Chips",
            "{C:red}+#3#{} Mult",
            "{C:green}#1# in #2#{} chance",
            "to become {C:attention}Yellow{}"
        }
    },
    atlas = 'SimpsEnhance',
    pos = { x = 2, y = 0 },
    config = { extra = { chips = 20, mult = 1, odds = 4 } },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS['m_simpson_yellow']
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'die')
        return { vars = { numerator, denominator, card.ability.extra.chips, card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            return {
                chips = card.ability.extra.chips,
                mult = card.ability.extra.mult
            }
        end
        if context.after and SMODS.pseudorandom_probability(card, 'die', 1, card.ability.extra.odds) then
            card:set_ability('m_simpson_yellow', nil, true)
            return {
                message = "Yellow!"
            }
        end
    end
}
--67!
SMODS.Enhancement {
    key = 'green',
    loc_txt = {
        name = "Green Card",
        text = {
            "{X:red,C:white}X#3#{} Mult and {C:green}#1# in #2#{} chance",
            "to infect a random card in hand",
            "when scored",
            "{X:red,C:white}X#4#{} Mult",
            "when held in hand"
        }
    },
    atlas = 'SimpsEnhance',
    pos = { x = 3, y = 0 },
    config = { extra = { xmult_good = 1.3, xmult_bad = 0.7, odds = 3 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'infect')
        return { vars = { numerator, denominator, card.ability.extra.xmult_bad, card.ability.extra.xmult_good } }
    end,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            if SMODS.pseudorandom_probability(card, 'infect', 1, card.ability.extra.odds) then
                local pos = pseudorandom('spread', 1, #G.hand.cards)
                G.hand.cards[pos]:set_ability('m_simpson_green', nil, true)
                SMODS.calculate_effect({message = "Infection!"}, G.hand.cards[pos])
            end
            return {
                xmult = card.ability.extra.xmult_bad
            }
        end
        if context.main_scoring and context.cardarea == G.hand then
            return {
                xmult = card.ability.extra.xmult_good
            }
        end
    end
}

SMODS.Enhancement {
    key = 'alcohol',
    loc_txt = {
        name = "Alcoholic Card",
        text = {
            "Between {C:chips}#1#{}",
            "and {C:chips}+#2#{} Chips"
        }
    },
    atlas = 'SimpsEnhance',
    pos = { x = 4, y = 0 },
    config = { extra = { chips_b = -10, chips_m = 60 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips_b, card.ability.extra.chips_m } }
    end,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            return {
                chips = pseudorandom('drunk', card.ability.extra.chips_b, card.ability.extra.chips_m)
            }
        end
    end
}

SMODS.Enhancement {
    key = 'leatherbound',
    loc_txt = {
        name = "Leatherbound Card",
        text = {
            "Immune to {C:red}Debuff{}",
            "{C:chips}+#1#{} Chips when played",
            "or held in hand"
        }
    },
    atlas = 'SimpsEnhance',
    pos = { x = 5, y = 0 },
    config = { extra = { chips = 15 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,
    calculate = function(self, card, context)
        if context.main_scoring then
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}

SMODS.current_mod.set_debuff = function(card)
    if SMODS.has_enhancement(card, 'm_simpson_leatherbound') then
        return 'prevent_debuff'
    end
end

SMODS.Enhancement {
    key = 'grilled',
    loc_txt = {
        name = "Grilled Card",
        text = {
            "{C:red}+#3#{} Mult",
            "{C:green}#1# in #2#{} chance",
            "of {X:red,C:white}X#4#{} Mult",
        }
    },
    atlas = 'SimpsEnhance',
    pos = { x = 1, y = 1 },
    config = { extra = { mult = 2, xmult = 1.3, odds = 3 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'grillin')
        return { vars = { numerator, denominator, card.ability.extra.mult, card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            if SMODS.pseudorandom_probability(card, 'grillin', 1, card.ability.extra.odds) then
                return {
                    xmult = card.ability.extra.xmult
                }
            end
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}