local qianxun = fk.CreateSkill {
  name = "yi__qianxun",
}

Fk:loadTranslationTable{
	["yi__qianxun"] = "谦逊",
  [":yi__qianxun"] = "每回合限一次，当你成为锦囊牌的目标时，你可弃置与之颜色相同的所有手牌并取消你为目标。",
  ["#yi__qianxun-invoke"] = "谦逊：你可弃置所有%arg色的手牌，取消你为目标",

  ["$yi__qianxun1"] = "满招损，谦受益。",
  ["$yi__qianxun2"] = "谦谦君子，温润如玉。",
}

qianxun:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(qianxun.name) and data.card.type == Card.TypeTrick and target == player and  
      #table.filter(player:getCardIds("h"), function(id) 
        return Fk:getCardById(id).color == data.card.color and id ~= data.card.id
      end) ~= 0 and player:usedSkillTimes(qianxun.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local colors = {"黑", "红", "无"}
    if room:askToSkillInvoke(player, {
        skill_name = qianxun.name, 
        prompt = "#yi__qianxun-invoke:::"..colors[data.card.color]
      }) then return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getCardIds("h"), function(id) 
      return Fk:getCardById(id).color == data.card.color 
    end)
    if #cards > 0 then
      room:throwCard(cards, self.name, player, player)
      data:cancelTarget(player)
    end
  end,
})

return qianxun


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

  