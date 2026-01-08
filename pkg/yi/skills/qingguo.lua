local qingguo = fk.CreateSkill {
  name = "yi__qingguo",
  -- frequency = Skill.Compulsory,
}

Fk:loadTranslationTable{
  ["yi__qingguo"] = "倾国",
  [":yi__qingguo"] = "锁定技，当你或你攻击范围内的角色失去【闪】时，你从牌堆中获得一张黑色牌，此牌不计次数与手牌上限。",
  ["@@yi__qingguo-inhand"] = "倾国",

  ["$yi__qingguo1"] = "髣髴兮若轻云之蔽月。",
  ["$yi__qingguo2"] = "飘飖兮若流风之回雪。",
}

qingguo:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(qingguo.name) then
      for _, move in ipairs(data) do
        if move.from and (player:inMyAttackRange(move.from) or move.from == player) then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Player.Hand or info.fromArea == Player.Equip) and Fk:getCardById(info.cardId).name == "jink" then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getCardsFromPileByRule(".|.|spade,club")
    if #cards > 0 then
      room:obtainCard(player, cards, true, fk.ReasonJustMove, player, qingguo.name)
    end
  end
})

qingguo:addEffect("maxcards", {
  exclude_from = function(self, player, card)
    return card:getMark("@@yi__qingguo-inhand") > 0
  end,
})

qingguo:addEffect(fk.PreCardUse, {
  mute = true,
  can_refresh = function (self, event, target, player, data)
    return target == player and data.card:getMark("@@yi__qingguo-inhand") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    data.extraUse = true
  end,
})

return qingguo

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

-- local qingguo = fk.CreateTriggerSkill{
--   name = "qingguo",
--   mute = true,
--   events = {},

--   refresh_events = {fk.CardUsing},
--   can_refresh = function (self, event, target, player, data)
--     return player == target and player:hasSkill(self, true) and data.card.suit ~= Card.NoSuit
--     and not table.contains(player:getTableMark("@qingguo-turn"), data.card:getSuitString(true))
--   end,
--   on_refresh = function (self, event, target, player, data)
--     player.room:addTableMark(player, "@qingguo-turn", data.card:getSuitString(true))
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
--     room:setPlayerMark(player, "@qingguo-turn", #mark > 0 and mark or 0)
--   end,
-- }
-- local qingguo_maxcards = fk.CreateMaxCardsSkill{
--   name = "#qingguo_maxcards",
--   fixed_func = function(self, player)
--     if player:hasSkill(qingguo) then
--       return (5 - #player:getTableMark("@qingguo-turn"))
--     end
--   end,
-- }