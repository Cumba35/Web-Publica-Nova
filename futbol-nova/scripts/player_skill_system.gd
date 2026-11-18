class_name PlayerSkillSystem
extends RefCounted
const CATALOG_PATH := "res://data/skills/skill_catalog.json"
const MATCH_SKILL_USE_LIMIT := 3
const ALIASES := {"POR":"goalkeeper","GK":"goalkeeper","PORTERO":"goalkeeper","DFC":"defender","LI":"defender","LD":"defender","MCD":"midfielder","MC":"midfielder","MCO":"midfielder","MI":"midfielder","MD":"midfielder","EI":"forward","ED":"forward","DC":"forward"}
static func slots_for_overall(overall:int)->int:
	if overall>90:return 3
	if overall>=80:return 2
	if overall>=70:return 1
	return 0
static func normalize_position(position:String)->String:
	return str(ALIASES.get(position.strip_edges().to_upper(),""))
static func _catalog()->Dictionary:
	if not FileAccess.file_exists(CATALOG_PATH):return {}
	var value:Variant=JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	return value if value is Dictionary else {}
static func _choices(level:int,pos:String)->Array:
	var result:Array=[]
	for entry in _catalog().get("levels",[]):
		if int(entry.get("level",0))==level:
			for skill in entry.get("skills",[]):
				if str(skill.get("position",""))==pos:result.append(skill)
	return result
static func _valid(skill:Dictionary,level:int,pos:String)->bool:
	if int(skill.get("level",0))!=level or str(skill.get("position",""))!=pos:return false
	var stars:=int(skill.get("stars",0))
	return (level==1 and stars>=1 and stars<=2) or (level==2 and stars>=3 and stars<=4) or (level==3 and stars==5)
static func _pick(level:int,pos:String,count:int,rng:RandomNumberGenerator,exclude:Array=[])->Array[String]:
	var pool:Array=[]
	for s in _choices(level,pos):
		if _valid(s,level,pos) and not exclude.has(str(s.get("id",""))):pool.append(s)
	var result:Array[String]=[]
	while not pool.is_empty() and result.size()<count:
		var i:=rng.randi_range(0,pool.size()-1)
		result.append(str(pool[i].get("id","")))
		pool.remove_at(i)
	return result
static func create_legend_profile(overall:int,position:String)->Dictionary:
	return {"schema_version":"2.0.0","mode":"legend","overall":overall,"position_group":normalize_position(position),"stored_by_level":{"level_1":[],"level_2":[],"level_3":[]},"equipped_by_level":{"level_1":null,"level_2":null,"level_3":null},"active_skill_ids":[],"match_skill_uses":0,"match_skill_use_limit":MATCH_SKILL_USE_LIMIT,"match_skill_activation_history":[]}
static func create_standard_profile(overall:int,position:String,rng:RandomNumberGenerator)->Dictionary:
	var pos:=normalize_position(position)
	var equipped:Dictionary={"level_1":null,"level_2":null,"level_3":null}
	var active:Array[String]=[]
	for level in range(1,slots_for_overall(overall)+1):
		var selected:=_pick(level,pos,1,rng)
		if not selected.is_empty():
			equipped["level_%d"%level]=selected[0]
			active.append(selected[0])
	return {"schema_version":"2.0.0","mode":"standard_roster","position_group":pos,"active_skill_ids":active,"stored_skill_ids":[],"equipped_by_level":equipped,"secondary_skills_enabled":false,"match_skill_uses":0,"match_skill_use_limit":MATCH_SKILL_USE_LIMIT,"match_skill_activation_history":[]}
static func grant_random_skill_on_level_up(profile:Dictionary,old_overall:int,new_overall:int,rng:RandomNumberGenerator)->Array[String]:
	var granted:Array[String]=[]
	if profile.get("mode","")!="legend" or new_overall<=old_overall:return granted
	var stored:Dictionary=profile.get("stored_by_level",{})
	var pos:=str(profile.get("position_group",""))
	for level in range(slots_for_overall(old_overall)+1,slots_for_overall(new_overall)+1):
		var key:="level_%d"%level
		var owned:Array=stored.get(key,[])
		var options:=_pick(level,pos,3,rng,owned)
		for id in options:
			if owned.size()<3:owned.append(id);granted.append(id)
		stored[key]=owned
	profile["stored_by_level"]=stored
	profile["overall"]=new_overall
	return granted
static func equip_skill(profile:Dictionary,skill_id:String)->bool:
	if profile.get("mode","")!="legend":return false
	var pos:=str(profile.get("position_group",""))
	for level in range(1,4):
		var key:="level_%d"%level
		if level>slots_for_overall(int(profile.get("overall",0))) or not profile.get("stored_by_level",{}).get(key,[]).has(skill_id):continue
		for s in _choices(level,pos):
			if str(s.get("id",""))==skill_id and _valid(s,level,pos):
				var equipped:Dictionary=profile.get("equipped_by_level",{})
				equipped[key]=skill_id
				profile["equipped_by_level"]=equipped
				var active:Array[String]=[]
				for n in range(1,4):
					var v=equipped.get("level_%d"%n)
					if v!=null and str(v)!="":active.append(str(v))
				profile["active_skill_ids"]=active
				return true
	return false

# Call once when a new match is initialized for this player.
static func reset_match_skill_uses(profile:Dictionary)->void:
	profile["match_skill_uses"]=0
	profile["match_skill_use_limit"]=MATCH_SKILL_USE_LIMIT
	profile["match_skill_activation_history"]=[]

# Called only after the touch UI recognizes a completed circle around the gesture button.
# eligible_skill_ids must be produced by the match/action evaluator after checking each
# skill's own activation conditions, animation window, possession/ball state and cooldown.
static func activate_random_skill(profile:Dictionary,eligible_skill_ids:Array,rng:RandomNumberGenerator,live_ball:bool,player_can_act:bool)->Dictionary:
	var used:=int(profile.get("match_skill_uses",0))
	var remaining:=maxi(0,MATCH_SKILL_USE_LIMIT-used)
	if not live_ball:
		return {"activated":false,"reason":"ball_not_live","uses_remaining":remaining,"skill_id":""}
	if not player_can_act:
		return {"activated":false,"reason":"player_cannot_act","uses_remaining":remaining,"skill_id":""}
	if remaining<=0:
		return {"activated":false,"reason":"match_use_limit_reached","uses_remaining":0,"skill_id":""}
	var active:Array=profile.get("active_skill_ids",[])
	var eligible:Array[String]=[]
	var seen:Dictionary={}
	for raw_id in eligible_skill_ids:
		var skill_id:=str(raw_id)
		if skill_id.is_empty() or seen.has(skill_id) or not active.has(skill_id):
			continue
		if _find_skill(skill_id).is_empty():
			continue
		seen[skill_id]=true
		eligible.append(skill_id)
	if eligible.is_empty():
		return {"activated":false,"reason":"no_eligible_equipped_skill","uses_remaining":remaining,"skill_id":""}
	var chosen:=eligible[rng.randi_range(0,eligible.size()-1)]
	var chosen_skill:=_find_skill(chosen)
	used+=1
	profile["match_skill_uses"]=used
	profile["match_skill_use_limit"]=MATCH_SKILL_USE_LIMIT
	var history:Array=profile.get("match_skill_activation_history",[])
	history.append(chosen)
	profile["match_skill_activation_history"]=history
	return {"activated":true,"reason":"ok","skill_id":chosen,"action_family":str(chosen_skill.get("mechanics",{}).get("action_family","")),"skill":chosen_skill,"uses_remaining":MATCH_SKILL_USE_LIMIT-used,"uses_used":used}

static func _find_skill(skill_id:String)->Dictionary:
	for entry in _catalog().get("levels",[]):
		for skill in entry.get("skills",[]):
			if str(skill.get("id",""))==skill_id:
				return skill
	return {}

static func is_valid_star_rating(stars:int)->bool:return stars>=1 and stars<=5
static func star_label(stars:int)->String:
	if not is_valid_star_rating(stars):return ""
	return "★".repeat(stars)+"☆".repeat(5-stars)
static func get_skill_star_rating(skill_id:String)->int:
	for entry in _catalog().get("levels",[]):
		for s in entry.get("skills",[]):
			if str(s.get("id",""))==skill_id:return int(s.get("stars",0))
	return 0
