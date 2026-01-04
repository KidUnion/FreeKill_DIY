local kongcheng = fk.CreateSkill {
  name = "yi__kongcheng",
}

Fk:loadTranslationTable{
  ["yi__kongcheng"] = "空城",
  [":yi__kongcheng"] = "出牌阶段，若你武将牌上的牌数不大于已损失体力值，你可将一张手牌扣置于武将牌上。"..
  "你可将这些牌如手牌般使用或打出并弃置当前回合角色一张牌，然后若你没有手牌，则将牌堆顶的牌扣置于武将牌上。",
  ["yi__kongcheng__pile"] = "空城",
  ["#yi__kongcheng"] = "空城：将一张手牌扣置于武将牌上",
  ["#yi__kongcheng-discard"] = "空城：弃置当前回合角色一张牌",
  
  ["$yi__kongcheng1"] = "淡然相对，转危为安。",
  ["$yi__kongcheng2"] = "绝处逢生，此招慎用。",
}

kongcheng:addEffect("active", {
  anim_type = "special",
  prompt = "#yi__kongcheng",
  card_num = 1,
  can_use = function(self, player)
    return player:hasSkill(self.name) and not player:isKongcheng() and
      #player:getPile("yi__kongcheng__pile") <= player:getLostHp()
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("h"), to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    player:addToPile("yi__kongcheng__pile", effect.cards[1], false, kongcheng.name)
  end,
})

kongcheng:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(kongcheng.name) then
      for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromSpecialName == "yi__kongcheng__pile" then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local current = room.current
    if not (current.dead or current:isNude()) then
      local card = room:askToChooseCard(player, { 
        target = current, 
        flag = "he", 
        skill_name = kongcheng.name,
        prompt = "#yi__kongcheng-discard",
      })
      room:throwCard(card, kongcheng.name, current, player)
    end
    if player:isKongcheng() then
      local cards = room:getNCards(1)
      player:addToPile("yi__kongcheng__pile", cards, false, kongcheng.name)
    end
  end,
})

kongcheng:addEffect("filter", {
  handly_cards = function (self, player)
    if player:hasSkill(kongcheng.name) then
      return player:getPile("yi__kongcheng__pile")
    end
  end,
})

return kongcheng

-- local zhaxiang = fk.CreateTriggerSkill{
--   name = "yi__zhaxiang",
--   anim_type = "drawcard",
--   prompt = "#yi__zhaxiang",
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
--         room:setCardMark(card, "@@yi__zhaxiang_damage", 1)
--       end
--     end
--     player:showCards(visible)
--   end,
-- }
-- local zhaxiang_delay = fk.CreateTriggerSkill{
--   name = "#yi__zhaxiang_delay",
--   refresh_events = {fk.PreCardUse},
--   can_refresh = function(self, event, target, player, data)
--     return player == target and data.card:getMark("@@yi__zhaxiang_damage") > 0
--   end,
--   on_refresh = function(self, event, target, player, data)
--     data.disresponsiveList = table.map(player.room.alive_players, Util.IdMapper)
--   end,
-- }
-- local zhaxiang_trigger = fk.CreateTriggerSkill{
--   name = "#yi__zhaxiang_trigger",
--   mute = true,
--   events = {fk.AfterCardsMove},
--   can_trigger = function(self, event, target, player, data)
--     if player.dead or not player:hasSkill("yi__zhaxiang") then return false end
--     local suits = player:getTableMark("@yi__zhaxiang-round")
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
--               player.room:addTableMark(player, "@yi__zhaxiang-round", suit)
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
--     U.askForUseVirtualCard(room, player, "fire__slash", nil, self.name, "#yi__zhaxiang_slash", 
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