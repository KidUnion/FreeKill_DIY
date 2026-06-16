local cifeng = fk.CreateSkill {
  name = "cifeng",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["cifeng"] = "辞锋",
  [":cifeng"] = "锁定技，当你造成或受到伤害后，若伤害来源未横置，你横置之并弃置其一张牌；否则你横置一名角色。",

  ["#cifeng-choose"] = "辞锋：选择一名角色，令其横置",

}

local spec = {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(cifeng.name) 
			and table.find(player.room.alive_players, function(p)
      return not p.chained
    end)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local source = data.from or (event == fk.Damage and player or nil)
    if source and not source.dead and not source.chained then
      source:setChainState(true)
      if not source.dead and not source:isNude() then
        if source == player then
          room:askToDiscard(player, {
            min_num = 1,
            max_num = 1,
            include_equip = true,
            skill_name = cifeng.name,
            cancelable = false,
          })
        else
          local card = room:askToChooseCard(player, {
            target = source,
            flag = "he",
            skill_name = cifeng.name,
          })
          room:throwCard(card, cifeng.name, source, player)
        end
      end
      return
    end
    local to = table.filter(room.alive_players, function(p)
      return not p.chained
    end)
    if #to > 1 then
      to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = to,
        skill_name = cifeng.name,
        prompt = "#cifeng-choose",
        cancelable = false,
      })
    end
    to[1]:setChainState(true)
  end,
}

cifeng:addEffect(fk.Damage, spec)
cifeng:addEffect(fk.Damaged, spec)

return cifeng
