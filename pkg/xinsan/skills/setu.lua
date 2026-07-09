local setu = fk.CreateSkill {
  name = "setu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["setu"] = "色徒",
  [":setu"] = "锁定技，每回合首次有角色失去装备区内的牌后，你摸一张牌；若该角色为你，你获得其中一张牌且本回合下次受到伤害+1。",
  ["#setu-obtain"] = "色徒：获得其中一张牌",
  ["@@setu-turn"] = "色徒 受伤+1",

  ["$setu"] = "嘿嘿，更衣好，更衣好啊！",
}

setu:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(setu.name) and player:usedSkillTimes(setu.name, Player.HistoryTurn) == 0 then
      local cards = {}
      local equip = false
      for _, move in ipairs(data) do
        if move.from then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerEquip then
              equip = true
              if move.from == player then
                table.insert(cards, info.cardId)
              end
            end
          end
        end
      end
      event:setCostData(self, { cards = cards })
      return equip
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, setu.name)
    local player_cards = event:getCostData(self).cards
    if #player_cards > 0 then
      local room = player.room
      local card = room:askToChooseCard(player, {
        target = player,
        min_num = 1,
        max_num = 1,
        flag = { card_data = {{ setu.name, player_cards }} },
        cancelable = false,
        skill_name = setu.name,
        prompt = "#setu-obtain",
      })
      room:addPlayerMark(player, "@@setu-turn", 1)
      if not card then return end
      room:obtainCard(player, card, false, fk.ReasonPrey, player, setu.name)
    end
  end,
})

setu:addEffect(fk.DamageInflicted, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target:getMark("@@setu-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(target:getMark("@@setu-turn"))
    player.room:setPlayerMark(target, "@@setu-turn", 0)
  end,
})

return setu

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