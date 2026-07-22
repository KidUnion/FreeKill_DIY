local extension = Package:new("xinsan")
extension.extensionName = "FreeKill_DIY"

extension:loadSkillSkelsByPath("./packages/FreeKill_DIY/pkg/xinsan/skills")

Fk:loadTranslationTable{
  ["xinsan"] = "新三",
}

General:new(extension, "xinsan__dongzhuo", "qun", 4):addSkills { "xinsan__shisuan", "setu" }
Fk:loadTranslationTable{
  ["xinsan__dongzhuo"] = "新三董卓",
  ["designer:xinsan__dongzhuo"] = "KidUnion",

  ["~xinsan__dongzhuo"] = "老臣是天底下命最苦的人，苦的就像是车轮底下的野草，我苦的就像是石头缝里的黄连呐。",
}

General:new(extension, "xinsan__caoren", "wei", 4):addSkills { "qingchao", "jieshou" }
Fk:loadTranslationTable{
  ["xinsan__caoren"] = "新三曹仁",
  ["designer:xinsan__caoren"] = "KidUnion",

  ["~xinsan__caoren"] = "弃城！",
}

General:new(extension, "xinsan__yuanshao", "qun", 4):addSkills { "duoduan", "kuanren" }
Fk:loadTranslationTable{
  ["xinsan__yuanshao"] = "新三袁绍",
  ["designer:xinsan__yuanshao"] = "KidUnion",

  ["~xinsan__yuanshao"] = "此战，罪在于我，连累三军呀！",
}

return extension