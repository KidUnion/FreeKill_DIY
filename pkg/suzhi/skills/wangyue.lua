local wangyue = fk.CreateSkill {
  name = "suzhi__wangyue",
}

Fk:loadTranslationTable{
  ["suzhi__wangyue"] = "望岳",
  [":suzhi__wangyue"] = "出牌阶段限一次，你可与一名手牌数不大于你的角色交换手牌，然后摸两张牌并将手牌弃至与其相同，本回合你与其距离视为一。",
  ["#suzhi__wangyue-active"] = "发动〖望岳〗，与一名手牌数不大于你的角色交换手牌",
  ["#suzhi__wangyue-discard"] = "望岳：你须将手牌弃至与其相同",
  
  ["$suzhi__wangyue"] = "望岳",
  ["@@suzhi__wangyue-turn"] = "望岳",
}

-- local wangyue = fk.CreateActiveSkill{
--   name = "suzhi__wangyue",
--   anim_type = "control",
--   target_num = 1,
--   prompt = "#suzhi_wangyue-active",
--   can_use = function(self, player)
--     return player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
--   end,
--   card_filter = Util.FalseFunc,
--   target_filter = function(self, to_select, selected)
--     local target = Fk:currentRoom():getPlayerById(to_select)
--     return Self.id ~= to_select and #selected == 0 and target:getHandcardNum() <= Self:getHandcardNum() 
--   end,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     local target = room:getPlayerById(effect.tos[1])
--     U.swapCards(room, player, player, target, player:getCardIds("h"), target:getCardIds("h"), self.name)
--     if not player.dead then
--       room:drawCards(player, 2, self.name)
--       room:setPlayerMark(target, "@@suzhi_wangyue-turn", player.id)
--       local num = player:getHandcardNum() - target:getHandcardNum()
--       if num > 0 then
--         room:askForDiscard(player, num, num, false, self.name, false, nil, "#suzhi_wangyue-discard")
--       end
--     end
--   end,
-- }
-- local wangyue_distance = fk.CreateDistanceSkill{
--   name = "#suzhi_wangyue_distance",
--   fixed_func = function(self, from, to)
--     if from:hasSkill(wangyue) and to:getMark("@@suzhi_wangyue-turn") == from.id then
--       return 1
--     end
--   end,
-- }

return wangyue

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

-- local wangyue = fk.CreateTriggerSkill{
--   name = "wangyue",
--   mute = true,
--   events = {},

--   refresh_events = {fk.CardUsing},
--   can_refresh = function (self, event, target, player, data)
--     return player == target and player:hasSkill(self, true) and data.card.suit ~= Card.NoSuit
--     and not table.contains(player:getTableMark("@wangyue-turn"), data.card:getSuitString(true))
--   end,
--   on_refresh = function (self, event, target, player, data)
--     player.room:addTableMark(player, "@wangyue-turn", data.card:getSuitString(true))
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
--     room:setPlayerMark(player, "@wangyue-turn", #mark > 0 and mark or 0)
--   end,
-- }
-- local wangyue_maxcards = fk.CreateMaxCardsSkill{
--   name = "#wangyue_maxcards",
--   fixed_func = function(self, player)
--     if player:hasSkill(wangyue) then
--       return (5 - #player:getTableMark("@wangyue-turn"))
--     end
--   end,
-- }