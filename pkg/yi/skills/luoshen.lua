local luoshen = fk.CreateSkill {
  name = "yi__luoshen",
}

Fk:loadTranslationTable{
  ["yi__luoshen"] = "洛神",
  [":yi__luoshen"] = "当你/其他角色使用黑色牌时，你/其与其他角色/你的距离-1/+1直至回合结束，若有角色因此进入或离开了一名角色的攻击范围，你可弃置其中一名角色一张牌。",
  ["@yi__luoshen_off-turn"] = "洛神 -",
  ["@yi__luoshen_def-turn"] = "洛神 +",
  ["#yi__luoshen-discard"] = "洛神：你可以弃置其中一名角色的一张牌",

  ["$yi__luoshen1"] = "凌波微步，罗袜生尘。",
  ["$yi__luoshen2"] = "体迅飞凫，飘忽若神。",
}

luoshen:addEffect(fk.CardUsing, {
  anim_type = "control",
  
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(luoshen.name) and data.card.color == Card.Black
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local in_my_attack_range = table.filter(room:getOtherPlayers(player), function (p)
      return player:inMyAttackRange(p)
    end)
    local in_others_attack_range = table.filter(room:getOtherPlayers(player), function (p)
      return p:inMyAttackRange(player)
    end)
    if target == player then
      room:addPlayerMark(player, "@yi__luoshen_off-turn", 1)
    else
      room:addPlayerMark(player, "@yi__luoshen_def-turn", 1)
    end
    local can_discard = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if player:inMyAttackRange(p) and not table.contains(in_my_attack_range, p) then
        table.insertIfNeed(can_discard, p)
      end
      if not p:inMyAttackRange(player) and table.contains(in_others_attack_range, p) then
        table.insertIfNeed(can_discard, player)
      end
    end
    if #can_discard == 0 then return end
    local to_discard = room:askToChoosePlayers(player, {
      skill_name = luoshen.name,
      min_num = 1,
      max_num = 1,
      targets = can_discard,
      prompt = "#yi__luoshen-discard",
      cancelable = true,
    })
    if #to_discard > 0 then
      local id = room:askToChooseCard(player, {
          target = to_discard[1],
          flag = "he",
          skill_name = luoshen.name,
        })
      room:throwCard(id, luoshen.name, to_discard[1], player)
    end
  end,
})

luoshen:addEffect("distance", {
  correct_func = function(self, from, to)
    return to:getMark("@yi__luoshen_def-turn") - from:getMark("@yi__luoshen_off-turn")
  end,
})

return luoshen

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

-- local luoshen = fk.CreateActiveSkill{
--   name = "luoshen",
--   prompt = "#luoshen-active",
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
--     room:addPlayerMark(player, "luoshen-turn", 1)
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
-- local luoshen_targetmod = fk.CreateTargetModSkill{
--   name = "#luoshen_targetmod",
--   bypass_times = function(self, player, skill, scope, card)
--     return card and player:hasSkill(luoshen) and player:getMark("luoshen-turn") > 0
--   end,
--   bypass_distances = function(self, player, skill, card)
--     return card and player:hasSkill(luoshen) and player:getMark("luoshen-turn") > 0
--   end,
-- }
-- local luoshen_trigger = fk.CreateTriggerSkill{
--   name = "#luoshen_trigger",
--   mute = true,
--   events = {fk.AfterCardUseDeclared},
--   can_trigger = function(self, event, target, player, data)
--     return player == target and player:hasSkill(luoshen) and player:getMark("luoshen-turn") > 0
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
--       card.skillName = "luoshen"
--       card.suit = Card.NoSuit
--       card.color = Card.NoColor
--       data.card = card
--     end
--     local room = player.room
--     room:setPlayerMark(player, "luoshen-turn", 0)
--   end,
-- }