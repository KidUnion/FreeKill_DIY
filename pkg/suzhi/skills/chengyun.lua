local chengyun = fk.CreateSkill {
  name = "chengyun",
  tags = { Skill.Switch, Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["chengyun"] = "成韵",
  [":chengyun"] = "转换技，锁定技，当有角色于其回合内使用与上一张牌押韵的牌时，阴/阳：你交给/获得其一张牌，你/其摸一张牌。",
  ["#chengyun-give"] = "成韵：你可交给 %dest 一张牌",
  ["#chengyun-prey"] = "成韵：你可获得 %dest 一张牌",

  ["$chengyun"] = "成韵",
}

local chengyun_pairs = {
  --a ia ua：杀，万箭齐发，藤甲，木牛流马，兵临城下，桐油百韧甲，烂银甲，商鞅变法，奇门八卦
  a = {
    "slash",
    "archery_attack",
    "vine",
    "wooden_ox",
    "enemy_at_the_gates",
    "ex_vine",
    "glittery_armor",
    "shangyang_reform",
    "mystical_diagram",
  },

  --o e uo：衠钢槊，三略，霹雳车，大攻车，连弩战车，望梅止渴
  e = {
    "steel_lance",
    "three_strategies",
    "catapult",
    "siege_engine",
    "offensive_siege_engine",
    "defensive_siege_engine",
    "wd_crossbow_tank",
    "wd_stop_thirst"
  },

  --ie ve：趁火打劫
  ie = {
    "looting"
  },

  --ai uai：黑光铠，瞒天过海，玲珑狮蛮带
  ai = {
    "dark_armor",
    "underhanding",
    "lion_belt",
  },

  --ei ui：调剂盐梅，以半击倍，浮雷，照月狮子盔，养精蓄锐
  ei = {
    "redistribute",
    "defeating_the_double",
    "floating_thunder",
    "ex_silver_lion",
    "wd_save_energy",
  },

  --ao iao：桃，青龙偃月刀，丈八蛇矛，过河拆桥，古锭刀，笑里藏刀，七宝刀，金蝉脱壳，增兵减灶，以逸待劳，三尖两刃刀，鬼龙斩月刀，红棉百花袍，
  --国风玉袍，烈淬刀，七星刀
  ao = {
    "peach",
    "blade",
    "spear",
    "dismantlement",
    "guding_blade",
    "daggar_in_smile",
    "seven_stars_sword",
    "crafty_escape",
    "reinforcement",
    "await_exhausted",
    "triblade",
    "ghost_dragon_blade",
    "red_robe",
    "sage_cloak",
    "quenched_blade",
    "wd_seven_stars_sword",
  },

  --ou iu：无中生有，决斗，骅骝，酒，走
  ou = {
    "ex_nihilo",
    "duel",
    "huailiu",
    "analeptic",
    "wd_run",
  },

  --an ian uan van：闪，闪电，青釭剑，雌雄双股剑，寒冰剑，爪黄飞电，大宛，兵粮寸断，朱雀羽扇，铁索连环，乌铁锁链，五行鹤翎扇，逐近弃远，
  --砖，吴六剑，真龙长剑，束发紫金冠，虚妄之冕，思召剑，水波剑，玄剑
  an = {
    "jink",
    "lightning",
    "qinggang_sword",
    "double_swords",
    "ice_sword",
    "zhuahuangfeidian",
    "dayuan",
    "supply_shortage",
    "fan",
    "iron_chain",
    "black_chain",
    "five_elements_fan",
    "chasing_near",
    "n_brick",
    "six_swords",
    "qin_dragon_sword",
    "golden_coronet",
    "illusory_coronet",
    "sizhao_sword",
    "water_sword",
    "xuanjian_sword",
  },

  --en in un vn：借刀杀人，南蛮入侵，八卦阵，仁王盾，水淹七军，先天八卦阵，仁王金刚盾，天雷刃，太极拂尘，金
  en = {
    "collateral",
    "savage_assault",
    "eight_diagram",
    "nioh_shield",
    "drowning",
    "horsetail_whisk",
    "ex_eight_diagram",
    "ex_nioh_shield",
    "thunder_blade",
    "wd_drowning",
    "wd_gold",
  },

  --ang iang uang：顺手牵羊，李代桃僵，银月枪，红缎枪，粮
  ang = {
    "snatch",
    "substituting",
    "moon_spear",
    "red_spear",
    "wd_rice",
  },

  --eng ing ong ung：五谷丰登，麒麟弓，绝影，紫骍，火攻，护心镜，奇正相生，弃甲曳兵，草木皆兵，远交近攻，赤血青锋，照骨镜，欲擒故纵
  eng = {
    "amazing_grace",
    "kylin_bow",
    "jueying",
    "zixing",
    "fire_attack",
    "breastplate",
    "raid_and_frontal_attack",
    "abandoning_armor",
    "paranoid",
    "befriend_attacking",
    "blood_sword",
    "bone_mirror",
    "wd_breastplate",
    "wd_let_off_enemy",
  },

  --i er v：桃园结义，无懈可击，方天画戟，白银狮子，出其不意，洞烛先机，美人计，传国玉玺，违害就利，声东击西，斗转星移，知己知彼，
  --无双方天戟，镔铁双戟，混毒弯匕，日月戟
  i = {
    "god_salvation",
    "nullification",
    "halberd",
    "silver_lion",
    "unexpectation",
    "foresight",
    "honey_trap",
    "qin_seal",
    "avoiding_disadvantages",
    "diversion",
    "time_flying",
    "known_both",
    "matchless_halberd",
    "iron_double_halberd",
    "poisonous_dagger",
    "wd_sun_moon_halberd",
  },

  --u：乐不思蜀，诸葛连弩，贯石斧，赤兔，的卢，天机图，太公阴符，毒，偷梁换柱，推心置腹，文和乱武，连弩，悦刻五，太平要术，
  --四乘粮舆，铁蒺玄舆，飞轮战舆，金梳，琼梳，犀梳，秦弩，元戎精械弩，灵宝仙葫，冲应神符，白鹄，诱敌深入
  u = {
    "indulgence",
    "crossbow",
    "axe",
    "chitu",
    "dilu",
    "wonder_map",
    "taigong_tactics",
    "poison",
    "replace_with_a_fake",
    "sincere_treat",
    "wenhe_chaos",
    "xbow",
    "n_relx_v",
    "peace_spell",
    "grain_cart",
    "caltrop_cart",
    "wheel_cart",
    "golden_comb",
    "jade_comb",
    "rhino_comb",
    "qin_crossbow",
    "ex_crossbow",
    "celestial_calabash",
    "talisman",
    "wd_baihu",
    "wd_lure_in_deep",
  },
}

chengyun:addEffect(fk.CardUsing, {
  anim_type = "switch",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(chengyun.name) then
      local name = ""
      player.room.logic:getEventsByRule(GameEvent.UseCard, 1, function (e)
        if e.id < player.room.logic:getCurrentEvent().id then
          name = e.data.card.trueName
          return true
        end
      end, 0, Player.HistoryGame)
      if name then
        for _, v in pairs(chengyun_pairs) do
          if table.contains(v, name) then
            return table.contains(v, data.card.trueName)
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getSwitchSkillState(chengyun.name, true) == fk.SwitchYang then
      local card = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = chengyun.name,
        prompt = "#chengyun-give::"..target.id,
        cancelable = false,
      })
      if #card > 0 then
        room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonGive, chengyun.name, nil, false, player)
        if not player.dead then
          room:drawCards(player, 1, chengyun.name)
        end
      end
    else
      local card = room:askToChooseCard(player, {
        target = target,
        flag = "he",
        skill_name = chengyun.name,
        prompt = "#chengyun-prey::"..target.id,
      })
      if #card > 0 then
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, chengyun.name, nil, false, player)
        if not target.dead then
          room:drawCards(target, 1, chengyun.name)
        end
      end
    end
  end,
})

return chengyun

-- local dangxian = fk.CreateSkill {
--   name = "ty_ex__dangxian",
--   tags = { Skill.Compulsory },
--   dynamic_desc = function (self, player)
--     if player:getMark("ty_ex__fuli") > 0 then
--       return "ty_ex__dangxian_update"
--     end
--   end,
-- }

-- Fk:loadTranslationTable{
--   ["ty_ex__dangxian"] = "当先",
--   [":ty_ex__dangxian"] = "锁定技，回合开始时，你执行一个额外的出牌阶段，此阶段开始时你失去1点体力并从弃牌堆获得一张【杀】。",

--   [":ty_ex__dangxian_update"] = "锁定技，回合开始时，你执行一个额外的出牌阶段，此阶段开始时，你可以失去1点体力并从弃牌堆获得一张【杀】。",

--   ["#ty_ex__dangxian-invoke"] = "当先：你可以失去1点体力，从弃牌堆获得一张【杀】",

--   ["$ty_ex__dangxian1"] = "竭诚当先，一举克定！",
--   ["$ty_ex__dangxian2"] = "一马当先，奋勇杀敌！",
-- }

-- dangxian:addEffect(fk.TurnStart, {
--   anim_type = "offensive",
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(dangxian.name)
--   end,
--   on_use = function(self, event, target, player, data)
--     player:gainAnExtraPhase(Player.Play, dangxian.name)
--   end,
-- })

-- dangxian:addEffect(fk.EventPhaseStart, {
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(dangxian.name) and player.phase == Player.Play and
--       data.reason == dangxian.name
--   end,
--   on_cost = function (self, event, target, player, data)
--     if player:getMark("ty_ex__fuli") == 0 then
--       return true
--     else
--       return player.room:askToSkillInvoke(player, {
--         skill_name = dangxian.name,
--         prompt = "#ty_ex__dangxian-invoke",
--       })
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:loseHp(player, 1, dangxian.name)
--     if not player.dead then
--       local cards = room:getCardsFromPileByRule("slash", 1, "discardPile")
--       if #cards > 0 then
--         room:obtainCard(player, cards, true, fk.ReasonJustMove, player, dangxian.name)
--       end
--     end
--   end,
-- })

-- dangxian:addLoseEffect(function (self, player, is_death)
--   player.room:setPlayerMark(player, "ty_ex__fuli", 0)
-- end)

-- return dangxian

-- local chengyun = fk.CreateActiveSkill{
--   name = "chengyun",
--   prompt = "#chengyun-active",
--   anim_type = "drawcard",
--   can_use = function(self, player)
--     return player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryRound) == 0 
--       and #player:getCardIds(Player.Hand) > 0
--   end,
--   card_filter = Util.FalseFunc,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     local show_cards = player:getCardIds(Player.Hand)
--     player:showCards(show_cards)
--     room:addPlayerMark(player, "chengyun-turn", 1)
--     local cards_suits = {}
--     for _, id in ipairs(show_cards) do
--       local card = Fk:getCardById(id)
--       if not table.contains(cards_suits, card.suit) then
--         table.insert(cards_suits, card.suit)
--       end
--     end
--     local top_cards = room:getNCards(5)
--     room:moveCardTo(top_cards, Card.Processing)
--     room:delay(500)
--     local match = {}
--     for _, id in ipairs(top_cards) do
--       local card = Fk:getCardById(id)
--       if not table.contains(cards_suits, card.suit) then
--         table.insert(match, card)
--       end
--     end
--     room:moveCardTo(match, Player.Hand, player, fk.ReasonPrey, self.name)
--     local cardsInProcessing = table.filter(top_cards, function(id) return room:getCardArea(id) == Card.Processing end)
--     if #cardsInProcessing > 0 then
--       room:moveCardTo(cardsInProcessing, Card.DiscardPile)
--     end
--   end,
-- }
-- local chengyun_targetmod = fk.CreateTargetModSkill{
--   name = "#chengyun_targetmod",
--   bypass_times = function(self, player, skill, scope, card)
--     return card and player:hasSkill(chengyun) and player:getMark("chengyun-turn") > 0
--   end,
--   bypass_distances = function(self, player, skill, card)
--     return card and player:hasSkill(chengyun) and player:getMark("chengyun-turn") > 0
--   end,
-- }
-- local chengyun_trigger = fk.CreateTriggerSkill{
--   name = "#chengyun_trigger",
--   mute = true,
--   events = {fk.AfterCardUseDeclared},
--   can_trigger = function(self, event, target, player, data)
--     return player == target and player:hasSkill(chengyun) and player:getMark("chengyun-turn") > 0
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     if not (data.card:isVirtual() and #data.card.subcards == 0) then
--       local card = Fk:cloneCard(data.card.name, data.card.suit, data.card.number)
--       for k, v in pairs(data.card) do
--         if card[k] == nil then
--           card[k] = v
--         end
--       end
--       if data.card:isVirtual() then
--         card.subcards = data.card.subcards
--       else
--         card.id = data.card.id
--       end
--       card.skillNames = data.card.skillNames
--       card.skillName = "chengyun"
--       card.suit = Card.NoSuit
--       card.color = Card.NoColor
--       data.card = card
--     end
--     local room = player.room
--     room:setPlayerMark(player, "chengyun-turn", 0)
--   end,
-- }