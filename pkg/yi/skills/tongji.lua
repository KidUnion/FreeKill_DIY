local tongji = fk.CreateSkill {
  name = "yi__tongji",
}

Fk:loadTranslationTable{
  ["yi__tongji"] = "同疾",
  [":yi__tongji"] = "出牌阶段限一次，你可视为使用一张未以此法使用过的伤害牌，然后本局游戏你不能响应此牌名的牌。",
  ["#yi__tongji"] = "发动【同疾】，视为使用一张未以此法使用过的伤害牌",
  ["#yi__tongji_trigger"] = "同疾",
  
  ["$yi__tongji1"] = "弑君之罪，当诛九族！",
  ["$yi__tongji2"] = "你，你这是反啦！",
}

tongji:addEffect("viewas", {
  prompt = "#yi__tongji",
  anim_type = "offensive",
  interaction = function(self, player)
    local names = table.filter(Fk:getAllCardNames("bt"), function (name)
      local card = Fk:cloneCard(name)
      card.skillName = tongji.name
      return player:canUse(card) and not player:prohibitUse(card) and card.is_damage_card 
        and not table.contains(player:getTableMark("yi__tongji_used"), name)
    end)
    if #names == 0 then return end
    return UI.ComboBox {choices = names}
  end,
  card_num = 0,
  view_as = function(self, player)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = tongji.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(tongji.name, Player.HistoryPhase) < 1
  end,
  after_use = function(self, player, use)
    if not use.card then return end
    player.room:addTableMark(player, "yi__tongji_used", use.card.name)
  end,
})

tongji:addEffect(fk.TargetConfirmed, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(tongji.name) 
      and table.contains(player:getTableMark("yi__tongji_used"), data.card.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, tongji.name, "negative")
    data:setDisresponsive(player)
  end,
})

return tongji


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