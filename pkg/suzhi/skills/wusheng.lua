local wusheng = fk.CreateSkill {
  name = "suzhi__wusheng",
}

Fk:loadTranslationTable{
  ["suzhi__wusheng"] = "舞圣",
  [":suzhi__wusheng"] = "当你于回合内首次使用一种牌名字数的牌时，你可将手牌摸/弃至此牌牌名字数并与一名其他角色各弃/摸一张牌，"..
  "本回合你使用牌可指定其为额外目标且其不可响应。",
  ["#suzhi__wusheng-discard"] = "舞圣：你可弃置%arg张牌并与一名其他角色各摸一张牌",
  ["#suzhi__wusheng-draw"] = "舞圣：你可摸%arg张牌并与一名其他角色各弃一张牌",
  ["#suzhi__wusheng-discard1"] = "舞圣：请弃置一张牌",
  ["#suzhi__wusheng-choose"] = "舞圣：你可以为%arg额外指定目标",
  
  ["$suzhi__wusheng"] = "舞圣",
  ["@suzhi__wusheng-turn"] = "舞圣",
  ["@@suzhi__wusheng-turn"] = "舞圣",
}

wusheng:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(wusheng.name, true) 
      or player.room.current ~= player then return end
    local n = Fk:translate(data.card.trueName, "zh_CN"):len()
    if table.contains(player:getTableMark("@suzhi__wusheng-turn"), n) then return false end
    player.room:addTableMark(player, "@suzhi__wusheng-turn", n)
    return player:getHandcardNum() ~= n
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n = Fk:translate(data.card.trueName, "zh_CN"):len()
    local num = math.max(0, player:getHandcardNum() - n)
    local abs = math.abs(player:getHandcardNum() - n)
    local to, card =  room:askToChooseCardsAndPlayers(player, {
      min_card_num = num,
      max_card_num = num,
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player),
      prompt = num > 0 and "#suzhi__wusheng-discard:::"..abs or "#suzhi__wusheng-draw:::"..abs,
      pattern = num > 0 and ".|.|.|hand" or ".",
      skill_name = wusheng.name,
      will_throw = true,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {
        to = to[1],
        cards = card,
        n = abs,
      })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost = event:getCostData(self)
    if #cost.cards > 0 then
      room:throwCard(cost.cards, wusheng.name, player, player)
      if not player.dead then
        room:drawCards(player, 1, wusheng.name)
      end
      if not cost.to.dead then
        room:drawCards(cost.to, 1, wusheng.name)
        room:addPlayerMark(cost.to, "@@suzhi__wusheng-turn")
      end
    else
      room:drawCards(player, cost.n, wusheng.name)
      if not player.dead then
        room:askToDiscard(player, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = wusheng.name,
          cancelable = false,
          prompt = "#suzhi__wusheng-discard1",
          skip = false
        })
      end
      if not cost.to.dead then
        room:askToDiscard(cost.to, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = wusheng.name,
          cancelable = false,
          prompt = "#suzhi__wusheng-discard1",
          skip = false
        })
        room:addPlayerMark(cost.to, "@@suzhi__wusheng-turn")
      end
    end
  end,
})

wusheng:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wusheng.name) 
      and (data.card.type == Card.TypeBasic or data.card:isCommonTrick())
      and table.find(data:getExtraTargets(), function (p)
        return p:getMark("@@suzhi__wusheng-turn") > 0
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(data:getExtraTargets(), function (p)
      return p:getMark("@@suzhi__wusheng-turn") > 0
    end)
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = #targets,
      prompt = "#suzhi__wusheng-choose:::" .. data.card:toLogString(),
      skill_name = wusheng.name,
      cancelable = true,
    })
    if #tos > 0 then
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local tos = event:getCostData(self).tos
    data.disresponsiveList = data.disresponsiveList or {}
    for _, p in ipairs(tos) do
      data:addTarget(p)
      table.insertIfNeed(data.disresponsiveList, p)
    end
  end,
})

return wusheng

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

-- local wusheng = fk.CreateTriggerSkill{
--   name = "wusheng",
--   mute = true,
--   events = {},

--   refresh_events = {fk.CardUsing},
--   can_refresh = function (self, event, target, player, data)
--     return player == target and player:hasSkill(self, true) and data.card.suit ~= Card.NoSuit
--     and not table.contains(player:getTableMark("@wusheng-turn"), data.card:getSuitString(true))
--   end,
--   on_refresh = function (self, event, target, player, data)
--     player.room:addTableMark(player, "@wusheng-turn", data.card:getSuitString(true))
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
--     room:setPlayerMark(player, "@wusheng-turn", #mark > 0 and mark or 0)
--   end,
-- }
-- local wusheng_maxcards = fk.CreateMaxCardsSkill{
--   name = "#wusheng_maxcards",
--   fixed_func = function(self, player)
--     if player:hasSkill(wusheng) then
--       return (5 - #player:getTableMark("@wusheng-turn"))
--     end
--   end,
-- }