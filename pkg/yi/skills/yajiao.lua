local yajiao = fk.CreateSkill {
  name = "yi__yajiao",
  tags = {Skill.Compulsory}
}

Fk:loadTranslationTable{
	["yi__yajiao"] = "涯角",
  [":yi__yajiao"] = "锁定技，你使用虚拟牌指定唯一目标时弃置其一张牌；本回合结束时，你分配一张本回合因此弃置的牌。",
  ["#yi__yajiao-discard"] = "涯角：你须弃置%dest一张牌",
  ["#yi__yajiao-give"] = "涯角：分配其中一张牌",

	["@$yi__yajiao-turn"] = "涯角",
}

yajiao:addEffect(fk.TargetSpecifying, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target == player and data.card and data.card:isVirtual()
			and data:isOnlyTarget(data.to) and #data.to:getCardIds("he") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToChooseCards(player, {
      skill_name = yajiao.name,
      target = data.to,
			prompt = "#yi__yajiao-discard::" .. data.to.id,
      min = 1,
      max = 1,
      flag = "he",
    })
    room:throwCard(cards, yajiao.name, data.to, player)
		room:addTableMark(player, "@$yi__yajiao-turn", cards[1])
  end,
})

yajiao:addEffect(fk.TurnEnd, {
	can_trigger = function(self, event, target, player, data)
		return player:hasSkill(self.name) and target == player and #player:getTableMark("@$yi__yajiao-turn") > 0
	end,
	on_cost = Util.TrueFunc,
	on_use = function(self, event, target, player, data)
		local room = player.room
		local discard_cards = player:getTableMark("@$yi__yajiao-turn") or {}
		room:askToYiji(player, {
			min_num = 1,
			max_num = 1,
			skill_name = yajiao.name,
			targets = room.alive_players,
			cards = discard_cards,
			prompt = "#yi__yajiao-give",
			expand_pile = discard_cards,
    })
	end,
})

return yajiao