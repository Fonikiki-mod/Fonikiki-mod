--Establecer mod path de location
local mod_path = "" .. SMODS.current_mod.path
local files = NFS.getDirectoryItems(mod_path .. "localization")
for _, file in ipairs(files) do
	print("[FONIKIKI] Loading localization file " .. file)
	local f, err = SMODS.load_file("localization/" .. file)
	if err then
		error(err) 
	end
	f()
end

--RNG
local function random_float(min, max)
    return min + (max - min) * math.random()
end

--ATLASES
--Establecer icono del mod
SMODS.Atlas({
    key = "modicon",
    path = "icon.png",
    px = 32,
    py = 32
})

-- Atlas Jokers
SMODS.Atlas{
    key = 'Jokers1',
    path = 'Jokers1.png',
    px = 71,
    py = 95
}

--Atlas Tarot
SMODS.Atlas{
    key = 'Tarot',
    path = 'Tarot.png',
    px = 71,
    py = 95
}

--Atlas del puto perro
SMODS.Atlas{
    key = 'perro',
    path = 'Fuckass_dog.png',
    px = 128,
    py = 171
}

--Atlas balatro balatrez
SMODS.Atlas{
    key = 'balatro_balatrez',
    path = 'Balatro_balatrez.png',
    px = 406,
    py = 448
}

--Atlas joker que cojones
SMODS.Atlas{
    key = 'que_cojones',
    path = 'pero_que_cojones_tio.png',
    px = 526,
    py = 705,
    disable_mipmap = true
}

-- Atlas Barajas
SMODS.Atlas{
    key = 'Decks1',
    path = 'Decks1.png',
    px = 71,
    py = 95
}

--JOKER
--Click Click Click
SMODS.Joker{
    key = 'fonikiki_click',
    loc_txt = {
        name = 'Clic',
        text = {
            'Otorga {C:mult}+#1#{} Multi. Se',
            'reduce en {C:attention}#2#{} por carta jugada',
        }
    },
    
    unlocked = true,
    discovered = true,
    atlas = 'Jokers1', 
    pos = { x = 1, y = 3 },
    rarity = 1,
    cost = 4,
    config = {
		extra = {
			mult_value = 80,     
		},
	},

	loc_vars = function(self, info_queue, center)
		return {
			vars = {
				number_format(center.ability.extra.mult_value),
                number_format(1),
			},
		}
	end,
    
	calculate = function(self, card, context)
		if context.joker_main then
            local current_mult = card.ability.extra.mult_value
            local deduction = #context.scoring_hand 
            local new_mult = math.max(0, current_mult - deduction)
            local mult_to_add = new_mult
            card.ability.extra.mult_value = new_mult
            local message_text
            local message_color
            if deduction > 0 then
                message_color = G.C.RED
            else
                message_color = G.C.MULT 
            end
            message_text = "+" .. number_format(mult_to_add) .. " Multi"
            return {
                card = card,
                mult_mod = lenient_bignum(mult_to_add),
                message = message_text,
                colour = message_color,
                operation = "+", 
            }
		end
	end
}

--jeje (No tocar, este joker me ha costado 4 horas de mi vida que no voy a volver a recuperar y encima la mitad del codigo es robado del yahimod XD)
SMODS.Joker{
    key = 'fonikiki_ehh',
    loc_txt= {
        name = 'Fonikiki??',
        text = {
            "Un joker muy normal que aporta {C:mult}+#1#{} Mult.",
            "{C:green}#2# en #3#{} de que haga un video ahora mismo.",
            '{s:2,C:red}:)',
        }
    },
    
    unlocked = true,
    discovered = true,
    atlas = 'Jokers1',
    pos = { x = 3, y = 2},
    rarity = 1,
    cost = 3,
    config = { extra = {mult = 50, odds = 4}},
    blueprint_compat = false,

    loc_vars = function(self, info_queue, card)
        return { 
            vars = { 
                card.ability.extra.mult, 
                (G.GAME.probabilities.normal or 1), 
                card.ability.extra.odds 
            } 
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local mult_val = card.ability.extra.mult
            if pseudorandom('beemovie') < G.GAME.probabilities.normal / card.ability.extra.odds then
                if G.beemoviescript and type(G.beemoviescript) == 'table' then
                    local base_delay = 0.2
                    for i = 1, #G.beemoviescript do
                        G.E_MANAGER:add_event(Event({
                            trigger = 'immediate',
                            blocking = false,
                            delay = base_delay * i,
                            func = function()
                                card_eval_status_text(card, 'extra', nil, nil, nil, {message = G.beemoviescript[i]})
                                return true
                            end,
                        }))
                    end
                end
            end
            return {
                mult_mod = mult_val,
                message = "+" .. number_format(mult_val) .. " Multi"
            }
        end
    end,
}

--Vinagre
SMODS.Joker{
    key = 'fonikiki_vinagre',
    loc_txt = {
        name = 'El vinagre',
        text = {
            '{C:green}#1# en #2#{} de probabilidad de obtener una',
            '{C:attention}Etiqueta aleatoria{} al jugar {C:attention}1{} sola carta.'
        }
    },

    unlocked = true,
    discovered = true,
    rarity = 2,
    atlas = 'Jokers1',
    pos = {x=2, y=2},
    cost = 4,
    blueprint_compat = false,
    config = { extra = { odds = 2 } }, 

    loc_vars = function(self, info_queue, card)
        return { vars = { (G.GAME.probabilities.normal or 1), card.ability.extra.odds } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if #context.scoring_hand == 1 then
                -- Probabilidad compatible con Oops! All 6s
                if pseudorandom('vinagre_chance') < G.GAME.probabilities.normal / card.ability.extra.odds then 
                    local L_add_tag = rawget(_G, 'add_tag')
                    local L_Tag = rawget(_G, 'Tag')
                    local G_P_TAGS = rawget(rawget(_G, 'G'), 'P_TAGS')
                    
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.3, 
                        func = (function()
                            if L_add_tag and L_Tag and G_P_TAGS then
                                local tag_keys = {}
                                for key, tag in pairs(G_P_TAGS) do
                                    if tag and tag.key and not tag.key:find('boss') and not tag.hidden then
                                        table.insert(tag_keys, tag.key)
                                    end
                                end
                                if #tag_keys > 0 then
                                    -- Usamos pseudorandom para la selección de la etiqueta también
                                    local random_tag_key = pseudorandom_element(tag_keys, pseudoseed('vinagre_tag'))
                                    L_add_tag(L_Tag(random_tag_key))
                                end
                            end
                            return true
                        end)
                    }))
                    return {
                        message = "Etiqueta!",
                        colour = G.C.GREEN
                    }
                end
            end
        end
    end
}

--joker peseta
SMODS.Joker{
    key = 'fonikiki_peseta',
    loc_txt = {
        name = 'Peseta',
        text = {
            'Al final de la ronda, si tu dinero total',
            'es un múltiplo de {C:attention}25{}, ganas {C:money}$25{} extra.'
        }
    },

    unlocked = true,
    discovered = true,
    pos = { x = 1 , y = 4 },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    atlas = 'Jokers1',
    config = {
        extra = {
            bonus_money = 25,
            divisor = 25,
        }
    },
    
    calc_dollar_bonus = function(self, card)
        local current_money = G.GAME.dollars
        if type(current_money) == 'table' then
            current_money = current_money.v or current_money.num or 0 
        end
        current_money = math.floor(tonumber(current_money) or 0)
        local divisor = self.config.extra.divisor -- 25
        local bonus_money = self.config.extra.bonus_money -- 10
        if current_money > 0 and current_money % divisor == 0 then
            return bonus_money
        end
        return nil
    end
}

-- Joker Lol guy joker
SMODS.Joker{
    key = 'fonikiki_lol_guy',
    loc_txt = {
        name = 'Lol guy',
        text = {
            'Otorga {C:red}+#1#{} descartes en', 
            'la ronda. Cada vez que se',
            'descarta, Lol guy {C:atention}comenta'
        }
    },

    unlocked = true,
    discovered = true,
    atlas = 'Jokers1',
    pos = {x = 1, y = 0},
    rarity = 2,
    cost = 4,
    blueprint_compat = false,
    config = { 
        extra = { 
            discard_size = 2 
        } 
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.discard_size } }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.discard_size
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.discard_size
    end,
    
    calculate = function(self, card, context)
        if context.discard then
            local messages = {'Who is fonikiki?', 'What is a "Alexby"', 'Buy token fan and sell perkeo', 'Balatoro', 'Patalano', 'Perkeo stinks', 'balatotor balatrez', 'Token fan better', 'Im not a bot', 'Photochad=trash', 'Play and buy silksong', 'Nanefonikikinf', 'Who records to .MKV?', 'no', 'lol', 'vinagre', 'I want a coffee', 'I am form the Earth', 'I am from balatroland', 'Ñ?????', 'hahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahaha', 'Twitch chat sucks'}
            local random_message = pseudorandom_element(messages, pseudoseed('lol_guy_message'))
            card_eval_status_text(card, 'extra', nil, nil, nil,
                { message = random_message,
                  colour = G.C.JOKER })
        end
    end
}

-- 20 rupias romanas joker
SMODS.Joker{
    key = 'fonikiki_20_euros',
    loc_txt = {
        name = '20 euros, son 20 euros',
        text = {
            'Otorga {C:money}$#1#{} al final de la ronda,', 
            'dividido por el número de Jokers que tengas.',
            '{C:inactive}(Actualmente dividido por {C:attention}#2#{C:inactive})'
        }
    },

    unlocked = true,
    discovered = true,
    atlas = 'Jokers1',
    pos = {x = 3, y = 0}, 
    rarity = 2,
    cost = 6,
        blueprint_compat = false,
    config = {
        extra = {
            money = 20,
        }
    },

    loc_vars = function(self, info_queue, card)
        local total_jokers = (G.jokers and #G.jokers.cards) or 1
        local divisor = total_jokers
        local money_value = self.config.extra.money
        return { vars = { money_value, divisor } }
    end,
    calc_dollar_bonus = function(self, card)
        local base_money = self.config.extra.money
        local total_jokers = #G.jokers.cards
        local raw_money = base_money / total_jokers
        local bonus_money = math.floor(raw_money)
        if bonus_money > 0 then 
            return bonus_money 
        end
    end
}

--Trabajo joker
SMODS.Joker{
    key = 'fonikiki_job',
    loc_txt = {
        name = 'Job aplication.',
        text = {
            'Gana {C:money}$#1#{} al final de la',
            'ronda si se juega un {C:atention}Color{}'
        }
    },

    unlocked = true,
    discovered = true,
    config = { extra = { money = 5, earned_bonus = 0 } },
    rarity = 2,
    atlas = 'Jokers1',
    pos = { x = 2, y = 1 },
    cost = 6,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money } }
    end,

    calculate = function(self, card, context)
        if context.before and next(context.poker_hands['Flush']) and not context.blueprint then
            card.ability.extra.earned_bonus = card.ability.extra.money
            return{
                message = '¡Color!',
                colour = G.C.MONEY,
                card = card
            }
        end
    end,

    calc_dollar_bonus = function(self, card)
        local bonus = card.ability.extra.earned_bonus
        if bonus > 0 then 
            card.ability.extra.earned_bonus = 0
            return bonus 
        end
    end
}

--Monetización
SMODS.Joker{
    key = 'fonikiki_monetizacion',
    loc_txt = {
        name = 'Monetización',
        text = {
            "Cuando se descarta {C:green}#1# en #2#{}",
            "probabilidades de otorgar {C:money}$#3#{}"
        }
    },
    config = { 
        extra = { 
            money_value = 4,
            odds = 4
        } 
    },

    unlocked = true,
    discovered = true,
    rarity = 2,
    atlas = 'Jokers1', 
    pos = {x = 0, y = 2},
    cost = 7,
    blueprint_compat = true,

    loc_vars = function(self, info_queue, card)
        local extra = card.ability.extra
        return { 
            vars = { 
                (G.GAME.probabilities.normal or 1),
                extra.odds,
                extra.money_value
            } 
        }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra
        if context.discard and context.other_card == context.full_hand[#context.full_hand] then
            if pseudorandom('monetization_discard_action') < G.GAME.probabilities.normal / extra.odds then
                local money_earned = extra.money_value
                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + money_earned
                return {
                    dollars = money_earned,
                    colour = G.C.MONEY,
                    retriggerable = true,
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.5,
                            func = function()
                                G.GAME.dollar_buffer = 0
                                return true
                            end,
                        }))
                    end,
                }
            end
        end
    end
}

--Fresa dorada joker (celeste juegazo)
SMODS.Joker {
    key = 'fonikiki_fresa',
    loc_txt = {
        name = 'Fresa {C:gold}dorada{}',
        text = {
            '{C:mult}+#1#{} Mult.', 
            '{C:green}#2# en #3#{} probabilidades de',
            'destruirse al final de la ronda'
        }
    },

    unlocked = true,
    discovered = true,
    config = { 
        extra = { 
            mult_value = 30,
            odds = 4
        } 
    },
    no_pool_flag = 'fonikiki_fresa_extinct',
    rarity = 1,
    blueprint_compat = true,
    atlas = 'Jokers1', 
    pos = {x = 1, y = 1}, 
    cost = 4,
    eternal_compat = false,

    loc_vars = function(self, info_queue, card)
        return { 
            vars = { 
                card.ability.extra.mult_value, 
                (G.GAME.probabilities.normal or 1), 
                card.ability.extra.odds 
            } 
        }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra
        if context.joker_main then
            return {
                mult_mod = extra.mult_value,
                message = localize { type = 'variable', key = 'a_mult', vars = { extra.mult_value } }
            }
        end

        if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
            if pseudorandom('fonikiki_fresa_destroy') < G.GAME.probabilities.normal / extra.odds then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.drag.is = true
                        card.children.center.pinch.x = true
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.3,
                            blockable = false,
                            func = function()
                                G.jokers:remove_card(card)
                                card:remove()
                                card = nil
                                return true;
                            end
                        }))
                        return true
                    end
                }))
                
                G.GAME.pool_flags.fonikiki_fresa_extinct = true
                return {
                    message = '¡Muerto!',
                    colour = G.C.RED
                }
            else
                return {
                    message = '¡Seguro!'
                }
            end
        end
    end
}

--Fresa dorada de farewell joker (farewell capitulazo)
SMODS.Joker{
    key = 'fonikiki_fresa_farewell',
    loc_txt = {
        name = 'Fresa {C:gold}dorada{} de {C:dark_edition}Farewell{}',
        text = {
            '{C:white,X:red}X#1#{} multi.',
            '{C:green}#2# en #3#{} probabilidades',
            'de obtener {X:black,C:red,s:2}^#4#{} de multi'
        }
    },

    unlocked = true,
    discovered = true,
    config = { 
        extra = { 
            mult_value = 4,
            power_mult = 1.2,
            odds = 10,
        },
    },
    yes_pool_flag = 'fonikiki_fresa_extinct',
    rarity = 3,
    blueprint_compat = true,
    atlas = 'Jokers1',
    pos = { x = 3, y = 1 },
    cost = 10,
    
    loc_vars = function(self, info_queue, card)
        local extra = card.ability.extra
        local power_mult_display = extra.power_mult or self.config.extra.power_mult

        return { 
            vars = { 
                extra.mult_value or self.config.extra.mult_value,
                (G.GAME.probabilities.normal or 1), 
                extra.odds or self.config.extra.odds,
                power_mult_display
            } 
        }
    end,

    -- Función de migración porque por alguna razón los valores no migran. (quitar esto si funciona bien en la beta)
    update_ability = function(self, card)
        local extra = card.ability.extra
        local config_extra = self.config.extra

        if extra.mult_value ~= config_extra.mult_value then
            extra.mult_value = config_extra.mult_value
            card.T.misc_data.updated = true 
        end
        
        if extra.power_mult ~= config_extra.power_mult then
            extra.power_mult = config_extra.power_mult
            card.T.misc_data.updated = true
        end

        if extra.odds ~= config_extra.odds then
            extra.odds = config_extra.odds
            card.T.misc_data.updated = true
        end
        return card
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        if context.joker_main then
            
            local returns = {
                mult_mod = extra.mult_value, 
                mult_mod_type = 'mult',
                colour = G.C.MULT
            }

            if pseudorandom('fonikiki_farewell_power') < G.GAME.probabilities.normal / extra.odds then
                returns.mult_mod = 0
                returns.e_mult = extra.power_mult
                returns.colour = G.C.RED
            else
                returns.message = "X" .. extra.mult_value .. " Multi"
            end
            return returns
        end
    end
}

-- El cafe joker
SMODS.Joker{
    key = 'fonikiki_Cafe',
    loc_txt = {
        name = 'El Café',
        text = {
            'Consigue {C:white,X:red}X0.2{} de multi. Si se',
            'juega una mano de {C:attention}5{} cartas.',
            '{C:inactive}(Actualmente {X:mult,C:white}X#1#{C:inactive} Mult.)'
        }
    },

    unlocked = true,
    discovered = true,
    atlas = 'Jokers1',
    pos = {x = 0, y = 0},
    rarity = 3,
    cost = 8,
    blueprint_compat = true,
    config = {
        extra = {
            Xmult = 1
        }
    },

    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.Xmult}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                card = card,
                Xmult_mod = card.ability.extra.Xmult,
                message = 'X' .. tostring(card.ability.extra.Xmult),
                colour = G.C.MULT
            }
        end

        if context.before and not context.blueprint then
            if #context.scoring_hand == 5 then
                card.ability.extra.Xmult = card.ability.extra.Xmult + 0.2
                return {
                    message = '¡Mejorado!',
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
    end
}

-- cafe descafeinado joker
SMODS.Joker{
    key = 'fonikiki_Cafe_descafeinado',
    loc_txt = {
        name = 'Café descafeinado',
        text = {
            'Otorga {C:red}+4{} Multi, por cada mano',
            'jugada con {C:attention}4{} cartas o menos',
            '{C:inactive}(Actualmente {C:mult}+#1# {C:inactive}multi)' 
        }
    },

    unlocked = true,
    discovered = true,
    atlas = 'Jokers1',
    pos = {x = 2, y = 0},
    rarity = 3,
    cost = 3,
    blueprint_compat = true,
    config = {
        extra = {
            mult = 0
        }
    },

    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.mult}} 
    end,

    calculate = function(self, card, context)
        card.ability.extra.mult = card.ability.extra.mult or self.config.extra.mult

        if context.joker_main then
            return {
                card = card,
                mult_mod = card.ability.extra.mult,
                -- Mensaje directo con " Multi"
                message = "+" .. number_format(card.ability.extra.mult) .. " Multi"
            }
        end

        if context.before and not context.blueprint then
            if #context.scoring_hand < 5 then
                card.ability.extra.mult = card.ability.extra.mult + 4
                return {
                    message = '¡Mejorado!',
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
    end
}

-- Joker canal
SMODS.Joker{
    key = 'fonikiki_canal',
    loc_txt = {
        name = '@fonikiki2679',
        text = {
            'Consigue {C:white,X:red}X1{} de multi por cada', 
            '{C:atention}año{} desde su {C:gold}primer video',
            '{C:inactive}(Actualmente {C:white,X:red}X#1#{C:inactive} de multi)'
        }
    },

    unlocked = true,
    discovered = true,
    atlas = 'Jokers1', 
    pos = {x = 0, y = 1}, 
    rarity = 3,
    cost = 8,
    blueprint_compat = true,
    config = {
        extra = {
            start_year = 2022,
            years_active = 1
        }
    },

    loc_vars = function(self, info_queue, card)
        local CURRENT_YEAR = tonumber(os.date("%Y"))
        local years_active = math.max(1, CURRENT_YEAR - self.config.extra.start_year)
        self.config.extra.years_active = years_active
        return { vars = { years_active } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local mult_value = self.config.extra.years_active
            return {
                ['x_mult'] = mult_value, 
                colour = G.C.RED,
                card = card
            }
        end
    end
}

--Me encantan las K (en especial las de pica)
SMODS.Joker{
    key = 'fonikiki_K',
    loc_txt = {
        name = '¿...K...?',
        text = {
            'Reactiva las {C:attention}K{} jugadas tantas',
            'veces como {C:attention}K{} haya en la mano.'
        }
    },

    unlocked = true,
    discovered = true,
    rarity = 3,
    atlas = 'Jokers1',
    pos = {x = 1, y = 2},
    cost = 8,
    blueprint_compat = true,

    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition and not context.repetition_only then
            local k_count = 0
            for _, played_card in ipairs(context.full_hand or {}) do 
                if played_card:get_id() == 13 then
                    k_count = k_count + 1
                end
            end
            if k_count > 0 and context.other_card and context.other_card:get_id() == 13 then
                return {
                    message = '¡Otra vez!', 
                    repetitions = k_count, 
                    card = context.other_card 
                }
            end
        end
    end
}

--Millonario
SMODS.Joker{
    key = 'fonikiki_millonario',
    loc_txt = {
        name = 'Millonario',
        text = {
            'Gana el {C:mult}#1#%{} de tu dinero',
            'al final de la ronda.',
            'Límite de {C:money}$#3#{}.',
            '{C:inactive}(Actualmente: {C:money}$#2#{C:inactive})',
        }
    },
    
    unlocked = true,
    discovered = true,
    atlas = 'Jokers1', 
    pos = {x=0, y=3},
    rarity = 3,
    cost = 10,
    blueprint_compat = false,
    config = { 
        extra = { 
            percent = 30,
            money_limit = 50,
        } 
    }, 

    loc_vars = function(self, info_queue, card)
        local current_dollars = G.GAME and G.GAME.dollars or 0
        local current_percent = card.ability.extra.percent
        local bonus_limit = card.ability.extra.money_limit
        local estimated_bonus = math.min(
            math.floor(0.01 * current_percent * current_dollars),
            bonus_limit
        )
        
        return {
            vars = { 
                number_format(current_percent),
                number_format(estimated_bonus),
                number_format(bonus_limit)
            }
        }
    end,
    
    calc_dollar_bonus = function(self, card)
        if not G.GAME or to_big(G.GAME.dollars) <= to_big(0) then
            return 0
        end
        
        local current_dollars = G.GAME.dollars
        local current_percent = card.ability.extra.percent
        local bonus_limit = card.ability.extra.money_limit
        local bonus_amount_raw = math.max(0, math.floor(0.01 * current_percent * (current_dollars or 1)))
        local bonus_amount = lenient_bignum(
            math.min(bonus_amount_raw, bonus_limit)
        )
        if to_big(bonus_amount) > to_big(0) then
            return bonus_amount
        else
            return 0
        end
    end,
}

--Error (Terminado en tiempo record, no esperaba que fuera tan fácil xd) PD: Añadir que pueda hacer mas cosas aparte del mult o las chips en proxima actualización PPD: Me da pereza ahora, lo dejo así y ya en una proxima proxima actualización lo hago
SMODS.Joker{
    key = 'fonikiki_error',
    loc_txt = {
        name = '{s:1.5}N I L{}',
        text = {
            '{s:1.3,C:mult}N {s:1.3,C:blue}A {s:1.3,C:attention}N {s:1.3,C:green}E',
        }
    },

    unlocked = true,
    discovered = true,
    atlas = 'Jokers1', 
    pos = { x = 2, y = 3 }, 
    rarity = 2, 
    cost = 8, 
    
    calculate = function(self, card, context)
        if context.joker_main then
            local chips_add = random_float(1, 130)
            local mult_add = random_float(1, 70)
            local X_chips_val = random_float(1, 1.4)
            local X_mult_val = random_float(1, 1.4)
            return {
                card = card,
                chip_mod = lenient_bignum(chips_add),
                mult_mod = lenient_bignum(mult_add),
                X_chip_mod = lenient_bignum(X_chips_val), 
                Xmult_mod = lenient_bignum(X_mult_val),   
                message = "ERROR", 
                colour = G.C.RED,
            }
        end
    end,
}

--ANDALUCIAAAA DONDE VIVO YO :DDDD (estoy enloqueciendo) JOKER
SMODS.Joker{ 
    key = "fonikiki_andalucia",
    loc_txt = {
        name = 'Andalucía', 
        text = {
            'Cuando se juega una mano de {C:attention}1{} carta,', 
            '{C:green}#1# en #2#{} probabilidades de crear un Joker.',
            '{C:inactive}(No se admiten jokers {C:legendary}legendarios{C:inactive})'
        }
    },

    unlocked = true,
    discovered = true,
    pos = { x = 0 , y = 4 },
    cost = 10,
    rarity = 3,
    blueprint_compat = false,
    atlas = 'Jokers1',
    config = {
        extra = {
            slots = 0,
            odds = 2,
            respect = 0
        }
    },
    
    loc_vars = function(self, info_queue, card)
        return { vars = { (G.GAME.probabilities.normal or 1), card.ability.extra.odds } } 
    end,
    
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            if #context.scoring_hand == 1 then
                -- Uso de pseudorandom y G.GAME.probabilities para compatibilidad con Oops! All 6s
                if pseudorandom('andalucia') < G.GAME.probabilities.normal / card.ability.extra.odds then
                    local created_joker = false
                    if #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
                        created_joker = true
                        G.GAME.joker_buffer = G.GAME.joker_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local joker_card = SMODS.add_card({ set = 'Joker' })
                                if joker_card then
                                end
                                G.GAME.joker_buffer = 0
                                return true
                            end
                        }))
                    end
                    return {
                        message = created_joker and localize('k_plus_joker') or nil
                    }
                end
            end
        end
    end
}

--¿Que cojones? joker
SMODS.Joker{
    key = 'fonikiki_que_cojones',
    loc_txt = {
        name = '¿Que cojones?',
        text = {
            '{C:green}pero que cojones',
            '{C:green}porque hay cuatro gatos',
            '{C:green}jugando al balatro en mi casa',
            '{C:green}pero que cojones tio',
            '{C:green}cuidado tio ese tiene doble pareja',
            ' ',
            'Cuando se descartan {C:attention}4{C:inactive} [#2#]{} cartas el multi aumenta',
            'en {C:mult}4{}. Aumenta en {C:mult}8{} cuando se juega {C:attention}doble pareja{}.',
            'Se restablece en cada ronda',
            '{C:inactive}(Actual: {C:mult}+#1#{C:inactive} Mult)',
        },
    },

    unlocked = true,
    discovered = true,
    atlas = 'que_cojones',
    pos = { x = 0, y = 0 },
    rarity = 2,
    cost = 8,
    blueprint_compat = true,
    config = { extra = { mult = 0, count = 0, threshold = 4, gain = 4, hand_gain = 8 } },

    loc_vars = function(self, info_queue, center)
        local faltan = (center.ability.extra.threshold or 4) - (center.ability.extra.count or 0)
        return { vars = { center.ability.extra.mult, faltan } }
    end,

    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            card.ability.extra.count = (card.ability.extra.count or 0) + 1
            if card.ability.extra.count >= (card.ability.extra.threshold or 4) then
                card.ability.extra.count = 0
                card.ability.extra.mult = card.ability.extra.mult + (card.ability.extra.gain or 4)
                return {
                    message = 'Miau',
                    colour = G.C.MULT
                }
            end
        end
        if context.before and context.scoring_name == "Two Pair" and not context.blueprint then
            local gain = card.ability.extra.hand_gain or 8
            card.ability.extra.mult = card.ability.extra.mult + gain
            return {
                message = 'Miau',
                colour = G.C.MULT
            }
        end
        if context.joker_main and card.ability.extra.mult > 0 then
            return {
                mult_mod = card.ability.extra.mult,
                message = '+' .. card.ability.extra.mult .. ' Mult'
            }
        end
        if context.end_of_round and not (context.individual or context.repetition or context.blueprint) then
            card.ability.extra.mult = 0
            card.ability.extra.count = 0
        end
    end
}

--goofy ahh joker
SMODS.Joker{
    key = 'fonikiki_balatrez',
    loc_txt = {
        name = 'Balatro Balatrez',
        text = {
            'Al final del {C:attention}Ante{}, añade {C:dark_edition}+1{} espacio de Joker',
            'por cada {C:money}#2#${} que tengas. El requisito',
            'aumenta en {C:money}25${} cada Ante.',
            '{C:inactive}(Espacios añadidos: {C:dark_edition}+#1#{C:inactive})'
        },
    },
    unlocked = true,
    discovered = true,
    atlas = 'balatro_balatrez',
    pos = { x = 0, y = 0 },
    display_size = { w = 71, h = 76 },
    rarity = 3,
    cost = 5,
    blueprint_compat = false,
    config = { extra = { added_slots = 0 } },

    loc_vars = function(self, info_queue, center)
        local ante_corregido = math.max(1, G.GAME.round_resets.ante)
        local current_req = 50 + (25 * (ante_corregido - 1))
        return { vars = { center.ability.extra.added_slots, current_req } }
    end,

    remove_from_deck = function(self, card, from_debuff)
        if card.ability.extra.added_slots > 0 then
            G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.added_slots
            card.ability.extra.added_slots = 0
        end
    end,

    calculate = function(self, card, context)
        if context.end_of_round and G.GAME.blind.boss and not context.game_over and not (context.individual or context.repetition or context.blueprint) then
            local ante_corregido = math.max(1, G.GAME.round_resets.ante)
            local current_req = 50 + (25 * (ante_corregido - 1))
            local dollars = G.GAME.dollars
            local slots_to_add = 0
            if type(dollars) == 'table' then
                slots_to_add = math.floor(to_number(dollars / current_req))
            else
                slots_to_add = math.floor(dollars / current_req)
            end
            if slots_to_add > 0 then
                card.ability.extra.added_slots = card.ability.extra.added_slots + slots_to_add
                G.jokers.config.card_limit = G.jokers.config.card_limit + slots_to_add
                return {
                    message = '+' .. slots_to_add .. ' Slots',
                    colour = G.C.DARK_EDITION
                }
            end
        end
    end
}

--Perro de mierda joker
SMODS.Joker{
    key = 'fonikiki_perro',
    loc_txt = {
        name = 'perro de mierda',
        text = {
            '{C:mult}+1{} Multi.',
            '{C:green}#1# en #2#{} probabilidades de',
            'obtener {X:black,C:red,s:2}^#3#{} de multi'
        },
    },

    unlocked = true,
    discovered = true,
    atlas = 'perro',
    pos = { x = 0, y = 0 },
    rarity = 1,
    cost = -1,
    blueprint_compat = true,
    config = { extra = { odds = 500, pow = 500 } },

    loc_vars = function(self, info_queue, card)
        return { 
            vars = { 
                (G.GAME.probabilities.normal or 1), 
                card.ability.extra.odds, 
                card.ability.extra.pow 
            } 
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            -- Verificación de probabilidad compatible con Oops! All 6s
            if pseudorandom('perro') < G.GAME.probabilities.normal / card.ability.extra.odds then
                return {
                    e_mult = card.ability.extra.pow
                }
            else
                -- Efecto base garantizado
                return {
                    mult_mod = 1,
                    message = '+1 Multi.',
                    colour = G.C.MULT
                }
            end
        end
    end
}

--Token fan joker (Idea de Lolguy)
SMODS.Joker{
    key = 'fonikiki_token_fan',
    loc_txt = {
        name = 'Token fan',
        text = {
            'Otorga {X:chips,C:white} X#2# {} fichas',
            'por cada carta de {C:attention}figura{}',
            'que se juegue en la mano'
        }
    },

    unlocked = true,
    discovered = true,
    atlas = 'Jokers1',
    pos = { x = 4 , y = 0 },
    soul_pos = {x = 4, y = 1},
    rarity = 4,
    cost = 20,
    blueprint_compat = true,
    config = {
        extra = {
            chips_X_mult = 2
        }
    },
    
    loc_vars = function(self, info_queue, card)
        local mult_value = (card.ability.extra and card.ability.extra.chips_X_mult) or self.config.extra.chips_X_mult
        return { vars = { 0, mult_value } } 
    end,

    calculate = function(self, card, context)
        local mult_value = self.config.extra.chips_X_mult
        if context.individual and context.cardarea == G.play then
            if context.other_card and context.other_card:is_face() then
                return {
                    card = card, 
                    Xchip_mod = mult_value, 
                    message = localize { type = 'variable', key = 'a_xchips', vars = { mult_value } },
                    colour = G.C.BLUE 
                }
            end
        end
    end
}

-- Fonikiki joker
SMODS.Joker{
    key = 'fonikiki_fonikiki',
    loc_txt = {
        name = '{C:edition,s:1.7}Fonikiki',
        text = {
            'Otorga {X:black,C:red,s:2}^#1#{} de multi',
            'por cada {C:blue,s:1.5}K{} jugada'
        }
    },

    unlocked = true,
    discovered = true,
    atlas = 'Jokers1',
    pos = {x = 4, y = 2},
    soul_pos = {x = 4, y = 3},
    rarity = 4,
    cost = 20,
    blueprint_compat = true,
    config = {
        extra = {
            power_value = 1.2
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra.power_value } }
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other_card = context.other_card
            if other_card and other_card.get_id then 
                if other_card:get_id() == 13 then
                    local power_value = self.config.extra.power_value
                    return {
                        ['e_mult'] = power_value, 
                        message = '^'..power_value..' Mult', 
                        colour = G.C.RED,
                        card = card
                    }
                end
            end
        end
    end
}

--Calvo
SMODS.Joker{
    key = 'fonikiki_calvo',
    loc_txt= {
        name = '{s:3,C:edition}EL CALVO',
        text = {
            "{s:1.5,C:dark_edition}La Culminación de la Sabiduría.{}",
            "{s:1.2}Un {C:spectral,s:1.2}Blueprint {C:legendary,s:1.2}legendario{s:1.2}, la forma final de la {C:gold,s:1.2}eficiencia{s:1.2}.",
            "{s:1.2}El precio de este {C:attention,s:1.2}gran conocimiento{s:1.2} fue la melena:",
            "{s:1.2}su pelo huyó para dar espacio al {C:tarot,s:1.2}cerebro{s:1.2}.",
            "­",
            "Este comodín consigue {C:attention}0.5{} reactivaciones por cada {C:joker}Joker{} que tengas.",
            "{C:inactive}(Actualmente {C:attention}#1#{C:inactive} reactivaciones){}"
        }
    },
    
    unlocked = true,
    discovered = true,
    atlas = 'Jokers1',
    pos = { x = 3, y = 3 },
    soul_pos = { x = 4, y = 4 },
    rarity = 4,
    cost = 20,
    blueprint_compat = false,
    config = { 
        extra = { 
            bonus_per_joker = 0.5,
        } 
    },

    loc_vars = function(self, info_queue, card)
        local total_jokers = (G.jokers and #G.jokers.cards) or 0
        local total_repetitions = total_jokers * self.config.extra.bonus_per_joker
        local display_value
        if total_repetitions == math.floor(total_repetitions) then
            display_value = string.format("%.0f", total_repetitions)
        else
            display_value = string.format("%.1f", total_repetitions)
        end
        
        return { 
            vars = { display_value }
        }
    end,
    
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition then
            local total_jokers = (G.jokers and #G.jokers.cards) or 0
            local total_repetitions = total_jokers * self.config.extra.bonus_per_joker
            return {
                message = localize("k_again_ex"),
                repetitions = total_repetitions, 
                card = context.other_card
            }
        end
    end,
}

--CONSUMIBLES
SMODS.Consumable{
    key = 'fonikiki_intercambio_palos',
    set = 'Tarot',
    loc_txt = {
        name = 'El Editor',
        text = {
            'Selecciona {C:attention}2{} cartas.',
            'Convierte el palo de la carta de la',
            '{C:attention}izquierda{} a el palo de la de la {C:attention}derecha{}',
            '{C:inactive}(Arrastra para acomodar)'
        }
    },

    atlas = 'Tarot',
    pos = { x = 2, y = 0 },
    cost = 3,
    config = { max_highlighted = 2 },

    can_use = function(self, card)
        return G.hand and #G.hand.highlighted == 2
    end,

    use = function(self, card, area, copier)
        local cards = {}
        for i=1, #G.hand.highlighted do 
            cards[i] = G.hand.highlighted[i] 
        end
        table.sort(cards, function (a, b) return a.T.x < b.T.x end)
        local card_izq = cards[1]
        local card_der = cards[2]
        local nuevo_palo = card_der.base.suit
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card_izq:flip()
                card_der:flip()
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        SMODS.change_base(card_izq, nuevo_palo, card_izq.base.value)
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.4,
                            func = function()
                                play_sound('tarot2', 1, 0.6)
                                card_izq:flip()
                                card_der:flip()
                                card_izq:juice_up(0.3, 0.5)
                                return true
                            end
                        }))
                        return true
                    end
                }))
                return true
            end
        }))
    end
}

--Spectral Dios
SMODS.Consumable{
    key = 'fonikiki_GOD',
    set = 'Spectral',
    loc_txt = {
        name = 'Dios',
        text = {
            'Crea un Joker {C:legendary}Legendario{}',
            'del mod {E:1,C:red}Fonikiki{}'
        }
    },
    cost = 20,
    atlas = 'Tarot', -- Asegúrate de que este atlas esté definido en tu mod
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 }, -- Posición del sprite del "alma"
    soul_set = 'Tarot', -- Permite aparecer en sobres de Tarot
    soul_rate = 0.03, -- Probabilidad de aparición (3%)
    can_repeat_soul = true, -- Puede aparecer aunque ya tengas uno
    hidden = true, -- Oculto en la colección hasta ser encontrado

    -- Verifica si hay espacio para el nuevo Joker
    can_use = function(self, card)
        return #G.jokers.cards < G.jokers.config.card_limit
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                local my_legendaries = {}
                for k, v in pairs(SMODS.Centers) do
                    if v.set == 'Joker' and (v.rarity == 'legendary' or v.rarity == 4) and string.find(k, 'fonikiki') then 
                        table.insert(my_legendaries, k)
                    end
                end
                local chosen_key = #my_legendaries > 0 and pseudorandom_element(my_legendaries, pseudoseed('fonikiki_god')) or 'j_canchalagua'
                local card = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen_key, 'sou')
                
                card:add_to_deck()
                G.jokers:emplace(card)
                card:start_materialize()
                return true
            end
        }))
    end
}


--BARAJAS
--Baraja Inversionista
SMODS.Back{
    key = 'fonikiki_inversionista',
    loc_txt = {
        name = 'Baraja inversionista',
        text = {
            'Inicias la partida con:',
            '{C:money}Capital inicial{},',
            '{C:gold}Árbol de dinero{},',
            'y {C:attention}Jeroglífico{}.',
            'Inicias con {C:money}$0{}'
        }
    },

    unlocked = true,
    atlas = 'Decks1',
    pos = { x = 0 , y = 0 },

    apply = function(self)
        G.GAME.starting_params.dollars = 0
        G.E_MANAGER:add_event(Event({
            func = function()
                local vouchers = {'v_seed_money', 'v_money_tree', 'v_hieroglyph'}
                for _, v in ipairs(vouchers) do
                    G.GAME.used_vouchers[v] = true
                    local card = Card(G.play.T.x, G.play.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS[v])
                    card:apply_to_run()
                    card:remove() 
                end
                return true
            end
        }))
    end
}

--baraja definitiva
SMODS.Back{
    key = 'fonikiki_definitiva',
    loc_txt = {
        name = 'Baraja definitiva',
        text = {
            'Inicias la partida con:',
            '{C:blue}1{} sola mano,',
            '{C:red}8{} descartes,',
            'y {C:money}30{} dolares'
        }
    },

    unlocked = true,
    atlas = 'Decks1',
    pos = { x = 1, y = 0 },

    apply = function(self)
        G.GAME.starting_params.hands = 1
        G.GAME.starting_params.discards = 8
        G.GAME.starting_params.dollars = 30
    end
}

--baraja dorada de farewell
SMODS.Back{
    key = 'fonikiki_baraja_fresa',
    loc_txt = {
        name = 'Baraja {C:gold}dorada{} de {C:dark_edition}Farewell{}',
        text = {
            'Inicias la partida con:',
            'La {C:gold}fresa dorada{} de {C:dark_edition}farewell{}',
            'y {C:attention}-1{} tamaño de mano'
        }
    },

    unlocked = true,
    atlas = 'Decks1',
    pos = { x = 2, y = 0 },
    
    apply = function(self)
        G.GAME.starting_params.hand_size = G.GAME.starting_params.hand_size - 1
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.jokers then
                    local card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_fonikiki_fresa_farewell", "fonikiki_baraja_fresa")
                    card:add_to_deck()
                    G.jokers:emplace(card)
                    return true
                end
            end
        }))
    end
}

--REWORKS
--Rework de nombre del The Hermit a "20 euros son 20 euros"
SMODS.current_mod.process_loc_text = function()
    G.localization.descriptions.Tarot.c_hermit.name = "20 euros son 20 euros"
end