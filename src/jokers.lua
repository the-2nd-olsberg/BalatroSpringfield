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
            'destroy the last {C:attention}scored{} card'
        }
    },
    blueprint_compat = false,
    rarity = 2,
    cost = 6,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 0, y = 1 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = {} },

    calculate = function(self, card, context)
        if context.destroy_card and context.scoring_hand and context.cardarea == G.play and 
        #context.full_hand == 5 and (context.destroy_card == context.scoring_hand[#context.scoring_hand])
        and not context.blueprint then
            return {
                remove = true,
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
    pos = { x = 1, y = 1 },
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
    pos = { x = 2, y = 1 },
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
            '{X:chips,C:white}X#1#{} Chips when scored'
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 3, y = 1 },
    pools = { ['SpringfieldJokers'] = true },

    config = { extra = { xchips = 1.1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xchips } }
    end,

    calculate = function(self, card, context)
        if context.other_card and context.individual and context.cardarea == G.play and context.other_card:is_face(true) then
            return { xchips = card.ability.extra.xchips }
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
            'GSains {C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult',
            'from every {C:attention}enhancement{} removed',
            '{C:inactive}(Currently{} {C:chips}+#3#{} {C:inactive}Chips{}{C:red} +#4#{} {C:inactive}Mult){}',
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 4, y = 1 },
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
            if amount > 1 then
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