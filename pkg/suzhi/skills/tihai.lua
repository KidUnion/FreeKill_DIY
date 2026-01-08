local tihai = fk.CreateSkill {
  name = "tihai",
  frequency = Skill.Compulsory,
}

Fk:loadTranslationTable{
  ["tihai"] = "题海",
  [":tihai"] = "锁定技，当你于回合内使用牌时，若此牌花色未被记录，你记录之；否则你从牌堆中获得一张花色未被记录的牌。 \r\n"..
  "结束阶段，你亮出牌堆顶等同于记录花色数的牌并可使用其中任意张牌名字数各不相同的牌，然后移除所有记录；若你此阶段未造成过伤害，下次亮出的牌数加一。",

  ["$tihai"] = "题海",
  ["@tihai-turn"] = "题海",
  ["@@tihai-plus"] = "题海+1",
  ["#tihai-use"] = "题海：你可使用其中任意张牌名字数各不相同的牌",
}

tihai:addEffect(fk.EventPhaseStart,{
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tihai.name) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local num = #player:getTableMark("@tihai-turn") + player:getMark("@@tihai-plus")
    local room = player.room
    room:setPlayerMark(player, "@@tihai-plus", 1)
    if num > 0 then
      local top_cards = room:getNCards(num)
      room:moveCardTo(top_cards, Card.Processing)
      local to_use = {}
      while not player.dead do
        to_use = table.filter(top_cards, function (id)
          local card = Fk:getCardById(id)
          return room:getCardArea(id) == Card.Processing and player:canUse(card) and not player:prohibitUse(card)
        end)
        if #to_use == 0 then break end
        local use = room:askToUseRealCard(player, {
          pattern = to_use,
          skill_name = tihai.name,
          prompt = "#tihai-use",
          extra_data = {
            bypass_times = true,
            extraUse = true,
            expand_pile = to_use,
          },
          skip = true,
        })
        if use then
          table.removeOne(top_cards, use.card:getEffectiveId())
          room:useCard(use)
          local n = Fk:translate(use.card.trueName, "zh_CN"):len()
          top_cards = table.filter(top_cards, function (id)
            local card = Fk:getCardById(id)
            return room:getCardArea(id) == Card.Processing and Fk:translate(card.trueName, "zh_CN"):len() ~= n
          end)
        else
          break
        end
      end
      local cardsInProcessing = table.filter(top_cards, function(id) return room:getCardArea(id) == Card.Processing end)
      if #cardsInProcessing > 0 then
        room:moveCardTo(cardsInProcessing, Card.DiscardPile)
      end
    end
  end,
})
tihai:addEffect(fk.CardUsing, {
  can_trigger = function (self, event, target, player, data)
    return player == target and player:hasSkill(self, true) and 
    data.card.suit ~= Card.NoSuit and player.room.current == player
  end,
  on_trigger = function (self, event, target, player, data)
    local record = player:getTableMark("@tihai-turn")
    local room = player.room
    if table.contains(record, data.card:getSuitString(true)) then
      local pattern = ".|.|^("
      local flag = 0
      local suits = {"spade", "heart", "club", "diamond"}
      for _, suit in ipairs(suits) do
        if table.contains(record, "log_"..suit) then
          if flag == 1 then
            pattern = pattern..","
          else
            flag = 1
          end
          pattern = pattern..suit
        end
      end
      local cards = room:getCardsFromPileByRule(pattern..")", 1)
      if #cards > 0 then
        room:obtainCard(player, cards[1], false, fk.ReasonJustMove, player.id, self.name)
      end
    else 
      room:addTableMark(player, "@tihai-turn", data.card:getSuitString(true))
    end
  end,
})

tihai:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(tihai.name) and target == player and player.phase == Player.Finish
  end,
  on_trigger = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@tihai-plus", 0)
  end
})

return tihai

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

-- local tihai = fk.CreateTriggerSkill{
--   name = "tihai",
--   mute = true,
--   events = {},

--   refresh_events = {fk.CardUsing},
--   can_refresh = function (self, event, target, player, data)
--     return player == target and player:hasSkill(self, true) and data.card.suit ~= Card.NoSuit
--     and not table.contains(player:getTableMark("@tihai-turn"), data.card:getSuitString(true))
--   end,
--   on_refresh = function (self, event, target, player, data)
--     player.room:addTableMark(player, "@tihai-turn", data.card:getSuitString(true))
--   end,

--   on_acquire = function (self, player, is_start)
--     local room = player.room
--     if player ~= player.room.current then return end
--     local mark = {}
--     room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e)
--       local use = e.data[1]
--       if use.from == player.id and use.card.suit ~= Card.NoSuit then
--         table.insertIfNeed(mark, use.card:getSuitString(true))
--       end
--     end, Player.HistoryTurn)
--     room:setPlayerMark(player, "@tihai-turn", #mark > 0 and mark or 0)
--   end,
-- }
-- local tihai_maxcards = fk.CreateMaxCardsSkill{
--   name = "#tihai_maxcards",
--   fixed_func = function(self, player)
--     if player:hasSkill(tihai) then
--       return (5 - #player:getTableMark("@tihai-turn"))
--     end
--   end,
-- }