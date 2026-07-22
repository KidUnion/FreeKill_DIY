local duoduan = fk.CreateSkill {
  name = "duoduan",
}

Fk:loadTranslationTable{
  ["duoduan"] = "多断",
  [":duoduan"] = "出牌阶段每名其他角色限一次，当你使用即时牌指定首个目标后，可令一名非目标角色展示并交给你一张牌，"..
  "若为黑，你弃本阶段此项发动次数张牌，此牌额外结算一次；红，其于回合结束后交给你一张牌并获得此牌，此牌无效且不计次数。",

  ["#duoduan-invoke"] = "多断：你可令一名非目标角色交给你一张牌",
  ["#duoduan-choose"] = "多断：交给 %dest 一张牌",
  ["#duoduan_discard"] = "多断：请弃置 %arg 张牌",
  ["@$duoduan_draw-turn"] = "多断"
}

duoduan:addEffect(fk.TargetSpecified, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(duoduan.name) and player.phase == Player.Play
      and data.firstTarget and (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) then
      return #table.filter(player.room.alive_players, function (p)
        return p ~= player and not table.contains(data:getAllTargets(), p)
          and not p:isNude() and p:getMark("duoduan-turn") == 0
      end) > 0
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p ~= player and not table.contains(data:getAllTargets(), p) 
        and not p:isNude() and p:getMark("duoduan-turn") == 0
    end)
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      skill_name = duoduan.name,
      prompt = "#duoduan-invoke",
      cancelable = true,
    })
    if tos and #tos > 0 then
      event:setCostData(self, {to = tos[1]})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).to
    local card = room:askToChooseCard(to, {
      target = to,
      flag = "he",
      skill_name = duoduan.name,
      prompt = "#duoduan-choose::" .. player.id
    })
    room:setPlayerMark(to, "duoduan-turn", 1)
    if not card then return end
    room:showCards(card, to, to)
    room:obtainCard(player, card, true, fk.ReasonPrey, player, duoduan.name)
    if Fk:getCardById(card, false):getColorString() == "red" then
      room:addTableMark(player, "duoduan-draw-turn", to.id)
      room:addTableMark(to, "@$duoduan_draw-turn", data.card.id)
      data.use.toCard = nil
      data.use:removeAllTargets()
      player:addCardUseHistory(data.card.trueName, -1)
    elseif Fk:getCardById(card, false):getColorString() == "black" then
      player:addMark("duoduan-discard-turn", 1)
      local num = player:getMark("duoduan-discard-turn")
      room:askToDiscard(player, {
        min_num = num,
        max_num = num,
        include_equip = true,
        skill_name = duoduan.name,
        prompt = "#duoduan_discard:::" .. num,
        cancelable = false
      })
      data.use.additionalEffect = (data.use.additionalEffect or 0) + 1
    end
  end,
})

duoduan:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(duoduan.name) and #player:getTableMark("duoduan-draw-turn") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = player:getTableMark("duoduan-draw-turn") or {}
    for _, p in ipairs(targets) do
      local target = room:getPlayerById(p)
      if not target.dead then
        local card = room:askToChooseCard(target, {
          target = target,
          flag = "he",
          skill_name = duoduan.name,
          prompt = "#duoduan-choose::" .. player.id,
          cancelable = false
        })
        if not card then return end
        room:obtainCard(player, card, false, fk.ReasonPrey, target, duoduan.name)
        room:obtainCard(target, target:getTableMark("@$duoduan_draw-turn"), false, fk.ReasonPrey, target, duoduan.name)
      end
    end
  end,
})

return duoduan

-- local zhaxiang = fk.CreateTriggerSkill{
--   name = "zhaxiang",
--   anim_type = "drawcard",
--   prompt = "#zhaxiang",
--   events = {fk.HpLost},
--   on_trigger = function(self, event, target, player, data)
--     for i = 1, data.num do
--       if i > 1 and not player:hasSkill(self) then break end
--       self:doCost(event, target, player, data)
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local cards = player:drawCards(3, self.name)
--     local visible = {}
--     for _, id in ipairs(cards) do
--       local card = Fk:getCardById(id)
--       if(not card.is_damage_card) then
--         room:setCardMark(card, "@@visible", 1)
--         table.insert(visible, id)
--       else 
--         room:setCardMark(card, "@@zhaxiang_damage", 1)
--       end
--     end
--     player:showCards(visible)
--   end,
-- }
-- local zhaxiang_delay = fk.CreateTriggerSkill{
--   name = "#zhaxiang_delay",
--   refresh_events = {fk.PreCardUse},
--   can_refresh = function(self, event, target, player, data)
--     return player == target and data.card:getMark("@@zhaxiang_damage") > 0
--   end,
--   on_refresh = function(self, event, target, player, data)
--     data.disresponsiveList = table.map(player.room.alive_players, Util.IdMapper)
--   end,
-- }
-- local zhaxiang_trigger = fk.CreateTriggerSkill{
--   name = "#zhaxiang_trigger",
--   mute = true,
--   events = {fk.AfterCardsMove},
--   can_trigger = function(self, event, target, player, data)
--     if player.dead or not player:hasSkill("zhaxiang") then return false end
--     local suits = player:getTableMark("@zhaxiang-round")
--     if #suits == 4 then return false end
--     local suit, can_use = nil, false
--     for _, move in ipairs(data) do
--       if move.from == player.id then
--         for _, info in ipairs(move.moveInfo) do
--           local card = Fk:getCardById(info.cardId)
--           suit = card:getSuitString(true)
--           if card:getMark("@@visible") > 0 or info.fromArea == Card.PlayerEquip then
--             card:setMark("@@visible", 0)
--             if not table.contains(suits, suit) and suit ~= Card.NoSuit then
--               player.room:addTableMark(player, "@zhaxiang-round", suit)
--               can_use = true
--             end
--           end
--         end
--       end
--       return can_use
--     end
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     U.askForUseVirtualCard(room, player, "fire__slash", nil, self.name, "#zhaxiang_slash", 
--     true, true, true)
--   end,
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

-- local luanjuan = fk.CreateTriggerSkill{
--   name = "luanjuan",
--   mute = true,
--   events = {},

--   refresh_events = {fk.CardUsing},
--   can_refresh = function (self, event, target, player, data)
--     return player == target and player:hasSkill(self, true) and data.card.suit ~= Card.NoSuit
--     and not table.contains(player:getTableMark("@luanjuan-turn"), data.card:getSuitString(true))
--   end,
--   on_refresh = function (self, event, target, player, data)
--     player.room:addTableMark(player, "@luanjuan-turn", data.card:getSuitString(true))
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
--     room:setPlayerMark(player, "@luanjuan-turn", #mark > 0 and mark or 0)
--   end,
-- }
-- local luanjuan_maxcards = fk.CreateMaxCardsSkill{
--   name = "#luanjuan_maxcards",
--   fixed_func = function(self, player)
--     if player:hasSkill(luanjuan) then
--       return (5 - #player:getTableMark("@luanjuan-turn"))
--     end
--   end,
-- }