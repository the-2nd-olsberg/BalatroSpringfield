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
--penis

SMODS.Joker {
    key = 'american_cheese',
    loc_txt = {
        name = 'American Cheese',
        text = {
            'All cards gain {X:red,C:white}X#1#{} Mult',
            'when scored, {C:attention}#3#th{} scored card',
            'gains {X:red,C:white}X#2#{} Mult',
            '{C:inactive}({}{C:attention}#4#{} {C:inactive}cards remaining){}'
        }
    },
    blueprint_compat = true,
    rarity = 4,
    cost = 20,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 16, y = 1 },
    soul_pos = { x = 16, y = 3 },
    pools = { },

    config = { extra = { xmult = 0.3, xmult_64 = 1, cards = 64, scored = 0 } },

    loc_vars = function(self, info_queue, card)
        local remaining = card.ability.extra.cards - card.ability.extra.scored
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_64, card.ability.extra.cards, remaining } }
    end,

    calculate = function (self, card, context)
        if context.cardarea == G.play and context.individual and context.other_card then
            local remaining = card.ability.extra.cards - card.ability.extra.scored
            if remaining > 1 then
                context.other_card.ability.perma_x_mult = (context.other_card.ability.perma_x_mult or 1) + card.ability.extra.xmult
                card.ability.extra.scored = card.ability.extra.scored + 1
                return {
                    message = 'Upgrade!'
                }
            else
                context.other_card.ability.perma_x_mult = (context.other_card.ability.perma_x_mult or 1) + card.ability.extra.xmult_64
                card.ability.extra.scored = 0
                return {
                    message = 'I think I\'m blind'
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'sparkle',
    loc_txt = {
        name = 'Mr. Sparkle',
        text = {
            'All played {C:attention}unenhanced{}',
            'cards give {X:red,C:white}X#1#{} Mult',
            'when scored'
        }
    },
    blueprint_compat = true,
    rarity = 4,
    cost = 20,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 17, y = 1 },
    soul_pos = { x = 17, y = 3 },


    config = { extra = { xmult = 1.5 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function (self, card, context)
        if context.cardarea == G.play and context.individual and context.other_card then
            if context.other_card.config.center.key == 'c_base' then
                return {
                    xmult = card.ability.extra.xmult
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'tv',
    loc_txt = {
        name = 'TV',
        text = {
            '{X:red,C:white}X#1#{} Mult for every',
            '{C:attention}Voucher{} redeemed this run',
            '{C:inactive}(Currently{} {X:red,C:white}X#2#{} {C:inactive}Mult){}',
            '{C:green}#3# in #4#{} chance to create',
            'up to {C:attention}#5# Voucher Tags{} at the',
            'end of the round'
        }
    },
    blueprint_compat = true,
    rarity = 4,
    cost = 30,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 18, y = 1 },
    soul_pos = { x = 18, y = 3 },


    config = { extra = { xmult_part = 0.7, odds = 2, tags = 3 } },

    loc_vars = function(self, info_queue, card)
        local count = 0
        for _, v in pairs(G.GAME.used_vouchers) do
            count = count + 1
        end
        local xmult = (count * card.ability.extra.xmult_part) + 1
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "tv_sucks")
        return { vars = { card.ability.extra.xmult_part, xmult, numerator, denominator, card.ability.extra.tags } }
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            local count = 0
            for _, v in pairs(G.GAME.used_vouchers) do
                count = count + 1
            end
            local xmult = (count * card.ability.extra.xmult_part) + 1
            print(G.vouchers)
            return {
                xmult = xmult
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval and SMODS.pseudorandom_probability(card, "tv_sucks", 1, card.ability.extra.odds) then
            local amount = pseudorandom('tags', 1, card.ability.extra.tags)
            G.E_MANAGER:add_event(Event({
                func = (function()
                    for i = 1, amount do
                        add_tag(Tag('tag_voucher'))
                        play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                        play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                    end
                    SMODS.calculate_effect({message = "TV!"}, card)
                    return true
                end)
            }))
            return nil, true
        end
    end
}

SMODS.Joker {
    key = 'worstbox',
    loc_txt = {
        name = 'Worst DVD Case of All Time',
        text = {
            'All scored cards become {C:attention}6s{}',
            'after play, all played {C:attention}6s{} gain',
            '{X:red,C:white}X#1#{} Mult when scored'
        }
    },
    blueprint_compat = true,
    rarity = 4,
    cost = 30,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = 'SimpsJokers',
    pos = { x = 19, y = 1 },


    config = { extra = { xmult_gain = 0.6 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_gain } }
    end,

    calculate = function (self, card, context)
        if context.final_scoring_step and not context.blueprint then
            for i = 1, #context.scoring_hand do
                local percent = 1.15 - (i - 0.999) / (#context.scoring_hand - 0.998) * 0.3
                if context.full_hand[i]:get_id() ~= 6 then
                    G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        context.scoring_hand[i]:flip()
                        play_sound('card1', percent)
                        context.scoring_hand[i]:juice_up(0.3, 0.3)
                        return true
                    end
                    }))
                end
            end
            for i = 1, #context.scoring_hand do
                if context.full_hand[i]:get_id() ~= 6 then
                    G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        SMODS.change_base(context.scoring_hand[i], nil, '6')
                        return true
                    end
                    }))
                end
            end
            for i = 1, #context.scoring_hand do
                local percent = 1.15 - (i - 0.999) / (#context.scoring_hand - 0.998) * 0.3
                if context.scoring_hand[i]:get_id() ~= 6 then
                    G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        context.scoring_hand[i]:flip()
                        play_sound('card1', percent)
                        context.scoring_hand[i]:juice_up(0.3, 0.3)
                        return true
                    end
                    }))
                end
            end
        end
        if context.individual and context.cardarea == G.play and context.other_card:get_id() == 6 then
            context.other_card.ability.perma_x_mult = (context.other_card.ability.perma_x_mult or 1) + card.ability.extra.xmult_gain
            return {
                message = 'Upgrade!',
                colour = G.C.RED
            }
        end
    end
}