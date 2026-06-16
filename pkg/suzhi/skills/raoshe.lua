local raoshe = fk.CreateSkill {
  name = "raoshe",
}

Fk:loadTranslationTable{
  ["raoshe"] = "饶舌",
  [":raoshe"] = "你的阶段结束时，若你的手牌数等于X且不为零，你可将手牌摸至五张并选择一项（X为你本回合剩余的阶段数）："..
  "1、视为使用一张【火攻】并于结算完毕后弃置以此法获得的牌；2、弃置X张牌。",

  ["$raoshe"] = "饶舌",
  ["@@raoshe-phase"] = "饶舌",
  ["#raoshe-choose"] = "饶舌：选择视为使用【火攻】或弃置%arg张牌",
  ["raoshe1"] = "视为使用一张【火攻】",
  ["raoshe2"] = "弃置%arg张牌",
  ["#raoshe-discard"] = "饶舌：弃置%arg张牌",
  ["#raoshe-use"] = "饶舌：视为对一名角色使用一张【火攻】",
}

raoshe:addEffect(fk.EventPhaseEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    local num = player:getHandcardNum()
    if num > 5 or num < 1 then return false end
    return target == player and player:hasSkill(raoshe.name) and (num == Player.Finish - player.phase)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #player:getCardIds(Player.Hand) < 5 then
      room:drawCards(player, 5 - #player:getCardIds(Player.Hand), self.name, "top", {"@@raoshe-phase", 1})
    end
    local discard_num = Player.Finish - player.phase
    local all_choices = {"raoshe1", "raoshe2:::"..discard_num}
    local choices = table.simpleClone(all_choices)
    if #Fk:cloneCard("fire_attack"):getAvailableTargets(player, { bypass_times = true, extraUse = true }) == 0 then
      table.removeOne(choices, "raoshe1")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = raoshe.name,
      prompt = "#raoshe-choose:::"..discard_num,
      cancelable = false,
      all_choices = all_choices,
    })
    if choice == "raoshe1" then
      room:askToUseVirtualCard(player, {
        name = "fire_attack",
        skill_name = raoshe.name,
        prompt = "#raoshe-use",
        cancelable = false,
      })
      local cards = table.filter(player:getCardIds(Player.Hand), function(id)
        return Fk:getCardById(id):getMark("@@raoshe-phase") > 0
      end)
      if #cards > 0 then
        room:throwCard(cards, raoshe.name, player, player)
      end
    else
      room:askToDiscard(player, {
        min_num = discard_num,
        max_num = discard_num,
        include_equip = false,
        skill_name = raoshe.name,
        cancelable = false,
        prompt = "#raoshe-discard:::"..discard_num,
      })
    end
  end,
})

return raoshe
