local refeng = fk.CreateSkill {
  name = "refeng",
}

Fk:loadTranslationTable{
  ["refeng"] = "热讽",
  [":refeng"] = "出牌阶段限一次，你可以弃置一张牌（点数记为X）并指定一名其他角色，其弃置任意张牌并移除以下效果中的等量项直至回合结束。"..
  "本回合你对其使用点数不大于X的牌无距离限制且执行剩余所有选项：1、你摸一张牌；2、此牌对其造成的伤害+1；3、其不能响应此牌；4、此牌不计次数。",
  ["#refeng_trigger"] = "热讽",
  ["#refeng-active"] = "发动〖热讽〗，弃置一张牌并指定一名其他角色",
  ["#refeng-discard"] = "热讽：你须弃置任意张牌",
  ["#refeng-choose"] = "热讽：移除等量选项",

  ["$refeng"] = "热讽",
  ["@refeng-turn"] = "热讽",
  ["@@refeng_target-turn"] = "被热讽",
  ["@@refeng1-turn"] = "摸一张牌",
  ["@@refeng2-turn"] = "伤害加一",
  ["@@refeng3-turn"] = "不能响应",
  ["@@refeng4-turn"] = "不计次数",
}

refeng:addEffect("active", {
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#refeng-active",
  can_use = function(self, player)
    return player:hasSkill(refeng.name) and player:usedSkillTimes(refeng.name, Player.HistoryPhase) == 0
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    player:broadcastSkillInvoke("refeng")
    local num = Fk:getCardById(effect.cards[1]).number
    room:throwCard(effect.cards[1], self.name, player, player)
    if player.dead then return end
    room:setPlayerMark(player, "@refeng-turn", num)
    room:setPlayerMark(target, "@@refeng_target-turn", player.id)
    local all_choices = {"@@refeng1-turn", "@@refeng2-turn", "@@refeng3-turn", "@@refeng4-turn"}
    local cards = room:askToDiscard(target, {
      min_num = 1,
      max_num = 4,
      include_equip = true,
      skill_name = refeng.name,
      cancelable = false,
      prompt = "#refeng-discard",
    })
    local choices = {}
    if #cards > 0 then
      choices = room:askToChoices(
        target,
        {
          min_num = #cards,
          max_num = #cards,
          choices = all_choices,
          skill_name = refeng.name,
          prompt = "#refeng-choose",
          cancelable = false,
        }
      )
    end
    for _, choice in ipairs(all_choices) do
      if not table.contains(choices, choice) then
        room:setPlayerMark(player, choice, 1)
      end
    end
  end,
})

refeng:addEffect("targetmod", {
  bypass_distances = function (self, player, skill, card, to)
    return to:getMark("@@refeng_target-turn") == player.id and card.number > 0
    and card.number <= player:getMark("@refeng-turn")
  end,
})

refeng:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    return target == player and to:getMark("@@refeng_target-turn") == player.id and
      (data.use.card.number > 0 and data.use.card.number <= player:getMark("@refeng-turn"))
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    if player:getMark("@@refeng1-turn") > 0 then
      player:drawCards(1, self.name)
    end
    if player:getMark("@@refeng3-turn") > 0 then
      data.use.disresponsiveList = data.use.disresponsiveList or {}
      table.insert(data.use.disresponsiveList, data.to)
    end
    if player:getMark("@@refeng4-turn") > 0 then
      data.use.extraUse = true
      player:addCardUseHistory(data.use.card.trueName, -1)
    end
  end,
})

refeng:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return target == player and data.to:getMark("@@refeng_target-turn") == player.id and
    (data.card.number > 0 and data.card.number <= player:getMark("@refeng-turn"))
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    if player:getMark("@@refeng2-turn") > 0 then
      data.damage = data.damage + 1
    end
  end,
})

return refeng

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

-- local refeng = fk.CreateTriggerSkill{
--   name = "refeng",
--   mute = true,
--   events = {},

--   refresh_events = {fk.CardUsing},
--   can_refresh = function (self, event, target, player, data)
--     return player == target and player:hasSkill(self, true) and data.card.suit ~= Card.NoSuit
--     and not table.contains(player:getTableMark("@refeng-turn"), data.card:getSuitString(true))
--   end,
--   on_refresh = function (self, event, target, player, data)
--     player.room:addTableMark(player, "@refeng-turn", data.card:getSuitString(true))
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
--     room:setPlayerMark(player, "@refeng-turn", #mark > 0 and mark or 0)
--   end,
-- }
-- local refeng_maxcards = fk.CreateMaxCardsSkill{
--   name = "#refeng_maxcards",
--   fixed_func = function(self, player)
--     if player:hasSkill(refeng) then
--       return (5 - #player:getTableMark("@refeng-turn"))
--     end
--   end,
-- }