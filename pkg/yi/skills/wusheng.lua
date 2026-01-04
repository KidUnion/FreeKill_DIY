local wusheng = fk.CreateSkill {
  name = "yi__wusheng",
}

Fk:loadTranslationTable{
  ["yi__wusheng"] = "武圣",
  [":yi__wusheng"] = "出牌阶段各限一次，你可将手牌弃至/摸至X张，视为使用一张无距离次数限制的【杀】/【决斗】。（X为你本回合使用牌的花色数且包含无色）",
  ["#yi__wusheng-draw"] = "发动【武圣】，摸%arg张牌并视为使用一张【决斗】",
  ["#yi__wusheng-discard"] = "发动【武圣】，弃置%arg张手牌并视为使用一张【杀】",
  ["@yi__wusheng-turn"] = "武圣",
  ["#yi__wusheng_slash"] = "武圣：视为使用一张无距离次数限制的【杀】",
  ["#yi__wusheng_duel"] = "武圣：视为使用一张【决斗】",

  ["$yi__wusheng1"] = "刀锋所向，战无不克！",
  ["$yi__wusheng2"] = "逆贼，哪里走！",
}

wusheng:addEffect("active", {
  anim_type = "offensive",
  card_num = function(self, player)
    return math.max(0, player:getHandcardNum() - #player:getTableMark("@yi__wusheng-turn"))
  end,
  prompt = function(self, player)
    local num = player:getHandcardNum() - #player:getTableMark("@yi__wusheng-turn")
    if num < 0 then
      return "#yi__wusheng-draw:::"..-num
    else
      return "#yi__wusheng-discard:::"..num
    end
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected < player:getHandcardNum() - #player:getTableMark("@yi__wusheng-turn") and
      table.contains(player:getCardIds("h"), to_select) and 
      not player:prohibitDiscard(Fk:getCardById(to_select))
  end,
  can_use = function(self, player)
    return (player:getHandcardNum() < #player:getTableMark("@yi__wusheng-turn") and player:getMark("yi__wusheng_draw-phase") == 0) or
      (player:getHandcardNum() > #player:getTableMark("@yi__wusheng-turn") and player:getMark("yi__wusheng_discard-phase") == 0)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    if #effect.cards > 0 then
      room:addPlayerMark(player, "yi__wusheng_discard-phase", 1)
      room:throwCard(effect.cards, self.name, player, player)
      room:askToUseVirtualCard(player, {
        name = "slash",
        prompt = "#yi__wusheng_slash",
        cancelable = false,
        skill_name = wusheng.name,
        extra_data = {
          bypass_distances = true,
          bypass_times = true,
        },
      })
    else
      local num = #player:getTableMark("@yi__wusheng-turn") - player:getHandcardNum()
      room:addPlayerMark(player, "yi__wusheng_draw-phase", 1)
      if num > 0 then
        room:drawCards(player, num, self.name)
        room:askToUseVirtualCard(player, {
        name = "duel",
          prompt = "#yi__wusheng_duel",
          cancelable = false,
          skill_name = wusheng.name,
        })
      end 
    end
  end,
})

wusheng:addEffect(fk.CardUsing, {
  name = "#yi__wusheng_trigger",
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return player == target and player:hasSkill(self, true)
    and not table.contains(player:getTableMark("@yi__wusheng-turn"), data.card:getSuitString(true))
  end,
  on_trigger = function (self, event, target, player, data)
    player.room:addTableMark(player, "@yi__wusheng-turn", data.card:getSuitString(true))
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    if player ~= player.room.current then return end
    local mark = {}
    room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e)
      local use = e.data[1]
      if use.from == player.id then
        table.insertIfNeed(mark, use.card:getSuitString(true))
      end
    end, Player.HistoryTurn)
    room:setPlayerMark(player, "@yi__wusheng-turn", #mark > 0 and mark or 0)
  end,
  on_lose = function (self, player, is_start)
    player.room:setPlayerMark(player, "@yi__wusheng-turn", 0)
  end,
})

return wusheng

-- zhaxiang:addEffect(fk.HpLost, {
--   anim_type = "drawcard",
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(zhaxiang.name)
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
--         room:setCardMark(card, "@@yi__zhaxiang_damage", 1)
--       end
--     end
--     player:showCards(visible)
--   end,
-- })

-- zhaxiang:addEffect(fk.PreCardUse, {
--   can_refresh = function(self, event, target, player, data)
--     return player == target and data.card:getMark("@@yi__zhaxiang_damage") > 0
--   end,
--   on_refresh = function(self, event, target, player, data)
--     data.disresponsiveList = table.simpleClone(player.room.alive_players)
--   end,
-- })

-- zhaxiang:addEffect(fk.AfterCardsMove, {
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     if player.dead or not player:hasSkill(zhaxiang.name) then return false end
--     local suits = player:getTableMark("@yi__zhaxiang-round")
--     if #suits == 4 then return false end
--     local suit, can_use = nil, false
--     for _, move in ipairs(data) do
--       if move.from == player then
--         for _, info in ipairs(move.moveInfo) do
--           local card = Fk:getCardById(info.cardId)
--           suit = card:getSuitString(true)
--           if card:getMark("@@visible") > 0 or info.fromArea == Card.PlayerEquip then
--             card:setMark("@@visible", 0)
--             if not table.contains(suits, suit) and suit ~= Card.NoSuit then
--               player.room:addTableMark(player, "@yi__zhaxiang-round", suit)
--               can_use = true
--             end
--           end
--         end
--       end
--       return can_use
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     local room = player.room
--     local slash = Fk:cloneCard("slash")
--     local max_num = slash.skill:getMaxTargetNum(player, slash)
--     local targets = table.filter(room:getOtherPlayers(player, false), function (p)
--       return player:canUseTo(slash, p, {bypass_distances = true, bypass_times = true})
--     end)
--     local tos = room:askToChoosePlayers(player, {
--       min_num = 1,
--       max_num = max_num,
--       targets = targets,
--       skill_name = zhaxiang.name,
--       prompt = "#yi__zhaxiang-choose",
--       cancelable = true,
--     })
--     if #tos > 0 then
--       event:setCostData(self, {tos = tos})
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local targets = event:getCostData(self).tos
--     room:sortByAction(targets)
--     room:useVirtualCard("fire__slash", nil, player, targets, zhaxiang.name, true)
--   end,
-- })

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