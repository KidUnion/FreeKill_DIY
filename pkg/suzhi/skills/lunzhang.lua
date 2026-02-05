local lunzhang = fk.CreateSkill {
  name = "lunzhang",
}

Fk:loadTranslationTable{
  ["lunzhang"] = "论章",
  [":lunzhang"] = "你获得过牌的回合结束时，你可重铸至多等量张牌并可与一名角色拼点，若你赢，你可视为对其使用一张你本回合失去过的牌。",

  ["$lunzhang"] = "论章",
  ["@lunzhang_obtain-turn"] = "本回合获得牌数",
  ["lunzhang_lose-turn"] = "论章-可使用",
  ["#lunzhang-recast"] = "论章：你可重铸至多 %arg 张牌",
  ["#lunzhang-choose"] = "论章：你可与一名角色拼点，若赢，可视为对其使用一张你本回合失去过的牌",
  ["#lunzhang-use"] = "论章：你可视为对%dest使用一张牌",
}

local U = require "packages.utility.utility"

lunzhang:addEffect(fk.AfterCardsMove,{
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(lunzhang.name, true) then return false end
    local room = player.room
    for _, move in ipairs(data) do
      local player_lose = false
      if move.to and move.to == player and move.toArea == Player.Hand then
        room:addPlayerMark(player, "@lunzhang_obtain-turn", #move.moveInfo)
      end
      if move.from and move.from == player then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId)
          if card.type ~= Card.TypeEquip and card.sub_type ~= Card.SubtypeDelayedTrick then
            room:addTableMarkIfNeed(player, "lunzhang_lose-turn", card.name)
          end
        end
      end
    end
    return false
  end,
})

lunzhang:addEffect(fk.TurnEnd,{
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(lunzhang.name) and player:getMark("@lunzhang_obtain-turn") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = room:askToCards(player, {
      min_num = 1,
      max_num = player:getMark("@lunzhang_obtain-turn"),
      include_equip = true,
      skill_name = lunzhang.name,
      prompt = "#lunzhang-recast:::"..player:getMark("@lunzhang_obtain-turn"),
      cancelable = true,
    })
    if #ids > 0 then
      room:recastCard(ids, player, lunzhang.name)
    end

    local targets = table.filter(room.alive_players, function(p)
      return player:canPindian(p)
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = lunzhang.name,
      prompt = "#lunzhang-choose",
      cancelable = true,
    })
    if #to == 0 then return end
    to = to[1]
    local pindian = player:pindian({to}, lunzhang.name)
    if pindian.results[to].winner == player then
      if player.dead or to.dead then return end
      local card_names = table.filter(player:getTableMark("lunzhang_lose-turn") or {}, function(name)
        local card = Fk:cloneCard(name)
        return player:canUseTo(card, to) and not player:prohibitUse(card)
      end)
      room:askToUseVirtualCard(player, {
        name = card_names,
        skill_name = lunzhang.name,
        prompt = "#lunzhang-use::"..to.id,
        cancelable = true,
        extra_data = {
          bypass_distances = true,
          bypass_times = true,
          extraUse = true,
          exclusive_targets = {to.id},
        },
        skip = false,
      })
    end
  end,
})

return lunzhang

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

-- local lunzhang = fk.CreateTriggerSkill{
--   name = "lunzhang",
--   mute = true,
--   events = {},

--   refresh_events = {fk.CardUsing},
--   can_refresh = function (self, event, target, player, data)
--     return player == target and player:hasSkill(self, true) and data.card.suit ~= Card.NoSuit
--     and not table.contains(player:getTableMark("@lunzhang-turn"), data.card:getSuitString(true))
--   end,
--   on_refresh = function (self, event, target, player, data)
--     player.room:addTableMark(player, "@lunzhang-turn", data.card:getSuitString(true))
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
--     room:setPlayerMark(player, "@lunzhang-turn", #mark > 0 and mark or 0)
--   end,
-- }
-- local lunzhang_maxcards = fk.CreateMaxCardsSkill{
--   name = "#lunzhang_maxcards",
--   fixed_func = function(self, player)
--     if player:hasSkill(lunzhang) then
--       return (5 - #player:getTableMark("@lunzhang-turn"))
--     end
--   end,
-- }