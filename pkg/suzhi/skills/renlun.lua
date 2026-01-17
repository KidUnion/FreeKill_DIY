local renlun = fk.CreateSkill {
  name = "renlun",
}

Fk:loadTranslationTable{
  ["renlun"] = "人论",
  [":renlun"] = "当你受到伤害后，你可进行X次判定（X为你已损失的体力值），若为红/黑，你可将一张牌当【无中生有】/【杀】对你/伤害来源使用。",
  ["#renlun-invoke"] = "人论：你可进行%arg次判定",
  ["#renlun_black"] = "人论：你可将一张牌当【杀】对%dest使用",
  ["#renlun_red"] = "人论：你可将一张牌当【无中生有】使用",

  ["$renlun"] = "人论",
}

renlun:addEffect(fk.Damaged, {
  anim_type = "masochism",
  events = {},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:isWounded()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = renlun.name,
      prompt = "#renlun-invoke:::"..(player:getLostHp()),
    }) then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for i = 1, player:getLostHp(), 1 do
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".",
      }
      room:judge(judge)
      if player.dead or not judge.card then return end
      if not data.from.dead and judge.card.color == Card.Black then
        local card = room:askToCards(target, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = renlun.name,
          prompt = "#renlun_black::"..data.from.id,
          cancelable = true,
        })
        if #card > 0 then
          room:useVirtualCard("slash", card, player, data.from, self.name)
        end
      end
      if judge.card.color == Card.Red then
        local card = room:askToCards(target, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = renlun.name,
          prompt = "#renlun_red",
          cancelable = true,
        })
        if #card > 0 then
          room:useVirtualCard("ex_nihilo", card, player, player, self.name, true)
        end
      end
    end
  end,
})

return renlun

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

-- local renlun = fk.CreateTriggerSkill{
--   name = "renlun",
--   mute = true,
--   events = {},

--   refresh_events = {fk.CardUsing},
--   can_refresh = function (self, event, target, player, data)
--     return player == target and player:hasSkill(self, true) and data.card.suit ~= Card.NoSuit
--     and not table.contains(player:getTableMark("@renlun-turn"), data.card:getSuitString(true))
--   end,
--   on_refresh = function (self, event, target, player, data)
--     player.room:addTableMark(player, "@renlun-turn", data.card:getSuitString(true))
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
--     room:setPlayerMark(player, "@renlun-turn", #mark > 0 and mark or 0)
--   end,
-- }
-- local renlun_maxcards = fk.CreateMaxCardsSkill{
--   name = "#renlun_maxcards",
--   fixed_func = function(self, player)
--     if player:hasSkill(renlun) then
--       return (5 - #player:getTableMark("@renlun-turn"))
--     end
--   end,
-- }