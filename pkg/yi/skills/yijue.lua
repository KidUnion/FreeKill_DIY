local yijue = fk.CreateSkill {
  name = "yi__yijue",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["yi__yijue"] = "义绝",
  [":yi__yijue"] = "锁定技，防止一名角色对你造成的首次致命伤害，若如此做，防止你对其造成的下一次致命伤害。",
  ["#yi__yijue_delay"] = "义绝",
  ["@@yi__yi"] = "义",
  ["@@yi__yijue"] = "义绝",

  ["$yi__yijue1"] = "关某，向来恩怨分明！",
  ["$yi__yijue2"] = "恩已断，义当绝！",
}

yijue:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.damage >= player.hp and data.from and
      data.from:getMark("@@yi__yi") ~= player.id and data.from:getMark("@@yi__yijue") ~= player.id
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player.room:doIndicate(player.id, {data.from.id})
    room:setPlayerMark(data.from, "@@yi__yi", player.id)
    data:preventDamage()
  end,
})

yijue:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return data.from and data.from == player and player:hasSkill(self) and data.damage >= target.hp and
    target:getMark("@@yi__yi") == player.id
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player.room:doIndicate(player.id, {target.id})
    room:setPlayerMark(target, "@@yi__yi", 0)
    room:setPlayerMark(target, "@@yi__yijue", player.id)
    data:preventDamage()
  end,
})

return yijue

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