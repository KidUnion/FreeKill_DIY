local guanxing = fk.CreateSkill {
  name = "yi__guanxing",
}

Fk:loadTranslationTable{
  ["yi__guanxing"] = "观星",
  [":yi__guanxing"] = "准备阶段，你可将手牌摸至｛7｝张并视为使用一张【火攻】（若你因此成为手牌数唯一最多的角色或造成伤害，｛｝中的数字-1），"..
  "然后将以此法获得的牌以任意顺序置于牌堆顶或牌堆底。",
  ["#yi__guanxing"] = "观星：你可将手牌摸至%arg张，然后视为使用一张【火攻】",
  ["@yi__guanxing"] = "观星",
  ["@@yi__guanxing-inhand"] = "观星",
  
  ["$yi__guanxing1"] = "祈星辰之力，佑我蜀汉！",
  ["$yi__guanxing2"] = "伏望天恩，誓讨汉贼！",
}

guanxing:addAcquireEffect(function (self, player, is_start)
  player.room:setPlayerMark(player, "@yi__guanxing", 7)
end)

guanxing:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(guanxing.name) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = guanxing.name,
      prompt = "#yi__guanxing:::"..player:getMark("@yi__guanxing"),
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark = math.floor(player:getMark("@yi__guanxing"))
    local to_draw = math.max(0, mark - player:getHandcardNum())
    if to_draw > 0 then
      player:drawCards(to_draw, guanxing.name, "top", "@@yi__guanxing-inhand")
    end

    local remove = false
    if table.every(player.room.alive_players, function (p)
        return p == player or p:getHandcardNum() < player:getHandcardNum()
      end) then
      remove = true 
    end
      
    local use = room:askToUseVirtualCard(player, {
      name = "fire_attack",
      skill_name = guanxing.name,
      cancelable = false,
    })
    if use and use.damageDealt then
      remove = true 
    end
    if remove then
      room:notifySkillInvoked(player, guanxing.name, "negative")
      room:removePlayerMark(player, "@yi__guanxing", 1)
    end
    local guanxing_cards = table.filter(player:getCardIds(Player.Hand), function (id)
      local card = Fk:getCardById(id)
      return card:getMark("@@yi__guanxing-inhand") > 0
    end)
    if #guanxing_cards > 0 then
      local result = room:askToGuanxing(player, {
        cards = guanxing_cards,
        skill_name = guanxing.name,
        skip = true,
      })
      local top, bottom = result.top, result.bottom
      room:moveCards({
        ids = top,
        from = player,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonJustMove,
        skillName = guanxing.name,
        proposer = player,
        drawPilePosition = 1,
      })
      room:moveCards({
        ids = bottom,
        from = player,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonJustMove,
        skillName = guanxing.name,
        proposer = player,
        drawPilePosition = -1,
      })
    end
  end,
})

return guanxing

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