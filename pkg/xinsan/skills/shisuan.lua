local shisuan = fk.CreateSkill {
  name = "xinsan__shisuan",
}

Fk:loadTranslationTable{
  ["xinsan__shisuan"] = "嗜酸",
  [":xinsan__shisuan"] = "准备阶段，你可弃置任意张牌并选择一名角色，令攻击范围内包含其的至多等量名角色依次选择交给你一张牌或将其一张牌当【酒】使用，"..
  "然后你可令手牌数因此变动的角色各失去一点体力。",
  ["#xinsan__shisuan-discard"] = "嗜酸：你可以弃置任意张牌并选择一名角色",
  ["#xinsan__shisuan-choose"] = "嗜酸：选择攻击范围内包含%dest的至多%arg名角色",
  ["#xinsan__shisuan-choice"] = "嗜酸：你须选择一项",
  ["xinsan__shisuan_give"] = "交给%dest一张牌",
  ["xinsan__shisuan_use"] = "将%dest的一张牌当【酒】用",
  ["#xinsan__shisuan-give"] = "嗜酸：交给%dest一张牌",
  ["#xinsan__shisuan-use"] = "嗜酸：将%dest的一张牌当【酒】使用",
  ["#xinsan__shisuan-lose"] = "嗜酸：你可令手牌数变动的角色各失去一点体力",

  ["$xinsan__shisuan1"] = "咱家说了，不怕酸！",
  ["$xinsan__shisuan2"] = "咱家恨不得砍了他们的脑袋，用他们的肉煮汤喝！",
}

shisuan:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shisuan.name) and player.phase == Player.Start
      and #player:getCardIds("he") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local target1, cards = room:askToChooseCardsAndPlayers(player, {
      targets = room:getAlivePlayers(),
      min_num = 1,
      max_num = 1,
      min_card_num = 1,
      max_card_num = 999,
      will_throw = true,
      cancelable = true,
      skill_name = shisuan.name,
      prompt = "#xinsan__shisuan-discard",
    })
    if #cards == 0 or #target1 == 0 then return false end
    room:throwCard(cards, shisuan.name, player, player)
    local targets2 = room:askToChoosePlayers(player, {
      targets = table.filter(room:getAlivePlayers(), function(p) 
        return p:inMyAttackRange(target1[1])
      end),
      min_num = 0,
      max_num = #cards,
      skill_name = shisuan.name,
      prompt = "#xinsan__shisuan-choose::" .. target1[1].id .. ":" .. #cards,
    })
    event:setCostData(self, {tos = target1[1], froms = targets2})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos
    local froms = event:getCostData(self).froms
    local all_choices = { "xinsan__shisuan_give::" .. player.id, "xinsan__shisuan_use::" .. to.id }
    local changed_players = {}
    if #froms == 0 then return end
    for _, p in ipairs(froms) do
      local choices = {}
      if #p:getCardIds("he") > 0 then
        table.insert(choices, "xinsan__shisuan_give::" .. player.id)
      end
      if #to:getCardIds("he") > 0 then
        table.insert(choices, "xinsan__shisuan_use::" .. to.id)
      end
      if #choices > 0 then
        local choice = room:askToChoice(p, {
          choices = choices,
          all_choices = all_choices,
          skill_name = shisuan.name,
          prompt = "#xinsan__shisuan-choice",
          cancelable = false,
        })
        if choice == "xinsan__shisuan_give::" .. player.id then
          local cards = room:askToCards(p, {
            min_num = 1,
            max_num = 1,
            include_equip = true,
            skill_name = shisuan.name,
            prompt = "#xinsan__shisuan-give::"..player.id,
            cancelable = false,
          })
          if #cards == 0 then return end
          if room:getCardArea(cards[1]) == Player.Hand then
            table.insertIfNeed(changed_players, p)
          end
          table.insertIfNeed(changed_players, player)
          room:obtainCard(player, cards, false, fk.ReasonGive, p)
        elseif choice == "xinsan__shisuan_use::" .. to.id then
          local cards = room:askToChooseCard(p, {
            target = to,
            flag = "he",
            skill_name = shisuan.name,
            prompt = "#xinsan__shisuan-use::" .. to.id,
            cancelable = false,
          })
          if not cards then return end
          if room:getCardArea(cards) == Player.Hand then
            table.insertIfNeed(changed_players, to)
          end
          local card = Fk:cloneCard("analeptic")
          card.skillName = shisuan.name
          card:addSubcards({cards})
          room:useCard {
            from = p,
            tos = { p },
            card = card,
          }
        end
      end
    end
    if #changed_players == 0 then return end
    if room:askToSkillInvoke(player, {
      skill_name = shisuan.name,
      prompt = "#xinsan__shisuan-lose",
    }) then
      for _, p in ipairs(changed_players) do
        room:loseHp(p, 1, shisuan.name)
      end
    end
  end,
})

return shisuan

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

-- local fanjian = fk.CreateActiveSkill{
--   name = "fanjian",
--   prompt = "#fanjian-active",
--   anim_type = "drawcard",
--   can_use = function(self, player)
--     return player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryRound) == 0 
--       and #player:getCardIds(Player.Hand) > 0
--   end,
--   card_filter = Util.FalseFunc,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     local show_cards = player:getCardIds(Player.Hand)
--     player:showCards(show_cards)
--     room:addPlayerMark(player, "fanjian-turn", 1)
--     local cards_suits = {}
--     for _, id in ipairs(show_cards) do
--       local card = Fk:getCardById(id)
--       if not table.contains(cards_suits, card.suit) then
--         table.insert(cards_suits, card.suit)
--       end
--     end
--     local top_cards = room:getNCards(5)
--     room:moveCardTo(top_cards, Card.Processing)
--     room:delay(500)
--     local match = {}
--     for _, id in ipairs(top_cards) do
--       local card = Fk:getCardById(id)
--       if not table.contains(cards_suits, card.suit) then
--         table.insert(match, card)
--       end
--     end
--     room:moveCardTo(match, Player.Hand, player, fk.ReasonPrey, self.name)
--     local cardsInProcessing = table.filter(top_cards, function(id) return room:getCardArea(id) == Card.Processing end)
--     if #cardsInProcessing > 0 then
--       room:moveCardTo(cardsInProcessing, Card.DiscardPile)
--     end
--   end,
-- }
-- local fanjian_targetmod = fk.CreateTargetModSkill{
--   name = "#fanjian_targetmod",
--   bypass_times = function(self, player, skill, scope, card)
--     return card and player:hasSkill(fanjian) and player:getMark("fanjian-turn") > 0
--   end,
--   bypass_distances = function(self, player, skill, card)
--     return card and player:hasSkill(fanjian) and player:getMark("fanjian-turn") > 0
--   end,
-- }
-- local fanjian_trigger = fk.CreateTriggerSkill{
--   name = "#fanjian_trigger",
--   mute = true,
--   events = {fk.AfterCardUseDeclared},
--   can_trigger = function(self, event, target, player, data)
--     return player == target and player:hasSkill(fanjian) and player:getMark("fanjian-turn") > 0
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     if not (data.card:isVirtual() and #data.card.subcards == 0) then
--       local card = Fk:cloneCard(data.card.name, data.card.suit, data.card.number)
--       for k, v in pairs(data.card) do
--         if card[k] == nil then
--           card[k] = v
--         end
--       end
--       if data.card:isVirtual() then
--         card.subcards = data.card.subcards
--       else
--         card.id = data.card.id
--       end
--       card.skillNames = data.card.skillNames
--       card.skillName = "fanjian"
--       card.suit = Card.NoSuit
--       card.color = Card.NoColor
--       data.card = card
--     end
--     local room = player.room
--     room:setPlayerMark(player, "fanjian-turn", 0)
--   end,
-- }