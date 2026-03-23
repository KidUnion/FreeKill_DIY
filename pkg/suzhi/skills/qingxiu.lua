local qingxiu = fk.CreateSkill {
  name = "qingxiu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["qingxiu"] = "请休",
  [":qingxiu"] = "锁定技，结束阶段，你亮出牌堆顶X张牌并获得其中一张，直至你下回合开始，花色包含于剩余牌中的牌对你无效，若X为："..
    "3：你失去一点体力；"..
    "4：你翻面。"..
    "（X为你本回合弃置牌的花色数）",
  ["#qingxiu-prey"] = "请休：获得其中一张牌",
  
  ["$qingxiu"] = "请休",
  ["@qingxiu-turn"] = "弃置",
  ["@qingxiu-suit"] = "无效",
}

Fk:addPoxiMethod{
  name = "qingxiu",
  prompt = "#qingxiu-prey",
  card_filter = function(to_select, selected, data, extra_data)
    return #selected == 0
  end,
  feasible = function (selected, data, extra_data)
    return #selected == 1
  end,
}

qingxiu:addEffect(fk.EventPhaseStart, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qingxiu.name) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local suits = player:getTableMark("@qingxiu-turn")
    local x = #suits    
    if x > 0 then
      local top_cards = room:getNCards(x)
      local revealed_suits = {}
      room:moveCardTo(top_cards, Card.Processing)
      local cards = room:askToPoxi(player, {
          poxi_type = qingxiu.name,
          data = { { qingxiu.name, top_cards } },
          cancelable = false,
        })
      if #cards > 0 then
        room:obtainCard(player, cards, true, fk.ReasonPrey, player, qingxiu.name)
        table.removeOne(top_cards, cards[1])
      end
      for _, id in ipairs(top_cards) do
        local card = Fk:getCardById(id)
        if card.suit ~= Card.NoSuit then
          table.insertIfNeed(revealed_suits, card:getSuitString(true))
        end
      end
      room:setPlayerMark(player, "@qingxiu-suit", revealed_suits)
      local cardsInProcessing = table.filter(top_cards, function(id) 
        return room:getCardArea(id) == Card.Processing 
      end)
      if #cardsInProcessing > 0 then
        room:moveCardTo(cardsInProcessing, Card.DiscardPile)
      end
      if x == 3 then
        room:loseHp(player, 1, qingxiu.name)
      elseif x == 4 then
        player:turnOver()
      end
    end
  end,
})

qingxiu:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player.room:getCurrent() == player and player:hasSkill(qingxiu.name, true) then
      for _, move in ipairs(data) do
        if move.from == player and move.moveReason == fk.ReasonDiscard then
          return true
        end
      end
    end
    return false
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local record = player:getTableMark("@qingxiu-turn")
    for _, move in ipairs(data) do
      if move.from == player and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId)
          if card.suit ~= Card.NoSuit then
            table.insertIfNeed(record, card:getSuitString(true))
          end
        end
      end
    end
    room:setPlayerMark(player, "@qingxiu-turn", record)
  end,
})

qingxiu:addEffect(fk.TurnStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and #player:getTableMark("@qingxiu-suit") > 0
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@qingxiu-suit", 0)
  end,
})

qingxiu:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(qingxiu.name) and data.card and data.card.suit ~= Card.NoSuit then
      return table.contains(player:getTableMark("@qingxiu-suit"), data.card:getSuitString(true))
    end
    return false
  end,
  on_trigger = function(self, event, target, player, data)
    data.use.nullifiedTargets = data.use.nullifiedTargets or {}
    table.insertIfNeed(data.use.nullifiedTargets, player)
  end,
})

return qingxiu

-- local qingxiu = fk.CreateSkill {
--   name = "ty_ex__qingxiu",
--   tags = { Skill.Compulsory },
--   dynamic_desc = function (self, player)
--     if player:getMark("ty_ex__fuli") > 0 then
--       return "ty_ex__qingxiu_update"
--     end
--   end,
-- }

-- Fk:loadTranslationTable{
--   ["ty_ex__qingxiu"] = "当先",
--   [":ty_ex__qingxiu"] = "锁定技，回合开始时，你执行一个额外的出牌阶段，此阶段开始时你失去1点体力并从弃牌堆获得一张【杀】。",

--   [":ty_ex__qingxiu_update"] = "锁定技，回合开始时，你执行一个额外的出牌阶段，此阶段开始时，你可以失去1点体力并从弃牌堆获得一张【杀】。",

--   ["#ty_ex__qingxiu-invoke"] = "当先：你可以失去1点体力，从弃牌堆获得一张【杀】",

--   ["$ty_ex__qingxiu1"] = "竭诚当先，一举克定！",
--   ["$ty_ex__qingxiu2"] = "一马当先，奋勇杀敌！",
-- }

-- qingxiu:addEffect(fk.TurnStart, {
--   anim_type = "offensive",
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(qingxiu.name)
--   end,
--   on_use = function(self, event, target, player, data)
--     player:gainAnExtraPhase(Player.Play, qingxiu.name)
--   end,
-- })

-- qingxiu:addEffect(fk.EventPhaseStart, {
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(qingxiu.name) and player.phase == Player.Play and
--       data.reason == qingxiu.name
--   end,
--   on_cost = function (self, event, target, player, data)
--     if player:getMark("ty_ex__fuli") == 0 then
--       return true
--     else
--       return player.room:askToSkillInvoke(player, {
--         skill_name = qingxiu.name,
--         prompt = "#ty_ex__qingxiu-invoke",
--       })
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:loseHp(player, 1, qingxiu.name)
--     if not player.dead then
--       local cards = room:getCardsFromPileByRule("slash", 1, "discardPile")
--       if #cards > 0 then
--         room:obtainCard(player, cards, true, fk.ReasonJustMove, player, qingxiu.name)
--       end
--     end
--   end,
-- })

-- qingxiu:addLoseEffect(function (self, player, is_death)
--   player.room:setPlayerMark(player, "ty_ex__fuli", 0)
-- end)

-- return qingxiu

-- local qingxiu = fk.CreateActiveSkill{
--   name = "qingxiu",
--   prompt = "#qingxiu-active",
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
--     room:addPlayerMark(player, "qingxiu-turn", 1)
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
-- local qingxiu_targetmod = fk.CreateTargetModSkill{
--   name = "#qingxiu_targetmod",
--   bypass_times = function(self, player, skill, scope, card)
--     return card and player:hasSkill(qingxiu) and player:getMark("qingxiu-turn") > 0
--   end,
--   bypass_distances = function(self, player, skill, card)
--     return card and player:hasSkill(qingxiu) and player:getMark("qingxiu-turn") > 0
--   end,
-- }
-- local qingxiu_trigger = fk.CreateTriggerSkill{
--   name = "#qingxiu_trigger",
--   mute = true,
--   events = {fk.AfterCardUseDeclared},
--   can_trigger = function(self, event, target, player, data)
--     return player == target and player:hasSkill(qingxiu) and player:getMark("qingxiu-turn") > 0
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
--       card.skillName = "qingxiu"
--       card.suit = Card.NoSuit
--       card.color = Card.NoColor
--       data.card = card
--     end
--     local room = player.room
--     room:setPlayerMark(player, "qingxiu-turn", 0)
--   end,
-- }