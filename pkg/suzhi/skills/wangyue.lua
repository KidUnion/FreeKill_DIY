local wangyue = fk.CreateSkill {
  name = "suzhi__wangyue",
  dynamic_desc = function (self, player)
    return "suzhi__wangyue_inner:"..math.max(player:getMark("@suzhi__wangyue_times"), 1)..":"..
      math.max(player:getMark("@suzhi__wangyue_num"), 1)
  end,
}

Fk:loadTranslationTable{
  ["suzhi__wangyue"] = "望岳",
  [":suzhi__wangyue"] = "出牌阶段限｛1｝次，你可与一名其他角色同时将手牌数向对方调整｛1｝张，若你与其手牌数大小关系不变，你可令｛｝中最小的一个数字+1。回合结束时，你将一项改为1。",
  [":suzhi__wangyue_inner"] = "出牌阶段限｛{1}｝次，你可与一名其他角色同时将手牌数向对方调整｛{2}｝张，若你与其手牌数大小关系不变，你可令｛｝中最小的一个数字+1。回合结束时，你将一项改为1。",
  ["#suzhi__wangyue-active"] = "发动〖望岳〗，与一名手牌数与你不同的其他角色调整手牌数",
  ["#suzhi__wangyue-discard"] = "望岳：弃置%arg张手牌",
  ["#suzhi__wangyue-upgrade"] = "望岳：你可令其中一项+1",
  ["#suzhi__wangyue-reset"] = "望岳：选择一项改为1",
  ["suzhi__wangyue_times"] = "发动次数",
  ["suzhi__wangyue_num"] = "调整张数",
  ["@suzhi__wangyue_times"] = "望岳次数",
  ["@suzhi__wangyue_num"] = "望岳张数",
  
  ["$suzhi__wangyue"] = "望岳",
}

local function getWangyueTimes(player)
  return math.max(player:getMark("@suzhi__wangyue_times"), 1)
end

local function getWangyueNum(player)
  return math.max(player:getMark("@suzhi__wangyue_num"), 1)
end

local function compareHandNum(player, target)
  local diff = player:getHandcardNum() - target:getHandcardNum()
  if diff > 0 then
    return 1
  elseif diff < 0 then
    return -1
  end
  return 0
end

local function setDefaultMarks(player)
  local room = player.room
  if player:getMark("@suzhi__wangyue_times") == 0 then
    room:setPlayerMark(player, "@suzhi__wangyue_times", 1)
  end
  if player:getMark("@suzhi__wangyue_num") == 0 then
    room:setPlayerMark(player, "@suzhi__wangyue_num", 1)
  end
end

wangyue:addEffect("active", {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#suzhi__wangyue-active",
  can_use = function(self, player)
    return player:hasSkill(wangyue.name) and
      player:usedSkillTimes(wangyue.name, Player.HistoryPhase) < getWangyueTimes(player)
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return player ~= to_select and #selected == 0 and to_select:getHandcardNum() ~= player:getHandcardNum()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local relation = compareHandNum(player, target)
    local num = getWangyueNum(player)
    local higher = relation > 0 and player or target
    local lower = relation > 0 and target or player
    local tos = {higher, lower}
    room:sortByAction(tos)
    for _, p in ipairs(tos) do
      if p == higher and not p.dead then
        room:askToDiscard(p, {
          min_num = num,
          max_num = num,
          include_equip = false,
          skill_name = wangyue.name,
          cancelable = false,
          prompt = "#suzhi__wangyue-discard:::"..num,
        })
      elseif p == lower and not p.dead then
        p:drawCards(num, wangyue.name)
      end
    end
    if player.dead or target.dead or compareHandNum(player, target) ~= relation then return end
    local times = getWangyueTimes(player)
    local card_num = getWangyueNum(player)
    local choices = {}
    if times <= card_num then
      table.insert(choices, "suzhi__wangyue_times")
    end
    if card_num <= times then
      table.insert(choices, "suzhi__wangyue_num")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = wangyue.name,
      prompt = "#suzhi__wangyue-upgrade",
      cancelable = true,
      all_choices = {"suzhi__wangyue_times", "suzhi__wangyue_num", "Cancel"},
    })
    if choice == "suzhi__wangyue_times" then
      room:addPlayerMark(player, "@suzhi__wangyue_times", 1)
    elseif choice == "suzhi__wangyue_num" then
      room:addPlayerMark(player, "@suzhi__wangyue_num", 1)
    end
  end,
})

wangyue:addEffect(fk.TurnEnd, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wangyue.name) and
      (getWangyueTimes(player) > 1 or getWangyueNum(player) > 1)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {}
    if getWangyueTimes(player) > 1 then
      table.insert(choices, "suzhi__wangyue_times")
    end
    if getWangyueNum(player) > 1 then
      table.insert(choices, "suzhi__wangyue_num")
    end
    local choice = choices[1]
    if #choices > 1 then
      choice = room:askToChoice(player, {
        choices = choices,
        skill_name = wangyue.name,
        prompt = "#suzhi__wangyue-reset",
        cancelable = false,
        all_choices = {"suzhi__wangyue_times", "suzhi__wangyue_num"},
      })
    end
    room:setPlayerMark(player, "@"..choice, 1)
  end,
})

wangyue:addAcquireEffect(function (self, player, is_start)
  setDefaultMarks(player)
end)

wangyue:addLoseEffect(function (self, player, is_death)
  local room = player.room
  room:setPlayerMark(player, "@suzhi__wangyue_times", 0)
  room:setPlayerMark(player, "@suzhi__wangyue_num", 0)
end)

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
