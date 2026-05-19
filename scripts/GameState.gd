extends Node

const DEFAULT_SAVE_NAME_PREFIX := "Slot"
const MAX_ACTIVITY_LOGS := 400
const WORK_EXP_PER_SHIFT := 10
const WORK_SHIFT_MINUTES := 210
const GYM_WORKOUT_MINUTES := 60
const GYM_TRAINER_MINUTES := 90
const GYM_TRAINER_COST := 80
const GYM_TRAINER_ENERGY_COST := 24
const INVENTORY_EAT_MINUTES := 10
const JOB_EXP_GROWTH := 1.5
const MAX_FULLNESS := 100
const BASE_MAX_METER := 100
const SKILL_STATS_FOR_METER_SCALING := ["fitness", "strength", "endurance", "education", "intelligence", "discipline", "confidence", "charisma"]
const DAILY_AGING_HEALTH_LOSS_INTERVAL_DAYS := 100
const FOOD_LOSS_PER_HOUR := 5
const HEALTH_LOSS_PER_STARVING_HOUR := 1
const HEALTH_LOSS_PER_ZERO_HAPPINESS_HOUR := 1
const LOW_HEALTH_WARNING_THRESHOLD := 10
const BANK_DAILY_INTEREST_RATE := 0.0025
const MAX_BANK_TRANSACTIONS := 30
const CLINIC_CHECKUP_COST := 25
const CLINIC_TREATMENT_COST := 120
const CLINIC_REST_ADVICE_COST := 0
const CLINIC_CHECKUP_MINUTES := 20
const CLINIC_TREATMENT_MINUTES := 60
const CLINIC_REST_ADVICE_MINUTES := 15
const CASINO_BLACKJACK_MINUTES := 15
const CASINO_SLOTS_MINUTES := 10
const PHONE_CONVERSE_MINUTES := 60
const PHONE_PRAISE_MINUTES := 45
const PHONE_ADVICE_MINUTES := 90
const PHONE_CONVERSE_ENERGY_COST := 6
const PHONE_PRAISE_ENERGY_COST := 5
const PHONE_ADVICE_ENERGY_COST := 8
const MAX_RELATIONSHIP_SCORE := 100

const JOB_DEFINITIONS := {
	"cashier": {
		"name": "Cashier",
		"base_pay": 60,
		"pay_step": 10,
		"base_exp_required": 50,
		"required_credential": "",
		"required_stats": {}
	},
	"sales": {
		"name": "Sales",
		"base_pay": 85,
		"pay_step": 15,
		"base_exp_required": 65,
		"required_credential": "Sales Certificate",
		"required_stats": {"charisma": 20, "confidence": 10}
	},
	"teacher": {
		"name": "Teacher",
		"base_pay": 180,
		"pay_step": 35,
		"base_exp_required": 95,
		"required_credential": "Teaching Credential",
		"required_stats": {"education": 80, "intelligence": 70, "charisma": 50, "discipline": 40}
	},
	"programmer": {
		"name": "Programmer",
		"base_pay": 240,
		"pay_step": 45,
		"base_exp_required": 110,
		"required_credential": "Programming Certificate",
		"required_stats": {"education": 100, "intelligence": 140, "discipline": 80, "confidence": 40}
	},
	"nurse": {
		"name": "Nurse",
		"base_pay": 260,
		"pay_step": 50,
		"base_exp_required": 120,
		"required_credential": "Nursing License",
		"required_stats": {"education": 120, "intelligence": 110, "endurance": 100, "discipline": 80}
	},
	"engineer": {
		"name": "Engineer",
		"base_pay": 330,
		"pay_step": 65,
		"base_exp_required": 145,
		"required_credential": "Engineering Degree",
		"required_stats": {"education": 180, "intelligence": 220, "discipline": 140, "confidence": 80}
	},
	"professor": {
		"name": "Professor",
		"base_pay": 420,
		"pay_step": 75,
		"base_exp_required": 170,
		"required_credential": "Advanced Degree",
		"required_stats": {"education": 280, "intelligence": 320, "charisma": 160, "discipline": 220}
	},
	"doctor": {
		"name": "Doctor",
		"base_pay": 600,
		"pay_step": 100,
		"base_exp_required": 220,
		"required_credential": "Medical Degree",
		"required_stats": {"education": 450, "intelligence": 500, "endurance": 300, "discipline": 350}
	}
}

const JOB_EMPLOYER_CONTACTS := {
	"cashier": {
		"contact_id": "employer_cashier",
		"name": "Morgan",
		"role": "Burger Town Store Manager",
		"advice_stats": ["discipline", "confidence"],
		"personality": "practical"
	},
	"sales": {
		"contact_id": "employer_sales",
		"name": "Riley",
		"role": "Sales Lead",
		"advice_stats": ["charisma", "confidence"],
		"personality": "social"
	},
	"teacher": {
		"contact_id": "employer_teacher",
		"name": "Ms. Carter",
		"role": "School Principal",
		"advice_stats": ["education", "discipline"],
		"personality": "mentor"
	},
	"programmer": {
		"contact_id": "employer_programmer",
		"name": "Alex",
		"role": "Engineering Manager",
		"advice_stats": ["intelligence", "education"],
		"personality": "technical"
	},
	"engineer": {
		"contact_id": "employer_engineer",
		"name": "Frederick",
		"role": "Project Director",
		"advice_stats": ["intelligence", "discipline"],
		"personality": "technical"
	},
	"nurse": {
		"contact_id": "employer_nurse",
		"name": "Nurse Lee",
		"role": "Charge Nurse",
		"advice_stats": ["endurance", "health"],
		"personality": "careful"
	},
	"doctor": {
		"contact_id": "employer_doctor",
		"name": "Dr. Patel",
		"role": "Medical Director",
		"advice_stats": ["intelligence", "health"],
		"personality": "analytical"
	},
	"professor": {
		"contact_id": "employer_professor",
		"name": "Dr. Nguyen",
		"role": "Department Chair",
		"advice_stats": ["education", "intelligence"],
		"personality": "academic"
	}
}

const FOOD_TYPE_HEALTHY := "healthy"
const FOOD_TYPE_UNHEALTHY := "unhealthy"

const STORE_ITEMS := {
	"instant_noodles": {
		"name": "Instant Noodles",
		"category": "food",
		"price": 5,
		"hunger_value": 15,
		"food_type": FOOD_TYPE_UNHEALTHY,
		"health_effect": -1,
		"stress_chance": 25,
		"stress_effect": 1,
		"image": "res://assets/images/items/instant_noodles.png",
		"description": "Cheap emergency food. Restores 15 Food, lowers Health slightly, and has a 25% chance to add Stress +1."
	},
	"protein_bar": {
		"name": "Protein Bar",
		"category": "food",
		"price": 32,
		"hunger_value": 15,
		"food_type": FOOD_TYPE_HEALTHY,
		"health_effect": 1,
		"random_gym_stat": true,
		"random_gym_stat_amount": 1,
		"image": "res://assets/images/items/protein_bar.png",
		"description": "Healthy snack. Restores 15 Food, Health +1, and increases one random gym stat: Fitness, Strength, or Endurance."
	},
	"apple": {
		"name": "Apple",
		"category": "food",
		"price": 10,
		"hunger_value": 5,
		"food_type": FOOD_TYPE_HEALTHY,
		"health_effect": 1,
		"image": "res://assets/images/items/apple.png",
		"description": "Small healthy snack. Restores 5 Food and Health +1."
	},
	"sandwich": {
		"name": "Sandwich",
		"category": "food",
		"price": 20,
		"hunger_value": 25,
		"food_type": FOOD_TYPE_HEALTHY,
		"health_effect": 1,
		"image": "res://assets/images/items/sandwich.png",
		"description": "Balanced meal. Restores 25 Food and Health +1."
	},
	"burger_meal": {
		"name": "Burger Meal",
		"category": "food",
		"price": 22,
		"hunger_value": 55,
		"food_type": FOOD_TYPE_UNHEALTHY,
		"health_effect": -2,
		"happiness_effect": 1,
		"image": "res://assets/images/items/burger_meal.png",
		"description": "Very filling fast food. Restores 55 Food and Happiness +1, but Health -2."
	},
	"salad": {
		"name": "Fresh Salad",
		"category": "food",
		"price": 34,
		"hunger_value": 25,
		"food_type": FOOD_TYPE_HEALTHY,
		"health_effect": 5,
		"image": "res://assets/images/items/salad.png",
		"description": "Very healthy meal. Restores 25 Food and Health +5."
	},
	"healthy_bowl": {
		"name": "Healthy Bowl",
		"category": "food",
		"price": 45,
		"hunger_value": 50,
		"food_type": FOOD_TYPE_HEALTHY,
		"health_effect": 3,
		"image": "res://assets/images/items/healthy_bowl.png",
		"description": "Premium balanced meal. Restores 50 Food and Health +3."
	},
	"family_groceries": {
		"name": "Family Groceries",
		"category": "food",
		"price": 45,
		"hunger_value": 100,
		"food_type": FOOD_TYPE_HEALTHY,
		"health_effect": 1,
		"image": "res://assets/images/items/family_groceries.png",
		"description": "Cheap filling grocery pack. Restores 100 Food and Health +1, but may be too large if you are almost full."
	},
	"energy_drink": {
		"name": "Energy Drink",
		"category": "food",
		"price": 15,
		"hunger_value": 5,
		"food_type": FOOD_TYPE_UNHEALTHY,
		"health_effect": -1,
		"energy_effect": 10,
		"booster_stat": "energy",
		"booster_effect": 10,
		"booster_until_full_text": "Drink Until Energy Full",
		"allow_when_full_for_boost": true,
		"stress_chance": 20,
		"stress_effect": 1,
		"image": "res://assets/images/items/energy_drink.png",
		"description": "Quick caffeine boost. Restores 5 Food and Energy +10, but Health -1 and a 20% chance of Stress +1. Can be used repeatedly until Energy is full."
	},
	"study_guide": {
		"name": "Study Guide",
		"category": "book",
		"price": 120,
		"image": "res://assets/images/items/study_guide.png",
		"retired": true,
		"description": "Retired general study book. It can remain in older saves, but it is no longer sold or used for credential progress."
	},
	"sales_book": {
		"name": "Sales Book",
		"category": "book",
		"price": 150,
		"image": "res://assets/images/items/finance_book.png",
		"description": "Entry-level sales book. Read at School for +3 Sales progress, Charisma +2, and Confidence +2."
	},
	"teaching_credential_book": {
		"name": "Teaching Credential Book",
		"category": "book",
		"price": 220,
		"image": "res://assets/images/items/teaching_credential_book.png",
		"description": "Profession-specific teaching book. Read at School for +3 Teaching progress, Education +2, Intelligence +2, Charisma +2, and Discipline +2."
	},
	"programming_book": {
		"name": "Programming Book",
		"category": "book",
		"price": 360,
		"image": "res://assets/images/items/programming_book.png",
		"description": "Programming career book. Read at School for +3 Programming progress, Education +2, Intelligence +3, Discipline +2, and Confidence +2."
	},
	"fitness_book": {
		"name": "Fitness Book",
		"category": "book",
		"price": 180,
		"image": "res://assets/images/items/fitness_book.png",
		"retired": true,
		"description": "Retired fitness book. It can remain in older saves, but School now uses profession-specific books only."
	},
	"finance_book": {
		"name": "Finance Book",
		"category": "book",
		"price": 260,
		"image": "res://assets/images/items/finance_book.png",
		"retired": true,
		"description": "Retired general finance book. It can remain in older saves, but Sales Book now handles Sales progress."
	},
	"nursing_textbook": {
		"name": "Nursing Textbook",
		"category": "book",
		"price": 650,
		"image": "res://assets/images/items/nursing_textbook.png",
		"description": "Nursing textbook. Read at School for +3 Nursing progress, Education +3, Intelligence +2, Endurance +2, and Discipline +3."
	},
	"engineering_textbook": {
		"name": "Engineering Textbook",
		"category": "book",
		"price": 950,
		"image": "res://assets/images/items/engineering_textbook.png",
		"description": "Advanced engineering book. Read at School for +3 Engineering progress, Education +3, Intelligence +3, Discipline +2, and Confidence +2."
	},
	"advanced_academic_textbook": {
		"name": "Advanced Academic Textbook",
		"category": "book",
		"price": 1500,
		"image": "res://assets/images/items/advanced_academic_textbook.png",
		"description": "Graduate-level academic textbook. Read at School for +3 Advanced Degree progress, Education +4, Intelligence +4, Charisma +3, and Discipline +3."
	},
	"medical_textbook": {
		"name": "Medical Textbook",
		"category": "book",
		"price": 2400,
		"image": "res://assets/images/items/medical_textbook.png",
		"description": "Expensive medical textbook. Read at School for +3 Medical progress, Education +4, Intelligence +4, Endurance +4, and Discipline +4."
	}
}

const INVENTORY_ONLY_ITEMS := {
	"starter_car": {"name": "Starter Car", "category": "vehicle", "image": "res://assets/images/cars/starter_car.png", "description": "Your first basic car.", "use_text": "Equip"},
	"used_sedan": {"name": "Used Sedan", "category": "vehicle", "image": "res://assets/images/cars/used_sedan.png", "description": "Affordable daily driver.", "use_text": "Equip"},
	"compact_car": {"name": "Compact Car", "category": "vehicle", "image": "res://assets/images/cars/compact_car.png", "description": "Small, efficient, and easy to maintain.", "use_text": "Equip"},
	"camaro": {"name": "Camaro", "category": "vehicle", "image": "res://assets/images/cars/camaro.png", "description": "Stylish performance car.", "use_text": "Equip"},
	"mustang": {"name": "Mustang Shelby", "category": "vehicle", "image": "res://assets/images/cars/mustang.png", "description": "High-end dream car.", "use_text": "Equip"},
	"sports_coupe": {"name": "Sports Coupe", "category": "vehicle", "image": "res://assets/images/cars/sports_coupe.png", "description": "Fast, flashy, and expensive.", "use_text": "Equip"},
	"family_suv": {"name": "Family SUV", "category": "vehicle", "image": "res://assets/images/cars/family_suv.png", "description": "Comfortable vehicle with space.", "use_text": "Equip"},
	"electric_car": {"name": "Electric Car", "category": "vehicle", "image": "res://assets/images/cars/electric_car.png", "description": "Modern electric vehicle.", "use_text": "Equip"},
	"sales_certificate": {"name": "Sales Certificate", "category": "credential", "image": "res://assets/images/items/certificate_scroll.png", "description": "Earned at School. Required for Sales jobs.", "use_text": "View", "permanent": true},
	"teaching_credential": {"name": "Teaching Credential", "category": "credential", "image": "res://assets/images/items/certificate_scroll.png", "description": "Earned at School. Required for Teacher jobs.", "use_text": "View", "permanent": true},
	"programming_certificate": {"name": "Programming Certificate", "category": "credential", "image": "res://assets/images/items/certificate_scroll.png", "description": "Earned at School. Required for Programmer jobs.", "use_text": "View", "permanent": true},
	"nursing_license": {"name": "Nursing License", "category": "credential", "image": "res://assets/images/items/certificate_scroll.png", "description": "Earned at School. Required for Nurse jobs.", "use_text": "View", "permanent": true},
	"engineering_degree": {"name": "Engineering Degree", "category": "credential", "image": "res://assets/images/items/diploma.png", "description": "Earned at School. Required for Engineer jobs.", "use_text": "View", "permanent": true},
	"medical_degree": {"name": "Medical Degree", "category": "credential", "image": "res://assets/images/items/diploma.png", "description": "Earned at School. Required for Doctor jobs.", "use_text": "View", "permanent": true},
	"advanced_degree": {"name": "Advanced Degree", "category": "credential", "image": "res://assets/images/items/diploma.png", "description": "Earned at School. Required for Professor jobs.", "use_text": "View", "permanent": true},
	"certificate_scroll": {"name": "Certificate", "category": "special", "image": "res://assets/images/items/certificate_scroll.png", "description": "Generic certificate item.", "use_text": "View", "permanent": true},
	"diploma": {"name": "Diploma", "category": "special", "image": "res://assets/images/items/diploma.png", "description": "Generic diploma item.", "use_text": "View", "permanent": true}
}

const CREDENTIAL_TO_ITEM_ID := {
	"Sales Certificate": "sales_certificate",
	"Teaching Credential": "teaching_credential",
	"Programming Certificate": "programming_certificate",
	"Nursing License": "nursing_license",
	"Engineering Degree": "engineering_degree",
	"Medical Degree": "medical_degree",
	"Advanced Degree": "advanced_degree"
}


const CAR_SHOP_ORDER := [
	"starter_car",
	"used_sedan",
	"compact_car",
	"camaro",
	"sports_coupe",
	"mustang",
	"family_suv",
	"electric_car"
]

const CAR_SHOP_LISTINGS := {
	"starter_car": {
		"price": 0,
		"travel_minutes": 25,
		"travel_cost": 0,
		"style_bonus": 0,
		"comfort_bonus": 0,
		"tier": 0,
		"note": "Basic starter vehicle. It is slow, but it has no travel cost."
	},
	"used_sedan": {
		"price": 2000,
		"travel_minutes": 20,
		"travel_cost": 3,
		"style_bonus": 1,
		"comfort_bonus": 1,
		"tier": 1,
		"note": "Affordable daily driver with low fuel cost."
	},
	"compact_car": {
		"price": 3500,
		"travel_minutes": 18,
		"travel_cost": 2,
		"style_bonus": 1,
		"comfort_bonus": 2,
		"tier": 2,
		"note": "Efficient compact car. Slightly faster than a sedan and cheaper to travel."
	},
	"camaro": {
		"price": 8000,
		"travel_minutes": 9,
		"travel_cost": 9,
		"style_bonus": 3,
		"comfort_bonus": 2,
		"tier": 3,
		"note": "Sporty Camaro. Fast travel, but higher gas cost."
	},
	"sports_coupe": {
		"price": 12000,
		"travel_minutes": 8,
		"travel_cost": 10,
		"style_bonus": 4,
		"comfort_bonus": 2,
		"tier": 4,
		"note": "Fast coupe with strong performance and expensive travel."
	},
	"mustang": {
		"price": 18000,
		"travel_minutes": 7,
		"travel_cost": 12,
		"style_bonus": 5,
		"comfort_bonus": 3,
		"tier": 5,
		"note": "High-end Mustang Shelby. Nearly electric-car speed, but the fuel cost is high."
	},
	"family_suv": {
		"price": 22000,
		"travel_minutes": 12,
		"travel_cost": 6,
		"style_bonus": 3,
		"comfort_bonus": 5,
		"tier": 5,
		"note": "Comfortable SUV. Not the fastest, but it is convenient and comfortable."
	},
	"electric_car": {
		"price": 30000,
		"travel_minutes": 5,
		"travel_cost": 1,
		"style_bonus": 5,
		"comfort_bonus": 5,
		"tier": 6,
		"note": "Modern electric vehicle. Fastest travel and cheapest travel cost."
	}
}

var slot_id: int = 0
var save_name: String = ""
var player_name: String = "Bobby"

var current_hour: int = 8
var current_minute: int = 0
var day: int = 1
var time_of_day: String = "morning"
var money: int = 0
var bank_balance: int = 0

var energy: int = 100
var hunger: int = 0
var health: int = 100
var happiness: int = 50
var stress: int = 0
var fitness: int = 0
var education: int = 0

var strength: int = 0
var intelligence: int = 0
var discipline: int = 0
var confidence: int = 0
var charisma: int = 0
var endurance: int = 0

var current_location: String = "home"
var current_house_id: String = "starter_house"
var current_car_id: String = "none"
var job_id: String = "none"
var jobs: Array[String] = []
var school_level: int = 0

var inventory: Array = []
var flags: Dictionary = {}
var relationships: Dictionary = {}
var activity_logs: Array[Dictionary] = []

var created_unix: int = 0
var last_played_unix: int = 0


func _ready() -> void:
	reset_to_defaults()


func reset_to_defaults() -> void:
	slot_id = 0
	save_name = ""
	player_name = "Bobby"

	current_hour = 8
	current_minute = 0
	time_of_day = "morning"
	day = 1
	money = 0
	bank_balance = 0

	energy = BASE_MAX_METER
	hunger = MAX_FULLNESS
	health = BASE_MAX_METER
	happiness = 50
	stress = 0
	fitness = 0
	education = 0

	strength = 0
	intelligence = 0
	discipline = 0
	confidence = 0
	charisma = 0
	endurance = 0

	current_location = "home"
	current_house_id = "starter_house"
	current_car_id = "starter_car"
	job_id = "cashier"
	jobs = ["cashier"]
	school_level = 0

	inventory = []
	flags = {}
	relationships = {}
	activity_logs = []

	created_unix = 0
	last_played_unix = 0


func create_new_game(slot: int, new_save_name: String = "", new_player_name: String = "Bobby") -> void:
	var data := create_new_game_data(slot, new_save_name, new_player_name)
	load_from_dictionary(data)


func create_new_game_data(slot: int, new_save_name: String = "", new_player_name: String = "Bobby") -> Dictionary:
	var now := Time.get_unix_time_from_system()
	var final_save_name := new_save_name.strip_edges()

	if final_save_name == "":
		final_save_name = "%s %d" % [DEFAULT_SAVE_NAME_PREFIX, slot]

	var final_player_name := new_player_name.strip_edges()
	if final_player_name == "" or final_player_name == "Player":
		final_player_name = "Bobby"

	return {
		"version": SaveManager.SAVE_VERSION,
		"meta": {
			"slot_id": slot,
			"save_name": final_save_name,
			"created_unix": now,
			"last_played_unix": now
		},
		"player": {
			"name": final_player_name,
			"energy": BASE_MAX_METER,
			"hunger": MAX_FULLNESS,
			"health": BASE_MAX_METER,
			"happiness": 50,
			"stress": 0,
			"fitness": 0,
			"education": 0,
			"strength": 0,
			"intelligence": 0,
			"discipline": 0,
			"confidence": 0,
			"charisma": 0,
			"endurance": 0
		},
		"progress": {
			"current_hour": 8,
			"current_minute": 0,
			"day": 1,
			"time_of_day": "morning",
			"money": 0,
			"bank_balance": 0,
			"current_location": "home",
			"current_house_id": "starter_house",
			"current_car_id": "starter_car",
			"job_id": "cashier",
			"jobs": ["cashier"],
			"school_level": 0
		},
		"systems": {
			"inventory": [
				{
					"id": "starter_car",
					"quantity": 1
				},
				{
					"id": "instant_noodles",
					"quantity": 50
				}
			],
			"flags": {
				"job_progress": {
					"cashier": {
						"tier": 1,
						"exp": 0
					}
				},
				"credentials": [],
				"known_employer_contacts": ["employer_cashier"],
				"preferred_phone_contact_id": "",
				"bank_transactions": [],
				"starvation_minutes": 0,
				"low_health_warning_triggered": false,
				"death_triggered": false
			},
			"relationships": {},
			"activity_logs": []
		}
	}


func load_from_dictionary(data: Dictionary) -> void:
	var meta: Dictionary = data.get("meta", {})
	var player: Dictionary = data.get("player", {})
	var progress: Dictionary = data.get("progress", {})
	var systems: Dictionary = data.get("systems", {})

	slot_id = int(meta.get("slot_id", 0))
	save_name = str(meta.get("save_name", ""))
	created_unix = int(meta.get("created_unix", 0))
	last_played_unix = int(meta.get("last_played_unix", 0))
	player_name = str(player.get("name", "Bobby")).strip_edges()
	if player_name == "" or player_name == "Player":
		player_name = "Bobby"

	current_hour = int(progress.get("current_hour", 8))
	current_minute = int(progress.get("current_minute", 0))
	time_of_day = _get_period_from_time(current_hour, current_minute)
	day = int(progress.get("day", 1))
	time_of_day = str(progress.get("time_of_day", "morning"))
	money = int(progress.get("money", 0))
	bank_balance = int(progress.get("bank_balance", 0))
	current_location = str(progress.get("current_location", "home"))
	current_house_id = str(progress.get("current_house_id", "starter_house"))
	current_car_id = str(progress.get("current_car_id", "none"))
	job_id = str(progress.get("job_id", "none"))
	school_level = int(progress.get("school_level", 0))

	energy = int(player.get("energy", 100))
	hunger = int(player.get("hunger", MAX_FULLNESS))
	health = int(player.get("health", 100))
	happiness = int(player.get("happiness", 50))
	stress = int(player.get("stress", 0))
	fitness = int(player.get("fitness", 0))
	education = int(player.get("education", 0))

	strength = int(player.get("strength", 0))
	intelligence = int(player.get("intelligence", 0))
	discipline = int(player.get("discipline", 0))
	confidence = int(player.get("confidence", 0))
	charisma = int(player.get("charisma", 0))
	endurance = int(player.get("endurance", 0))

	var loaded_jobs = progress.get("jobs", [])
	jobs.clear()

	if typeof(loaded_jobs) == TYPE_ARRAY:
		for item in loaded_jobs:
			jobs.append(str(item))

	if jobs.is_empty():
		var fallback_job_id := str(progress.get("job_id", "none"))
		if fallback_job_id != "" and fallback_job_id != "none":
			jobs.append(fallback_job_id)

	inventory = systems.get("inventory", []).duplicate(true)
	flags = systems.get("flags", {}).duplicate(true)
	relationships = systems.get("relationships", {}).duplicate(true)

	var loaded_logs = systems.get("activity_logs", [])
	activity_logs.clear()

	if typeof(loaded_logs) == TYPE_ARRAY:
		for entry in loaded_logs:
			if typeof(entry) == TYPE_DICTIONARY:
				activity_logs.append((entry as Dictionary).duplicate(true))

	_migrate_legacy_job_data()
	_migrate_fullness_meter()
	_ensure_job_system_defaults()
	_ensure_school_progress_defaults()
	_ensure_bank_defaults()
	_ensure_vehicle_defaults()
	_ensure_health_defaults()
	_ensure_casino_defaults()
	_ensure_phone_relationship_defaults()
	_ensure_known_employer_contacts_defaults()

func _format_time_text(hour: int, minute: int) -> String:
	return "%02d:%02d" % [hour, minute]


func get_time_text_12h() -> String:
	var display_hour: int = current_hour % 12
	if display_hour == 0:
		display_hour = 12

	var suffix := "AM"
	if current_hour >= 12:
		suffix = "PM"

	return "%02d:%02d %s" % [display_hour, current_minute, suffix]


func get_happiness_icon() -> String:
	if happiness <= 25:
		return "Low"
	elif happiness < 75:
		return "Mid"
	return "Good"

func _migrate_legacy_job_data() -> void:
	var migrated_job: String = job_id

	if job_id.begins_with("cashier_"):
		migrated_job = "cashier"

	for i in range(jobs.size()):
		var value: String = str(jobs[i])

		match value:
			"Cashier I", "Cashier II", "Cashier III", "Cashier IV":
				jobs[i] = "cashier"
			"Sales I", "Sales II", "Sales III", "Sales IV":
				jobs[i] = "sales"
			"Teacher I", "Teacher II", "Teacher III", "Teacher IV":
				jobs[i] = "teacher"
			"Programmer I", "Programmer II", "Programmer III", "Programmer IV":
				jobs[i] = "programmer"
			"Engineer I", "Engineer II", "Engineer III", "Engineer IV":
				jobs[i] = "engineer"
			"Nurse I", "Nurse II", "Nurse III", "Nurse IV":
				jobs[i] = "nurse"
			"Doctor I", "Doctor II", "Doctor III", "Doctor IV":
				jobs[i] = "doctor"
			"Professor I", "Professor II", "Professor III", "Professor IV":
				jobs[i] = "professor"

	job_id = migrated_job

func _get_period_from_time(hour: int, minute: int) -> String:
	var total_minutes: int = (hour * 60) + minute

	if total_minutes < 720:
		return "morning"
	elif total_minutes < 1020:
		return "afternoon"
	elif total_minutes < 1260:
		return "evening"
	else:
		return "night"
		
func to_dictionary() -> Dictionary:
	var now := int(Time.get_unix_time_from_system())

	if created_unix <= 0:
		created_unix = int(now)

	last_played_unix = int(now)

	return {
		"version": SaveManager.SAVE_VERSION,
		"meta": {
			"slot_id": slot_id,
			"save_name": save_name,
			"created_unix": created_unix,
			"last_played_unix": last_played_unix
		},
		"player": {
			"name": get_player_name(),
			"energy": energy,
			"hunger": hunger,
			"health": health,
			"happiness": happiness,
			"stress": stress,
			"fitness": fitness,
			"education": education,
			"strength": strength,
			"intelligence": intelligence,
			"discipline": discipline,
			"confidence": confidence,
			"charisma": charisma,
			"endurance": endurance
		},
		"progress": {
			"current_hour": current_hour,
			"current_minute": current_minute,
			"day": day,
			"time_of_day": time_of_day,
			"money": money,
			"bank_balance": bank_balance,
			"current_location": current_location,
			"current_house_id": current_house_id,
			"current_car_id": current_car_id,
			"job_id": job_id,
			"jobs": jobs.duplicate(true),
			"school_level": school_level
		},
		"systems": {
			"inventory": inventory.duplicate(true),
			"flags": flags.duplicate(true),
			"relationships": relationships.duplicate(true),
			"activity_logs": activity_logs.duplicate(true)
		}
	}


func get_food_loss_for_minutes(minutes: int) -> int:
	if minutes <= 0:
		return 0

	return int(round((float(minutes) / 60.0) * float(FOOD_LOSS_PER_HOUR)))



func get_lowest_skill_for_meter_scaling() -> int:
	var lowest := 999999
	for stat_name in SKILL_STATS_FOR_METER_SCALING:
		match str(stat_name):
			"fitness":
				lowest = mini(lowest, fitness)
			"strength":
				lowest = mini(lowest, strength)
			"endurance":
				lowest = mini(lowest, endurance)
			"education":
				lowest = mini(lowest, education)
			"intelligence":
				lowest = mini(lowest, intelligence)
			"discipline":
				lowest = mini(lowest, discipline)
			"confidence":
				lowest = mini(lowest, confidence)
			"charisma":
				lowest = mini(lowest, charisma)
	return maxi(0, lowest)


func get_meter_bonus_from_skills() -> int:
	return floori(float(get_lowest_skill_for_meter_scaling()) / 10.0)


func get_max_health() -> int:
	return BASE_MAX_METER + get_meter_bonus_from_skills()


func get_max_energy() -> int:
	return BASE_MAX_METER + get_meter_bonus_from_skills()


func get_max_fullness() -> int:
	return MAX_FULLNESS + get_meter_bonus_from_skills()


func get_meter_scaling_summary() -> String:
	return "Lowest Skill %d -> Max Meters +%d" % [get_lowest_skill_for_meter_scaling(), get_meter_bonus_from_skills()]


func get_daily_aging_health_loss_for_day(day_value: int = -1) -> int:
	var checked_day := day if day_value < 0 else day_value
	return maxi(0, int(floor(float(checked_day) / float(DAILY_AGING_HEALTH_LOSS_INTERVAL_DAYS))))


func _apply_daily_aging_health_loss() -> int:
	var loss := get_daily_aging_health_loss_for_day(day)
	flags["last_daily_aging_health_loss"] = loss
	if loss <= 0:
		return 0

	var old_health := health
	health = clampi(health - loss, 0, get_max_health())
	var actual_loss := old_health - health
	if actual_loss > 0:
		add_log("Aging: Day %d began, Health -%d." % [day, actual_loss], "health")
	return actual_loss


func _add_change(changes: Dictionary, stat_name: String, amount: int) -> void:
	if amount == 0:
		return
	changes[stat_name] = int(changes.get(stat_name, 0)) + amount


func get_stat_display_name(stat_name: String) -> String:
	match stat_name:
		"relationship":
			return "Relationship"
		"money":
			return "Money"
		"bank":
			return "Bank"
		"job_exp", "exp":
			return "EXP"
		"progress", "school_progress":
			return "Progress"
		"food", "hunger":
			return "Food"
		"energy":
			return "Energy"
		"happiness":
			return "Happiness"
		"health":
			return "Health"
		"stress":
			return "Stress"
		"fitness":
			return "Fitness"
		"strength":
			return "Strength"
		"endurance":
			return "Endurance"
		"education":
			return "Education"
		"intelligence":
			return "Intelligence"
		"discipline":
			return "Discipline"
		"confidence":
			return "Confidence"
		"charisma":
			return "Charisma"
		_:
			return stat_name.replace("_", " ").capitalize()


func get_stat_short_name(stat_name: String) -> String:
	match stat_name:
		"relationship":
			return "REL"
		"money":
			return "$"
		"bank":
			return "BANK"
		"job_exp", "exp":
			return "EXP"
		"progress", "school_progress":
			return "PROG"
		"food", "hunger":
			return "FOOD"
		"energy":
			return "ENG"
		"happiness":
			return "HAPPY"
		"health":
			return "HP"
		"stress":
			return "STRESS"
		"fitness":
			return "FIT"
		"strength":
			return "STR"
		"endurance":
			return "END"
		"education":
			return "EDU"
		"intelligence":
			return "INT"
		"discipline":
			return "DISC"
		"confidence":
			return "CONF"
		"charisma":
			return "CHA"
		_:
			return stat_name.substr(0, min(4, stat_name.length())).to_upper()


func _ordered_stat_keys(changes: Dictionary) -> Array[String]:
	var preferred := [
		"relationship", "money", "bank", "job_exp", "exp", "progress", "school_progress",
		"fitness", "strength", "endurance", "education", "intelligence", "discipline", "confidence", "charisma",
		"energy", "food", "hunger", "health", "stress", "happiness"
	]
	var result: Array[String] = []

	for key in preferred:
		if changes.has(key):
			result.append(key)

	for key in changes.keys():
		var key_text := str(key)
		if not result.has(key_text):
			result.append(key_text)

	return result


func _format_signed_money(amount: int) -> String:
	if amount >= 0:
		return "+$%d" % amount

	return "-$%d" % abs(amount)


func format_stat_changes_short(changes: Dictionary, positive_only: bool = false, max_parts: int = 6) -> String:
	var parts: Array[String] = []

	for key in _ordered_stat_keys(changes):
		var amount: int = int(changes.get(key, 0))

		if amount == 0:
			continue

		if positive_only and amount < 0:
			continue

		var part := ""

		if key == "money":
			part = _format_signed_money(amount)
		elif key == "bank":
			part = "Bank %s" % _format_signed_money(amount)
		elif key == "job_exp" or key == "exp":
			part = "%+d EXP" % amount
		elif key == "progress" or key == "school_progress":
			part = "Progress %+d" % amount
		else:
			part = "%+d %s" % [amount, get_stat_short_name(key)]

		parts.append(part)

		if max_parts > 0 and parts.size() >= max_parts:
			break

	if parts.is_empty():
		return "No stat changes"

	return ", ".join(parts)


func format_stat_changes_full(changes: Dictionary) -> String:
	var parts: Array[String] = []

	for key in _ordered_stat_keys(changes):
		var amount: int = int(changes.get(key, 0))

		if amount == 0:
			continue

		if key == "money":
			parts.append("Money %s" % _format_signed_money(amount))
		elif key == "bank":
			parts.append("Bank %s" % _format_signed_money(amount))
		elif key == "job_exp" or key == "exp":
			parts.append("Job EXP %+d" % amount)
		elif key == "progress" or key == "school_progress":
			parts.append("School Progress %+d" % amount)
		else:
			parts.append("%s %+d" % [get_stat_display_name(key), amount])

	if parts.is_empty():
		return "No stat changes"

	return " | ".join(parts)


func _apply_food_and_starvation_for_minutes(minutes: int) -> int:
	if minutes <= 0:
		return 0

	_ensure_health_defaults()

	var max_food := get_max_fullness()
	var old_food: int = hunger
	var food_loss: int = get_food_loss_for_minutes(minutes)
	var starving_minutes: int = 0

	if old_food <= 0:
		hunger = 0
		starving_minutes = minutes
	elif food_loss >= old_food:
		var minutes_until_empty: int = ceili((float(old_food) / float(FOOD_LOSS_PER_HOUR)) * 60.0)
		starving_minutes = maxi(0, minutes - minutes_until_empty)
		hunger = 0
	else:
		hunger = clampi(old_food - food_loss, 0, max_food)
		flags["starvation_minutes"] = 0

	if starving_minutes <= 0:
		return 0

	var accumulated: int = maxi(0, int(flags.get("starvation_minutes", 0))) + starving_minutes
	var health_loss: int = int(floor(float(accumulated) / 60.0)) * HEALTH_LOSS_PER_STARVING_HOUR
	flags["starvation_minutes"] = accumulated % 60

	if health_loss > 0:
		health = clampi(health - health_loss, 0, get_max_health())
		flags["last_starvation_health_loss"] = health_loss
	else:
		flags["last_starvation_health_loss"] = 0

	return health_loss



func _apply_zero_happiness_health_loss_for_minutes(minutes: int) -> int:
	if minutes <= 0:
		return 0

	_ensure_health_defaults()

	# Only Happiness at 0 should directly damage Health. High Stress drains
	# Happiness separately; it should not count as zero-happiness damage until
	# Happiness has actually reached 0.
	if happiness > 0:
		flags["zero_happiness_minutes"] = 0
		flags["last_zero_happiness_health_loss"] = 0
		return 0

	var accumulated: int = maxi(0, int(flags.get("zero_happiness_minutes", 0))) + minutes
	var damage_interval_minutes := 240
	var health_loss: int = int(floor(float(accumulated) / float(damage_interval_minutes))) * HEALTH_LOSS_PER_ZERO_HAPPINESS_HOUR
	flags["zero_happiness_minutes"] = accumulated % damage_interval_minutes

	if health_loss <= 0:
		flags["last_zero_happiness_health_loss"] = 0
		return 0

	var old_health := health
	health = clampi(health - health_loss, 0, get_max_health())
	var actual_loss := old_health - health
	flags["last_zero_happiness_health_loss"] = actual_loss

	if actual_loss > 0:
		add_log("Low Mood: Happiness stayed at 0 during an action, Health -%d." % actual_loss, "health")

	return actual_loss


func _apply_stress_happiness_penalty_for_minutes(minutes: int) -> int:
	if minutes <= 0:
		return 0

	_ensure_health_defaults()

	var loss_per_hour := 0
	if stress >= 95:
		loss_per_hour = 2
	elif stress >= 80:
		loss_per_hour = 1
	else:
		flags["stress_happiness_minutes"] = 0
		flags["last_stress_happiness_loss"] = 0
		return 0

	var accumulated: int = maxi(0, int(flags.get("stress_happiness_minutes", 0))) + minutes
	var hours: int = int(floor(float(accumulated) / 60.0))
	flags["stress_happiness_minutes"] = accumulated % 60

	if hours <= 0:
		flags["last_stress_happiness_loss"] = 0
		return 0

	var old_happiness := happiness
	happiness = clampi(happiness - (hours * loss_per_hour), 0, 100)
	var actual_loss := old_happiness - happiness
	flags["last_stress_happiness_loss"] = actual_loss
	if actual_loss > 0:
		add_log("Stress: high Stress drained Happiness -%d during time passing." % actual_loss, "health")
	return actual_loss

func advance_time(minutes: int) -> void:
	_apply_food_and_starvation_for_minutes(minutes)
	_apply_zero_happiness_health_loss_for_minutes(minutes)
	_apply_stress_happiness_penalty_for_minutes(minutes)

	var total_minutes: int = (current_hour * 60) + current_minute + minutes

	while total_minutes >= 1440:
		total_minutes -= 1440
		day += 1
		_apply_daily_aging_health_loss()

	current_hour = floori(float(total_minutes) / 60.0)
	current_minute = total_minutes % 60
	time_of_day = _get_period_from_time(current_hour, current_minute)
	_ensure_health_defaults()
	

func sleep_to_next_day() -> Dictionary:
	var start_time: String = _format_time_text(current_hour, current_minute)
	var old_energy: int = energy
	var old_stress: int = stress
	var old_happiness: int = happiness
	var old_food: int = hunger
	var old_health: int = health
	var old_fitness: int = fitness
	var old_strength: int = strength
	var old_endurance: int = endurance

	# Auto-eat before sleep so the player does not enter the 8-hour sleep period hungry.
	# This now uses the same food-effect path as manual eating, so Protein Bars still
	# grant their random Fitness/Strength/Endurance bonus when auto-eaten.
	var pre_sleep_food_result: Dictionary = consume_food_until_full()

	# Recover mood before time passes so high Stress / low Happiness do not damage Health
	# before the sleep recovery is applied.
	stress = clampi(stress - 25, 0, 100)
	happiness = clampi(happiness + 20, 0, 100)

	# Sleep still passes time, so Food naturally drops during the 8 hours.
	advance_time(480)
	energy = get_max_energy()

	# Auto-eat again after waking up. This tops the player back up after sleep's Food drain,
	# while still using consume_food_until_full() so it will not overfill or waste large food.
	var wake_food_result: Dictionary = consume_food_until_full()

	var pre_restored: int = int(pre_sleep_food_result.get("restored", 0))
	var wake_restored: int = int(wake_food_result.get("restored", 0))
	var total_restored: int = pre_restored + wake_restored
	var pre_consumed: Array = pre_sleep_food_result.get("consumed", [])
	var wake_consumed: Array = wake_food_result.get("consumed", [])
	var consumed: Array = []
	consumed.append_array(pre_consumed)
	consumed.append_array(wake_consumed)

	var interest_earned: int = apply_bank_daily_interest()
	var changes := {
		"energy": energy - old_energy,
		"stress": stress - old_stress,
		"happiness": happiness - old_happiness,
		"food": hunger - old_food,
		"health": health - old_health,
		"fitness": fitness - old_fitness,
		"strength": strength - old_strength,
		"endurance": endurance - old_endurance,
		"bank": interest_earned
	}
	var full_text := format_stat_changes_full(changes)
	var hud_text := "Sleep: Energy %d, Mood %+d:%+d" % [energy, happiness - old_happiness, stress - old_stress]
	if interest_earned > 0:
		hud_text = "Sleep: Energy %d, Bank +$%d" % [energy, interest_earned]
	if fitness != old_fitness or strength != old_strength or endurance != old_endurance:
		hud_text = "Sleep: Energy %d, Protein bonus applied" % energy

	var before_text := ", ".join(pre_consumed) if not pre_consumed.is_empty() else "No food eaten"
	var wake_text := ", ".join(wake_consumed) if not wake_consumed.is_empty() else "No food eaten"
	var before_effects := str(pre_sleep_food_result.get("effects_text", ""))
	var wake_effects := str(wake_food_result.get("effects_text", ""))
	if before_effects != "" and before_effects != "No stat changes" and before_text != "No food eaten":
		before_text = "%s (%s)" % [before_text, before_effects]
	if wake_effects != "" and wake_effects != "No stat changes" and wake_text != "No food eaten":
		wake_text = "%s (%s)" % [wake_text, wake_effects]
	add_log_at_time("Sleep: %s. Auto-eat before sleep: %s. Auto-eat after waking: %s." % [full_text, before_text, wake_text], "sleep", start_time)

	var food_text := "No food eaten"
	if total_restored > 0:
		food_text = "Food +%d from auto-eating" % total_restored
	if fitness != old_fitness or strength != old_strength or endurance != old_endurance:
		food_text = "%s | %s" % [food_text, format_stat_changes_short({
			"fitness": fitness - old_fitness,
			"strength": strength - old_strength,
			"endurance": endurance - old_endurance
		}, true, 3)]
	var interest_text := "No bank interest"
	if interest_earned > 0:
		interest_text = "Bank +$%d" % interest_earned

	return {
		"headline": "You slept for 8 hours.",
		"hud_message": hud_text,
		"toast_message": "%s | %s" % [food_text, interest_text],
		"money_earned": interest_earned,
		"exp_earned": 0,
		"stat_changes": changes,
		"stat_effects": full_text,
		"promotion": {},
		"food_consumed": consumed,
		"food_consumed_before_sleep": pre_consumed,
		"food_consumed_after_waking": wake_consumed,
		"bank_interest": interest_earned
	}

func do_work() -> Dictionary:
	_ensure_job_system_defaults()
	var current_job: String = get_primary_job_id()
	var pay: int = get_current_work_pay()
	var start_time_text: String = _format_time_text(current_hour, current_minute)
	var old_job_name: String = get_primary_job_name()
	var food_loss: int = get_food_loss_for_minutes(WORK_SHIFT_MINUTES)
	money += pay
	energy = clampi(energy - 20, 0, get_max_energy())
	stress = clampi(stress + 8, 0, 100)
	happiness = clampi(happiness - 1, 0, 100)
	var relationship_bonus_percent: int = get_job_work_exp_bonus_percent(current_job)
	var exp_earned: int = get_work_exp_with_relationship_bonus(current_job, WORK_EXP_PER_SHIFT)
	var random_work_stat_changes: Dictionary = _roll_work_related_stat_gain(current_job)
	for stat_name in random_work_stat_changes.keys():
		_add_to_named_stat(str(stat_name), int(random_work_stat_changes.get(stat_name, 0)))

	var exp_result: Dictionary = add_job_exp(current_job, exp_earned)
	var promotion: Dictionary = {}
	if bool(exp_result.get("success", false)):
		var new_job_name: String = get_primary_job_name()
		add_log_at_time("Promotion: %s -> %s." % [old_job_name, new_job_name], "promotion", start_time_text)
		promotion = {"success": true, "old_rank": old_job_name, "new_rank": new_job_name, "old_pay": get_job_pay(current_job, int(exp_result.get("old_tier", 1))), "new_pay": get_job_pay(current_job, int(exp_result.get("new_tier", 1)))}
	advance_time(WORK_SHIFT_MINUTES)
	var current_exp: int = get_job_exp(current_job)
	var next_requirement: int = get_job_exp_required_for_next_tier(current_job)
	var changes := {"money": pay, "job_exp": exp_earned, "energy": -20, "food": -food_loss, "stress": 8, "happiness": -1}
	for stat_name in random_work_stat_changes.keys():
		_add_change(changes, str(stat_name), int(random_work_stat_changes.get(stat_name, 0)))
	var positive_text := format_stat_changes_short(changes, true, 5)
	var full_text := format_stat_changes_full(changes)
	add_log_at_time("Work (%s): %s." % [old_job_name, full_text], "work", start_time_text)
	return {"headline": "Work Complete (%s)" % old_job_name, "hud_message": "Work: %s" % positive_text, "toast_message": positive_text, "money_earned": pay, "exp_earned": exp_earned, "stat_changes": changes, "stat_effects": full_text, "promotion": promotion, "job_name": get_primary_job_name(), "job_exp": current_exp, "next_promotion_requirement": next_requirement, "job_tier": get_job_tier(current_job), "minutes_spent": WORK_SHIFT_MINUTES, "relationship_bonus_percent": relationship_bonus_percent}

func do_study() -> Dictionary:
	var food_loss: int = get_food_loss_for_minutes(120)
	education = clampi(education + 1, 0, 999)
	intelligence = clampi(intelligence + 1, 0, 999)
	discipline = clampi(discipline + 1, 0, 999)
	energy = clampi(energy - 15, 0, get_max_energy())
	stress = clampi(stress + 8, 0, 100)
	advance_time(120)
	var changes := {"education": 1, "intelligence": 1, "discipline": 1, "energy": -15, "food": -food_loss, "stress": 8}
	var positive_text := format_stat_changes_short(changes, true, 4)
	var full_text := format_stat_changes_full(changes)
	add_log("Study: %s." % full_text, "study")
	return {"headline": "Study Complete", "hud_message": "Study: %s" % positive_text, "toast_message": positive_text, "money_earned": 0, "exp_earned": 0, "stat_changes": changes, "stat_effects": full_text, "promotion": {}}

func do_gym() -> Dictionary:
	var food_loss: int = get_food_loss_for_minutes(GYM_WORKOUT_MINUTES)
	fitness = clampi(fitness + 1, 0, 999)
	strength = clampi(strength + 1, 0, 999)
	endurance = clampi(endurance + 1, 0, 999)
	confidence = clampi(confidence + 1, 0, 999)
	energy = clampi(energy - 14, 0, get_max_energy())
	stress = clampi(stress - 5, 0, 100)
	happiness = clampi(happiness + 3, 0, 100)
	advance_time(GYM_WORKOUT_MINUTES)
	var changes := {"fitness": 1, "strength": 1, "endurance": 1, "confidence": 1, "energy": -14, "food": -food_loss, "stress": -5, "happiness": 3}
	var positive_text := format_stat_changes_short(changes, true, 4)
	var full_text := format_stat_changes_full(changes)
	add_log("Gym Workout: %s." % full_text, "gym")
	return {"headline": "Fitness Improved", "hud_message": "Gym: %s" % positive_text, "toast_message": positive_text, "money_earned": 0, "exp_earned": 0, "stat_changes": changes, "stat_effects": full_text, "promotion": {}, "minutes_spent": GYM_WORKOUT_MINUTES}

func do_gym_trainer() -> Dictionary:
	if money < GYM_TRAINER_COST:
		return {"success": false, "headline": "Trainer Unavailable", "hud_message": "Trainer: need $%d" % GYM_TRAINER_COST, "toast_message": "Need $%d for trainer." % GYM_TRAINER_COST, "message": "You need $%d to work out with a trainer." % GYM_TRAINER_COST, "stat_changes": {}, "stat_effects": "No changes", "promotion": {}, "minutes_spent": 0}
	if not can_perform_action(GYM_TRAINER_ENERGY_COST):
		return {"success": false, "headline": "Too Tired", "hud_message": "Trainer: need Energy", "toast_message": "Need at least %d Energy." % GYM_TRAINER_ENERGY_COST, "message": "You need at least %d Energy to work out with a trainer." % GYM_TRAINER_ENERGY_COST, "stat_changes": {}, "stat_effects": "No changes", "promotion": {}, "minutes_spent": 0}

	var food_loss: int = get_food_loss_for_minutes(GYM_TRAINER_MINUTES)
	money = maxi(0, money - GYM_TRAINER_COST)
	fitness = clampi(fitness + 2, 0, 999)
	strength = clampi(strength + 2, 0, 999)
	endurance = clampi(endurance + 2, 0, 999)
	confidence = clampi(confidence + 1, 0, 999)
	charisma = clampi(charisma + 1, 0, 999)
	energy = clampi(energy - GYM_TRAINER_ENERGY_COST, 0, get_max_energy())
	stress = clampi(stress - 8, 0, 100)
	happiness = clampi(happiness + 8, 0, 100)
	advance_time(GYM_TRAINER_MINUTES)
	var changes := {"money": -GYM_TRAINER_COST, "fitness": 2, "strength": 2, "endurance": 2, "confidence": 1, "charisma": 1, "energy": -GYM_TRAINER_ENERGY_COST, "food": -food_loss, "stress": -8, "happiness": 8}
	var positive_text := format_stat_changes_short(changes, true, 6)
	var full_text := format_stat_changes_full(changes)
	add_log("Trainer Workout: %s." % full_text, "gym")
	return {"success": true, "headline": "Trainer Session Complete", "hud_message": "Trainer: %s" % positive_text, "toast_message": positive_text, "money_earned": 0, "exp_earned": 0, "stat_changes": changes, "stat_effects": full_text, "promotion": {}, "minutes_spent": GYM_TRAINER_MINUTES}

func get_job_related_stats(job: String) -> Array[String]:
	match job:
		"cashier":
			return ["discipline", "endurance", "charisma"]
		"sales":
			return ["charisma", "confidence", "discipline"]
		"teacher":
			return ["education", "charisma", "discipline"]
		"programmer":
			return ["intelligence", "education", "discipline"]
		"nurse":
			return ["education", "endurance", "discipline"]
		"engineer":
			return ["intelligence", "education", "discipline"]
		"professor":
			return ["education", "intelligence", "discipline", "charisma"]
		"doctor":
			return ["intelligence", "education", "endurance", "discipline"]
		_:
			return ["discipline"]

func _roll_work_related_stat_gain(job: String) -> Dictionary:
	var changes: Dictionary = {}
	var options := get_job_related_stats(job)
	if options.is_empty():
		return changes
	var stat_name := str(options[randi_range(0, options.size() - 1)])
	changes[stat_name] = 1
	return changes

func _ensure_burger_town_defaults() -> void:
	if not flags.has("burger_town") or typeof(flags["burger_town"]) != TYPE_DICTIONARY:
		flags["burger_town"] = {
			"streak": 0,
			"best_streak": 0,
			"wins": 0,
			"attempts": 0
		}

	var data: Dictionary = flags["burger_town"]
	data["streak"] = maxi(0, int(data.get("streak", 0)))
	data["best_streak"] = maxi(0, int(data.get("best_streak", 0)))
	data["wins"] = maxi(0, int(data.get("wins", 0)))
	data["attempts"] = maxi(0, int(data.get("attempts", 0)))
	flags["burger_town"] = data


func get_burger_town_data() -> Dictionary:
	_ensure_burger_town_defaults()
	return (flags.get("burger_town", {}) as Dictionary).duplicate(true)


func get_burger_streak() -> int:
	_ensure_burger_town_defaults()
	return int((flags["burger_town"] as Dictionary).get("streak", 0))


func get_best_burger_streak() -> int:
	_ensure_burger_town_defaults()
	return int((flags["burger_town"] as Dictionary).get("best_streak", 0))



func can_play_burger_minigame() -> Dictionary:
	if is_dead():
		return {"success": false, "message": "You cannot work at Burger Town while Health is 0."}
	if happiness <= 0:
		return {"success": false, "message": "You are too unhappy to keep working Burger Town right now. Rest, sleep, eat, or visit the Clinic first."}
	if energy <= 0:
		return {"success": false, "message": "You are too exhausted to work Burger Town right now."}
	return {"success": true, "message": "Ready for Burger Town."}


func complete_burger_minigame(success: bool) -> Dictionary:
	_ensure_job_system_defaults()
	_ensure_burger_town_defaults()

	var play_check := can_play_burger_minigame()
	if not bool(play_check.get("success", false)):
		return {
			"success": false,
			"headline": "Burger Town unavailable.",
			"message": str(play_check.get("message", "You cannot work Burger Town right now.")),
			"hud_message": "Burger Town: unavailable",
			"toast_message": str(play_check.get("message", "Unavailable.")),
			"stat_changes": {},
			"stat_effects": "No changes"
		}

	var start_time_text: String = _format_time_text(current_hour, current_minute)
	var burger_job := "cashier"
	var old_job_name: String = get_job_display_name(burger_job)
	var burger_data: Dictionary = flags["burger_town"]
	burger_data["attempts"] = int(burger_data.get("attempts", 0)) + 1

	var money_earned: int = 0
	var exp_earned: int = 0
	var minutes_spent: int = 0
	var energy_change: int = 0
	var stress_change: int = 0
	var happiness_change: int = 0
	var discipline_change: int = 0
	var confidence_change: int = 0
	var headline := ""
	var category := "burger_town"

	if success:
		var cashier_tier: int = get_job_tier(burger_job)
		money_earned = 125 + ((cashier_tier - 1) * 30)
		exp_earned = 40
		minutes_spent = 30
		energy_change = -8
		stress_change = 2
		happiness_change = 3
		discipline_change = 1
		confidence_change = 1
		burger_data["streak"] = int(burger_data.get("streak", 0)) + 1
		burger_data["wins"] = int(burger_data.get("wins", 0)) + 1
		burger_data["best_streak"] = maxi(int(burger_data.get("best_streak", 0)), int(burger_data.get("streak", 0)))
		headline = "Well done! Burger order completed."
	else:
		money_earned = 0
		exp_earned = 10
		minutes_spent = 10
		energy_change = -3
		stress_change = 4
		happiness_change = -1
		discipline_change = 0
		confidence_change = 0
		burger_data["streak"] = 0
		headline = "Wrong order! Try again."

	flags["burger_town"] = burger_data

	var food_loss: int = get_food_loss_for_minutes(minutes_spent)
	money += money_earned
	energy = clampi(energy + energy_change, 0, get_max_energy())
	stress = clampi(stress + stress_change, 0, 100)
	happiness = clampi(happiness + happiness_change, 0, 100)
	discipline = clampi(discipline + discipline_change, 0, 999)
	confidence = clampi(confidence + confidence_change, 0, 999)

	var exp_result: Dictionary = add_job_exp(burger_job, exp_earned)
	var promotion: Dictionary = {}
	if bool(exp_result.get("success", false)):
		var new_job_name: String = get_job_display_name(burger_job)
		add_log_at_time("Promotion: %s -> %s." % [old_job_name, new_job_name], "promotion", start_time_text)
		promotion = {
			"success": true,
			"old_rank": old_job_name,
			"new_rank": new_job_name,
			"old_pay": get_job_pay(burger_job, int(exp_result.get("old_tier", 1))),
			"new_pay": get_job_pay(burger_job, int(exp_result.get("new_tier", 1)))
		}

	advance_time(minutes_spent)

	var changes := {
		"money": money_earned,
		"job_exp": exp_earned,
		"discipline": discipline_change,
		"confidence": confidence_change,
		"energy": energy_change,
		"food": -food_loss,
		"stress": stress_change,
		"happiness": happiness_change
	}

	var positive_text := format_stat_changes_short(changes, true, 6)
	var full_text := format_stat_changes_full(changes)
	var outcome_text := "Success" if success else "Wrong Order"
	add_log_at_time("Burger Town %s: %s. Cashier EXP applied. Streak: %d." % [outcome_text, full_text, get_burger_streak()], category, start_time_text)

	return {
		"success": success,
		"headline": headline,
		"message": headline,
		"hud_message": "Burger: %s" % positive_text,
		"toast_message": "%s | Cashier EXP | Streak %d" % [positive_text, get_burger_streak()],
		"money_earned": money_earned,
		"exp_earned": exp_earned,
		"stat_changes": changes,
		"stat_effects": full_text,
		"minutes_spent": minutes_spent,
		"promotion": promotion,
		"job_name": get_job_display_name(burger_job),
		"job_exp": get_job_exp(burger_job),
		"next_promotion_requirement": get_job_exp_required_for_next_tier(burger_job),
		"burger_streak": get_burger_streak(),
		"best_burger_streak": get_best_burger_streak()
	}

func go_to_location(location_id: String) -> void:
	current_location = location_id.to_lower()


func can_perform_action(min_energy: int = 1) -> bool:
	if is_dead():
		return false
	return energy >= min_energy


func _format_meter_value(value: int, max_value: int) -> String:
	if max_value <= BASE_MAX_METER:
		return str(value)
	return "%d/%d" % [value, max_value]


func get_top_bar_strings() -> Dictionary:
	return {
		"day": "Day: %d" % day,
		"time": get_time_text_12h(),
		"money": "$%d" % money,
		"energy": _format_meter_value(energy, get_max_energy()),
		"hunger": _format_meter_value(hunger, get_max_fullness()),
		"happiness": "%d:%d" % [happiness, stress],
		"health": _format_meter_value(health, get_max_health())
	}

func get_current_week() -> int:
	return floori(float(day - 1) / 7.0) + 1


func add_log(text: String, category: String = "general") -> void:
	var entry: Dictionary = {
		"week": get_current_week(),
		"day": day,
		"time_text": _format_time_text(current_hour, current_minute),
		"time_period": time_of_day,
		"text": text,
		"category": category,
		"unix": Time.get_unix_time_from_system()
	}

	activity_logs.append(entry)

	while activity_logs.size() > MAX_ACTIVITY_LOGS:
		activity_logs.remove_at(0)

func add_log_at_time(text: String, category: String, custom_time_text: String) -> void:
	var entry: Dictionary = {
		"week": get_current_week(),
		"day": day,
		"time_text": custom_time_text,
		"time_period": time_of_day,
		"text": text,
		"category": category,
		"unix": Time.get_unix_time_from_system()
	}

	activity_logs.append(entry)

	while activity_logs.size() > MAX_ACTIVITY_LOGS:
		activity_logs.remove_at(0)

func get_logs_for_week(week: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in activity_logs:
		if int(entry.get("week", 0)) == week:
			result.append(entry)
	return result


func get_max_logged_week() -> int:
	var max_week := 1
	for entry in activity_logs:
		max_week = maxi(max_week, int(entry.get("week", 1)))
	return maxi(max_week, get_current_week())

func _migrate_fullness_meter() -> void:
	if not flags.has("fullness_meter_migrated"):
		if hunger <= 0:
			hunger = get_max_fullness()
		else:
			hunger = clampi(hunger, 0, get_max_fullness())
		flags["fullness_meter_migrated"] = true
	else:
		hunger = clampi(hunger, 0, get_max_fullness())



func _ensure_vehicle_defaults() -> void:
	if not owns_vehicle("starter_car"):
		add_inventory_item("starter_car", 1)

	if current_car_id == "" or current_car_id == "none":
		current_car_id = "starter_car"

	if not owns_vehicle(current_car_id):
		current_car_id = "starter_car"


func _ensure_bank_defaults() -> void:
	if bank_balance < 0:
		bank_balance = 0

	if not flags.has("bank_transactions") or typeof(flags["bank_transactions"]) != TYPE_ARRAY:
		flags["bank_transactions"] = []


func _ensure_health_defaults() -> void:
	var max_health := get_max_health()
	var max_food := get_max_fullness()
	var max_energy := get_max_energy()

	health = clampi(health, 0, max_health)
	hunger = clampi(hunger, 0, max_food)
	energy = clampi(energy, 0, max_energy)

	if not flags.has("starvation_minutes"):
		flags["starvation_minutes"] = 0

	flags["starvation_minutes"] = maxi(0, int(flags.get("starvation_minutes", 0)))

	if not flags.has("zero_happiness_minutes"):
		flags["zero_happiness_minutes"] = 0

	flags["zero_happiness_minutes"] = maxi(0, int(flags.get("zero_happiness_minutes", 0)))

	if not flags.has("last_zero_happiness_health_loss"):
		flags["last_zero_happiness_health_loss"] = 0

	if not flags.has("stress_happiness_minutes"):
		flags["stress_happiness_minutes"] = 0

	flags["stress_happiness_minutes"] = maxi(0, int(flags.get("stress_happiness_minutes", 0)))

	if not flags.has("last_stress_happiness_loss"):
		flags["last_stress_happiness_loss"] = 0

	if not flags.has("low_health_warning_triggered"):
		flags["low_health_warning_triggered"] = false

	if not flags.has("death_triggered"):
		flags["death_triggered"] = false

	if not flags.has("last_daily_aging_health_loss"):
		flags["last_daily_aging_health_loss"] = 0

	if hunger > 0:
		flags["starvation_minutes"] = 0

	if happiness > 0:
		flags["zero_happiness_minutes"] = 0

	if stress < 50:
		flags["stress_happiness_minutes"] = 0

	if health > LOW_HEALTH_WARNING_THRESHOLD:
		flags["low_health_warning_triggered"] = false

	if health > 0:
		flags["death_triggered"] = false


func is_dead() -> bool:
	_ensure_health_defaults()
	return health <= 0


func is_low_health() -> bool:
	_ensure_health_defaults()
	return health > 0 and health <= LOW_HEALTH_WARNING_THRESHOLD


func consume_health_alert() -> Dictionary:
	_ensure_health_defaults()

	if health <= 0:
		if not bool(flags.get("death_triggered", false)):
			flags["death_triggered"] = true
			flags["low_health_warning_triggered"] = true
			add_log("Death: Health reached 0. Reincarnation is required to continue.", "death")
			return {
				"death": true,
				"low_health": false,
				"message": "Health reached 0. Your life has ended.",
				"hud_message": "Health 0: Reincarnation required.",
				"toast_message": "Health reached 0. Reincarnate to begin again."
			}
		return {}

	if health <= LOW_HEALTH_WARNING_THRESHOLD:
		if not bool(flags.get("low_health_warning_triggered", false)):
			flags["low_health_warning_triggered"] = true
			add_log("Warning: Health dropped to %d. Visit the Clinic, eat healthy food, or rest." % health, "health")
			return {
				"death": false,
				"low_health": true,
				"message": "Critical Health: %d / %d." % [health, get_max_health()],
				"hud_message": "Critical Health: %d. Visit the Clinic soon." % health,
				"toast_message": "Health is critically low. Visit the Clinic soon."
			}
		return {}

	flags["low_health_warning_triggered"] = false
	flags["death_triggered"] = false
	return {}


func get_pending_starvation_minutes() -> int:
	_ensure_health_defaults()
	return maxi(0, int(flags.get("starvation_minutes", 0)))


func get_pending_zero_happiness_minutes() -> int:
	_ensure_health_defaults()
	return maxi(0, int(flags.get("zero_happiness_minutes", 0)))


func get_last_zero_happiness_health_loss() -> int:
	_ensure_health_defaults()
	return maxi(0, int(flags.get("last_zero_happiness_health_loss", 0)))


func get_bank_balance() -> int:
	return maxi(0, bank_balance)


func get_net_worth() -> int:
	return maxi(0, money) + get_bank_balance()


func get_bank_daily_interest_percent_text() -> String:
	return "%.2f%%" % (BANK_DAILY_INTEREST_RATE * 100.0)


func get_bank_interest_preview() -> int:
	if bank_balance <= 0:
		return 0

	return int(round(float(bank_balance) * BANK_DAILY_INTEREST_RATE))


func deposit_to_bank(amount: int) -> Dictionary:
	_ensure_bank_defaults()

	if amount <= 0:
		return {"success": false, "message": "Enter an amount greater than $0."}

	if amount > money:
		return {"success": false, "message": "You do not have enough wallet money to deposit $%d." % amount}

	money -= amount
	bank_balance += amount
	_add_bank_transaction("Deposited $%d." % amount)
	add_log("Deposited $%d into the bank." % amount, "bank")

	return {"success": true, "message": "Deposited $%d." % amount}


func withdraw_from_bank(amount: int) -> Dictionary:
	_ensure_bank_defaults()

	if amount <= 0:
		return {"success": false, "message": "Enter an amount greater than $0."}

	if amount > bank_balance:
		return {"success": false, "message": "You do not have enough bank balance to withdraw $%d." % amount}

	bank_balance -= amount
	money += amount
	_add_bank_transaction("Withdrew $%d." % amount)
	add_log("Withdrew $%d from the bank." % amount, "bank")

	return {"success": true, "message": "Withdrew $%d." % amount}


func deposit_all_to_bank() -> Dictionary:
	return deposit_to_bank(money)


func withdraw_all_from_bank() -> Dictionary:
	return withdraw_from_bank(bank_balance)


func apply_bank_daily_interest() -> int:
	_ensure_bank_defaults()

	var interest: int = get_bank_interest_preview()
	if interest <= 0:
		return 0

	bank_balance += interest
	_add_bank_transaction("Daily interest +$%d." % interest)
	add_log("Bank interest added $%d to your savings." % interest, "bank")
	return interest


func _add_bank_transaction(text: String) -> void:
	_ensure_bank_defaults()

	var transactions: Array = flags.get("bank_transactions", [])
	transactions.append({
		"day": day,
		"time_text": _format_time_text(current_hour, current_minute),
		"text": text,
		"wallet": money,
		"bank_balance": bank_balance
	})

	while transactions.size() > MAX_BANK_TRANSACTIONS:
		transactions.pop_front()

	flags["bank_transactions"] = transactions


func get_bank_transactions() -> Array:
	_ensure_bank_defaults()
	return (flags.get("bank_transactions", []) as Array).duplicate(true)


func _ensure_school_progress_defaults() -> void:
	if not flags.has("school_progress") or typeof(flags["school_progress"]) != TYPE_DICTIONARY:
		flags["school_progress"] = {}


func _get_school_track_entry(credential_name: String) -> Dictionary:
	_ensure_school_progress_defaults()
	var progress_data: Dictionary = flags.get("school_progress", {})
	if not progress_data.has(credential_name) or typeof(progress_data[credential_name]) != TYPE_DICTIONARY:
		progress_data[credential_name] = {"progress": 0, "learned_facts": []}
		flags["school_progress"] = progress_data
	return progress_data.get(credential_name, {})


func get_school_progress(credential_name: String) -> int:
	var entry: Dictionary = _get_school_track_entry(credential_name)
	return maxi(0, int(entry.get("progress", 0)))


func set_school_progress(credential_name: String, progress: int) -> void:
	var progress_data: Dictionary = flags.get("school_progress", {})
	var entry: Dictionary = _get_school_track_entry(credential_name)
	entry["progress"] = maxi(0, progress)
	progress_data[credential_name] = entry
	flags["school_progress"] = progress_data


func add_school_progress(credential_name: String, amount: int) -> void:
	if amount <= 0:
		return
	var progress_data: Dictionary = flags.get("school_progress", {})
	var entry: Dictionary = _get_school_track_entry(credential_name)
	entry["progress"] = maxi(0, int(entry.get("progress", 0)) + amount)
	progress_data[credential_name] = entry
	flags["school_progress"] = progress_data


func has_learned_school_fact(credential_name: String, fact_id: String) -> bool:
	var entry: Dictionary = _get_school_track_entry(credential_name)
	var learned: Array = entry.get("learned_facts", [])
	for value in learned:
		if str(value) == fact_id:
			return true
	return false


func mark_school_fact_learned(credential_name: String, fact_id: String) -> void:
	if fact_id == "":
		return
	var progress_data: Dictionary = flags.get("school_progress", {})
	var entry: Dictionary = _get_school_track_entry(credential_name)
	var learned: Array = entry.get("learned_facts", [])
	for value in learned:
		if str(value) == fact_id:
			return
	learned.append(fact_id)
	entry["learned_facts"] = learned
	progress_data[credential_name] = entry
	flags["school_progress"] = progress_data


func get_school_learned_fact_count(credential_name: String) -> int:
	var entry: Dictionary = _get_school_track_entry(credential_name)
	var learned: Array = entry.get("learned_facts", [])
	return learned.size()


func _ensure_job_system_defaults() -> void:
	if not flags.has("job_progress") or typeof(flags["job_progress"]) != TYPE_DICTIONARY:
		flags["job_progress"] = {}

	if not flags.has("credentials") or typeof(flags["credentials"]) != TYPE_ARRAY:
		flags["credentials"] = []

	var progress: Dictionary = flags["job_progress"]

	if jobs.is_empty():
		jobs.append("cashier")

	if job_id == "" or job_id == "none":
		job_id = str(jobs[0])

	for job in jobs:
		var job_key: String = str(job)
		if not progress.has(job_key):
			progress[job_key] = {
				"tier": 1,
				"exp": 0
			}

	flags["job_progress"] = progress


func get_primary_job_id() -> String:
	_ensure_job_system_defaults()
	return job_id


func get_job_definition(job: String) -> Dictionary:
	return JOB_DEFINITIONS.get(job, {})



func get_job_order() -> Array[String]:
	return ["cashier", "sales", "teacher", "programmer", "nurse", "engineer", "professor", "doctor"]

func get_job_progress(job: String) -> Dictionary:
	_ensure_job_system_defaults()

	var progress: Dictionary = flags.get("job_progress", {})
	if not progress.has(job):
		progress[job] = {
			"tier": 1,
			"exp": 0
		}
		flags["job_progress"] = progress

	return progress.get(job, {})


func set_job_progress(job: String, tier: int, exp_value: int) -> void:
	_ensure_job_system_defaults()

	var progress: Dictionary = flags.get("job_progress", {})
	progress[job] = {
		"tier": maxi(1, tier),
		"exp": maxi(0, exp_value)
	}
	flags["job_progress"] = progress


func get_job_tier(job: String) -> int:
	var progress: Dictionary = get_job_progress(job)
	return maxi(1, int(progress.get("tier", 1)))


func get_job_exp(job: String) -> int:
	var progress: Dictionary = get_job_progress(job)
	return maxi(0, int(progress.get("exp", 0)))


func get_job_display_name(job: String) -> String:
	var definition: Dictionary = get_job_definition(job)
	if definition.is_empty():
		return "Unknown Job"

	return "%s %d" % [str(definition.get("name", "Job")), get_job_tier(job)]


func get_primary_job_name() -> String:
	var primary_job: String = get_primary_job_id()
	return get_job_display_name(primary_job)


func get_job_exp_required_for_next_tier(job: String, tier: int = -1) -> int:
	var definition: Dictionary = get_job_definition(job)
	if definition.is_empty():
		return 999999

	var current_tier: int = tier
	if current_tier <= 0:
		current_tier = get_job_tier(job)

	var base_exp: int = int(definition.get("base_exp_required", 50))
	var scaled: float = base_exp * pow(JOB_EXP_GROWTH, float(current_tier - 1))
	return int(round(scaled))


func get_current_job_exp_required() -> int:
	return get_job_exp_required_for_next_tier(get_primary_job_id())


func get_job_pay(job: String, tier: int = -1) -> int:
	var definition: Dictionary = get_job_definition(job)
	if definition.is_empty():
		return 0

	var current_tier: int = tier
	if current_tier <= 0:
		current_tier = get_job_tier(job)

	var base_pay: int = int(definition.get("base_pay", 100))
	var pay_step: int = int(definition.get("pay_step", 15))
	return base_pay + ((current_tier - 1) * pay_step)


func get_current_work_pay() -> int:
	return get_job_pay(get_primary_job_id())


func has_credential(credential_name: String) -> bool:
	var credentials: Array = flags.get("credentials", [])
	for entry in credentials:
		if str(entry) == credential_name:
			return true
	return false


func add_credential(credential_name: String) -> void:
	_ensure_job_system_defaults()

	var credentials: Array = flags.get("credentials", [])
	var already_owned := false
	for entry in credentials:
		if str(entry) == credential_name:
			already_owned = true
			break

	if not already_owned:
		credentials.append(credential_name)
		flags["credentials"] = credentials

	var item_id: String = get_credential_item_id(credential_name)
	if item_id != "" and get_inventory_quantity(item_id) <= 0:
		add_inventory_item(item_id, 1)


func can_unlock_job(job: String) -> Dictionary:
	var definition: Dictionary = get_job_definition(job)
	if definition.is_empty():
		return {
			"success": false,
			"reason": "Unknown job."
		}

	var required_credential: String = str(definition.get("required_credential", ""))
	if required_credential != "" and not has_credential(required_credential):
		return {
			"success": false,
			"reason": "Requires %s." % required_credential
		}

	var required_stats: Dictionary = definition.get("required_stats", {})
	for stat_name in required_stats.keys():
		var needed: int = int(required_stats[stat_name])
		var current_value: int = int(get(stat_name))
		if current_value < needed:
			return {
				"success": false,
				"reason": "Requires %s %d." % [String(stat_name).capitalize(), needed]
			}

	return {
		"success": true,
		"reason": ""
	}


func unlock_job(job: String) -> Dictionary:
	_ensure_job_system_defaults()

	var check: Dictionary = can_unlock_job(job)
	if not bool(check.get("success", false)):
		return check

	if not jobs.has(job):
		jobs.append(job)

	var progress: Dictionary = flags.get("job_progress", {})
	if not progress.has(job):
		progress[job] = {
			"tier": 1,
			"exp": 0
		}
		flags["job_progress"] = progress

	return {
		"success": true,
		"reason": ""
	}


func switch_to_job(job: String) -> Dictionary:
	_ensure_job_system_defaults()

	if not jobs.has(job):
		return {
			"success": false,
			"reason": "Job not unlocked."
		}

	job_id = job
	return {
		"success": true,
		"reason": ""
	}


func add_job_exp(job: String, amount: int) -> Dictionary:
	var tier: int = get_job_tier(job)
	var job_exp_value: int = get_job_exp(job) + maxi(0, amount)
	var required: int = get_job_exp_required_for_next_tier(job, tier)

	var promoted: bool = false
	var old_tier: int = tier

	while job_exp_value >= required:
		job_exp_value -= required
		tier += 1
		promoted = true
		required = get_job_exp_required_for_next_tier(job, tier)

	set_job_progress(job, tier, job_exp_value)

	return {
		"success": promoted,
		"old_tier": old_tier,
		"new_tier": tier,
		"current_exp": job_exp_value,
		"next_requirement": required
	}

func get_job_category(job: String) -> String:
	match job:
		"cashier", "nurse":
			return "physical"
		"sales", "teacher", "professor":
			return "social"
		"programmer", "engineer", "doctor":
			return "technical"
		_:
			return "technical"
			
func _ensure_job_application_defaults():
	if not flags.has("job_applications"):
		flags["job_applications"] = {}

func has_applied_to_job_today(job: String) -> bool:
	_ensure_job_application_defaults()
	return flags["job_applications"].get(job, -1) == day

func mark_applied(job: String):
	_ensure_job_application_defaults()
	flags["job_applications"][job] = day

func apply_to_job(job: String) -> Dictionary:
	if has_applied_to_job_today(job):
		return {
			"success": false,
			"accepted": false,
			"reason": "Daily Limit Reached. Try Again Tomorrow!"
		}

	mark_applied(job)

	var check: Dictionary = can_unlock_job(job)
	if not bool(check.get("success", false)):
		return {
			"success": true,
			"accepted": false,
			"reason": "Rejected: %s" % str(check.get("reason", "You do not meet the requirements."))
		}

	var chance: int = get_job_application_chance(job)
	var roll: int = randi_range(1, 100)
	if roll > chance:
		return {
			"success": true,
			"accepted": false,
			"reason": "Rejected. Application chance was %d%%. Contact the employer through Phone to improve your odds." % chance,
			"chance": chance,
			"roll": roll
		}

	var unlock_result: Dictionary = unlock_job(job)
	if not bool(unlock_result.get("success", false)):
		return {
			"success": true,
			"accepted": false,
			"reason": "Rejected: %s" % str(unlock_result.get("reason", "Could not unlock job."))
		}

	var switch_result: Dictionary = switch_to_job(job)
	if not bool(switch_result.get("success", false)):
		return {
			"success": true,
			"accepted": false,
			"reason": "Accepted, but could not switch jobs."
		}

	discover_job_employer_contact(job, true)

	return {
		"success": true,
		"accepted": true,
		"reason": "Accepted. Employer relationship helped your application chance reach %d%%." % chance,
		"chance": chance,
		"roll": roll
	}



func _ensure_phone_relationship_defaults() -> void:
	if relationships == null or typeof(relationships) != TYPE_DICTIONARY:
		relationships = {}

	for job in JOB_EMPLOYER_CONTACTS.keys():
		var contact: Dictionary = JOB_EMPLOYER_CONTACTS.get(job, {})
		var contact_id := str(contact.get("contact_id", "employer_%s" % str(job)))
		if not relationships.has(contact_id):
			relationships[contact_id] = 0


func _ensure_known_employer_contacts_defaults() -> void:
	_ensure_phone_relationship_defaults()

	var known = flags.get("known_employer_contacts", [])
	if typeof(known) != TYPE_ARRAY:
		known = []

	# Cashier is the starting job, so the cashier boss is always known.
	_add_known_contact_id_to_array(known, str(get_job_employer_contact("cashier").get("contact_id", "employer_cashier")))

	# Preserve contacts for jobs the player already unlocked, including older saves.
	for owned_job in jobs:
		var owned_job_id := str(owned_job)
		if owned_job_id == "" or owned_job_id == "none":
			continue
		var owned_contact := get_job_employer_contact(owned_job_id)
		_add_known_contact_id_to_array(known, str(owned_contact.get("contact_id", "employer_%s" % owned_job_id)))

	# Make sure current job boss is always reachable even if a save is unusual.
	var current_job := get_primary_job_id()
	if current_job != "" and current_job != "none":
		var boss_contact := get_job_employer_contact(current_job)
		_add_known_contact_id_to_array(known, str(boss_contact.get("contact_id", "employer_%s" % current_job)))

	flags["known_employer_contacts"] = known
	if not flags.has("preferred_phone_contact_id"):
		flags["preferred_phone_contact_id"] = ""


func _add_known_contact_id_to_array(known: Array, contact_id: String) -> void:
	if contact_id == "":
		return
	if not known.has(contact_id):
		known.append(contact_id)


func get_job_employer_contact(job: String) -> Dictionary:
	var data: Dictionary = JOB_EMPLOYER_CONTACTS.get(job, {})
	if data.is_empty():
		return {
			"job_id": job,
			"contact_id": "employer_%s" % job,
			"name": "%s Employer" % job.capitalize(),
			"role": "Hiring Manager",
			"advice_stats": ["discipline", "confidence"],
			"personality": "general"
		}

	var copy := data.duplicate(true)
	copy["job_id"] = job
	return copy


func has_job_employer_contact(job: String) -> bool:
	_ensure_known_employer_contacts_defaults()
	var contact := get_job_employer_contact(job)
	var contact_id := str(contact.get("contact_id", "employer_%s" % job))
	var known: Array = flags.get("known_employer_contacts", [])
	return known.has(contact_id)


func discover_job_employer_contact(job: String, make_preferred: bool = true) -> Dictionary:
	_ensure_known_employer_contacts_defaults()
	var contact := get_job_employer_contact(job)
	var contact_id := str(contact.get("contact_id", "employer_%s" % job))
	var known: Array = flags.get("known_employer_contacts", [])
	var was_known := known.has(contact_id)
	_add_known_contact_id_to_array(known, contact_id)
	flags["known_employer_contacts"] = known
	if make_preferred:
		flags["preferred_phone_contact_id"] = contact_id

	var contact_name := str(contact.get("name", "Employer"))
	var message_text := "%s added to your Phone contacts." % contact_name
	if was_known:
		message_text = "%s is already in your Phone contacts." % contact_name

	return {
		"success": true,
		"was_known": was_known,
		"contact_id": contact_id,
		"contact_name": contact_name,
		"job_id": job,
		"message": message_text
	}


func get_preferred_phone_contact_id() -> String:
	_ensure_known_employer_contacts_defaults()
	return str(flags.get("preferred_phone_contact_id", ""))


func clear_preferred_phone_contact_id() -> void:
	flags["preferred_phone_contact_id"] = ""


func get_job_required_stat_completion_percent(job: String) -> int:
	var definition: Dictionary = get_job_definition(job)
	var required_stats: Dictionary = definition.get("required_stats", {})
	if required_stats.is_empty():
		return 100

	var total_needed := 0
	var total_current_capped := 0
	for stat_name in required_stats.keys():
		var needed := maxi(1, int(required_stats[stat_name]))
		var current_value := maxi(0, int(get(stat_name)))
		total_needed += needed
		total_current_capped += mini(current_value, needed)

	if total_needed <= 0:
		return 100

	return clampi(int(floor((float(total_current_capped) / float(total_needed)) * 100.0)), 0, 100)


func can_contact_job_employer(job: String) -> Dictionary:
	var percent := get_job_required_stat_completion_percent(job)
	var contact := get_job_employer_contact(job)
	if percent < 75:
		return {
			"success": false,
			"percent": percent,
			"reason": "Need at least 75%% of the required stats before contacting %s. Current: %d%%." % [str(contact.get("name", "Employer")), percent]
		}

	return {
		"success": true,
		"percent": percent,
		"reason": "Ready to contact %s." % str(contact.get("name", "Employer"))
	}


func request_job_employer_contact(job: String) -> Dictionary:
	var check := can_contact_job_employer(job)
	if not bool(check.get("success", false)):
		return check

	var discovered := discover_job_employer_contact(job, true)
	return {
		"success": true,
		"percent": int(check.get("percent", 100)),
		"contact_id": str(discovered.get("contact_id", "")),
		"contact_name": str(discovered.get("contact_name", "Employer")),
		"job_id": job,
		"message": "%s You can now call them from the Phone." % str(discovered.get("message", "Contact added."))
	}


func get_phone_contacts() -> Array[Dictionary]:
	_ensure_known_employer_contacts_defaults()
	var contacts: Array[Dictionary] = []
	var current_job := get_primary_job_id()
	var known: Array = flags.get("known_employer_contacts", [])
	var added_ids: Array[String] = []

	# Current boss stays first.
	if JOB_EMPLOYER_CONTACTS.has(current_job):
		var boss := get_job_employer_contact(current_job)
		boss["is_current_boss"] = true
		contacts.append(boss)
		added_ids.append(str(boss.get("contact_id", "")))

	for job in get_job_order():
		var job_id_text := str(job)
		var contact := get_job_employer_contact(job_id_text)
		var contact_id := str(contact.get("contact_id", ""))
		if contact_id == "" or added_ids.has(contact_id):
			continue
		if not known.has(contact_id):
			continue
		contact["is_current_boss"] = false
		contacts.append(contact)
		added_ids.append(contact_id)

	return contacts

func get_relationship(contact_id: String) -> int:
	_ensure_phone_relationship_defaults()
	return clampi(int(relationships.get(contact_id, 0)), 0, MAX_RELATIONSHIP_SCORE)


func set_relationship(contact_id: String, value: int) -> void:
	_ensure_phone_relationship_defaults()
	relationships[contact_id] = clampi(value, 0, MAX_RELATIONSHIP_SCORE)


func add_relationship(contact_id: String, amount: int) -> int:
	var new_value := get_relationship(contact_id) + amount
	set_relationship(contact_id, new_value)
	return get_relationship(contact_id)


func get_job_employer_relationship(job: String) -> int:
	var contact := get_job_employer_contact(job)
	return get_relationship(str(contact.get("contact_id", "employer_%s" % job)))


func get_relationship_rank_text(value: int) -> String:
	if value >= 85:
		return "Excellent"
	elif value >= 65:
		return "Strong"
	elif value >= 40:
		return "Friendly"
	elif value >= 20:
		return "Familiar"
	return "New Contact"


func get_job_application_relationship_bonus(job: String) -> int:
	var value := get_job_employer_relationship(job)
	if value >= 75:
		return 15
	elif value >= 50:
		return 10
	elif value >= 25:
		return 5
	return 0


func get_job_work_exp_bonus_percent(job: String) -> int:
	var value := get_job_employer_relationship(job)
	if value >= 75:
		return 30
	elif value >= 50:
		return 20
	elif value >= 25:
		return 10
	return 0


func get_work_exp_with_relationship_bonus(job: String, base_exp: int = WORK_EXP_PER_SHIFT) -> int:
	var bonus_percent := get_job_work_exp_bonus_percent(job)
	return maxi(1, int(round(float(base_exp) * (1.0 + (float(bonus_percent) / 100.0)))))


func get_job_application_chance(job: String) -> int:
	var definition: Dictionary = get_job_definition(job)
	var chance := 50

	var credential: String = str(definition.get("required_credential", ""))
	if credential != "" and not has_credential(credential):
		chance -= 25

	var required_stats: Dictionary = definition.get("required_stats", {})
	for stat_name in required_stats.keys():
		var needed: int = int(required_stats[stat_name])
		var current_value: int = int(get(stat_name))

		if current_value >= needed:
			chance += 8
		else:
			chance -= 12

	chance += get_job_application_relationship_bonus(job)
	return clampi(chance, 5, 95)


func get_current_boss_relationship_summary() -> String:
	var job := get_primary_job_id()
	var contact := get_job_employer_contact(job)
	var value := get_job_employer_relationship(job)
	return "%s (%s): %d/100 | Work EXP +%d%%" % [
		str(contact.get("name", "Boss")),
		get_relationship_rank_text(value),
		value,
		get_job_work_exp_bonus_percent(job)
	]


func get_job_networking_summary(job: String) -> String:
	var contact := get_job_employer_contact(job)
	var value := get_job_employer_relationship(job)
	return "%s, %s | Relationship %d/100 (%s) | Apply +%d%% | Work EXP +%d%%" % [
		str(contact.get("name", "Employer")),
		str(contact.get("role", "Hiring Manager")),
		value,
		get_relationship_rank_text(value),
		get_job_application_relationship_bonus(job),
		get_job_work_exp_bonus_percent(job)
	]


func do_phone_action_for_job(job: String, action: String) -> Dictionary:
	var contact := get_job_employer_contact(job)
	return do_phone_action(str(contact.get("contact_id", "employer_%s" % job)), action)


func do_phone_action(contact_id: String, action: String) -> Dictionary:
	_ensure_phone_relationship_defaults()
	var contact := _get_contact_by_id(contact_id)
	if contact.is_empty():
		return {"success": false, "message": "Contact not found.", "hud_message": "Phone: contact not found."}

	var action_key := action.to_lower()
	var minutes := PHONE_CONVERSE_MINUTES
	var relationship_gain := 0
	var changes: Dictionary = {}
	var action_title := "Converse"
	var energy_cost := PHONE_CONVERSE_ENERGY_COST

	match action_key:
		"praise":
			minutes = PHONE_PRAISE_MINUTES
			energy_cost = PHONE_PRAISE_ENERGY_COST
			relationship_gain = randi_range(3, 12)
			changes["charisma"] = 1 if randi_range(1, 100) <= 50 else 0
			changes["confidence"] = 1 if randi_range(1, 100) <= 35 else 0
			changes["stress"] = randi_range(-1, 2)
			action_title = "Praise"
		"advice":
			minutes = PHONE_ADVICE_MINUTES
			energy_cost = PHONE_ADVICE_ENERGY_COST
			relationship_gain = randi_range(2, 6)
			var advice_stats: Array = contact.get("advice_stats", ["discipline", "confidence"])
			var stat_name := str(advice_stats[randi_range(0, advice_stats.size() - 1)]) if not advice_stats.is_empty() else "discipline"
			changes[stat_name] = int(changes.get(stat_name, 0)) + 1
			changes["stress"] = -2 if randi_range(1, 100) <= 55 else 0
			action_title = "Ask Advice"
		_:
			minutes = PHONE_CONVERSE_MINUTES
			energy_cost = PHONE_CONVERSE_ENERGY_COST
			relationship_gain = randi_range(5, 9)
			changes["charisma"] = 1 if randi_range(1, 100) <= 45 else 0
			changes["happiness"] = 1 if randi_range(1, 100) <= 50 else 0
			changes["stress"] = randi_range(-2, 2)
			action_title = "Converse"

	if not can_perform_action(energy_cost):
		return {"success": false, "message": "Not enough Energy for %s. Need at least %d Energy." % [action_title, energy_cost], "hud_message": "%s: Need %d Energy" % [action_title, energy_cost]}

	var start_time_text := _format_time_text(current_hour, current_minute)
	var old_relationship := get_relationship(contact_id)
	var new_relationship := add_relationship(contact_id, relationship_gain)
	changes["relationship"] = new_relationship - old_relationship
	changes["energy"] = -energy_cost
	changes["food"] = -get_food_loss_for_minutes(minutes)
	_apply_phone_stat_changes(changes)
	advance_time(minutes)

	var contact_name := str(contact.get("name", "Contact"))
	var job := str(contact.get("job_id", ""))
	var networking_text := get_job_networking_summary(job) if job != "" else "Relationship %d/100" % new_relationship
	var full_text := format_stat_changes_full(changes)
	add_log_at_time("Phone (%s with %s): %s. %s." % [action_title, contact_name, full_text, networking_text], "phone", start_time_text)

	var short_effects := format_stat_changes_short(changes, true, 6)

	return {
		"success": true,
		"headline": "%s with %s" % [action_title, contact_name],
		"message": "%s with %s. %s. Effects: %s" % [action_title, contact_name, networking_text, full_text],
		"hud_message": "%s: %s | %s" % [action_title, contact_name, short_effects],
		"toast_message": "%s | %s" % [contact_name, short_effects],
		"stat_changes": changes,
		"stat_effects": full_text,
		"relationship": new_relationship,
		"relationship_gain": relationship_gain,
		"minutes_spent": minutes,
		"contact_name": contact_name,
		"job_id": job,
		"action_title": action_title
	}


func _get_contact_by_id(contact_id: String) -> Dictionary:
	for contact in get_phone_contacts():
		if str(contact.get("contact_id", "")) == contact_id:
			return contact
	return {}


func _apply_phone_stat_changes(changes: Dictionary) -> void:
	for key in changes.keys():
		var stat_name := str(key)
		if stat_name == "relationship" or stat_name == "food" or stat_name == "hunger":
			continue
		_add_to_named_stat(stat_name, int(changes.get(key, 0)))


func _add_to_named_stat(stat_name: String, amount: int) -> void:
	if amount == 0:
		return

	match stat_name:
		"energy":
			energy = clampi(energy + amount, 0, get_max_energy())
		"happiness":
			happiness = clampi(happiness + amount, 0, 100)
		"health":
			health = clampi(health + amount, 0, get_max_health())
		"stress":
			stress = clampi(stress + amount, 0, 100)
		"food", "hunger":
			hunger = clampi(hunger + amount, 0, get_max_fullness())
		"fitness":
			fitness = clampi(fitness + amount, 0, 999)
		"strength":
			strength = clampi(strength + amount, 0, 999)
		"endurance":
			endurance = clampi(endurance + amount, 0, 999)
		"education":
			education = clampi(education + amount, 0, 999)
		"intelligence":
			intelligence = clampi(intelligence + amount, 0, 999)
		"discipline":
			discipline = clampi(discipline + amount, 0, 999)
		"confidence":
			confidence = clampi(confidence + amount, 0, 999)
		"charisma":
			charisma = clampi(charisma + amount, 0, 999)


func get_car_shop_order() -> Array[String]:
	var result: Array[String] = []
	for car_id in CAR_SHOP_ORDER:
		result.append(str(car_id))
	return result


func get_car_shop_listing(car_id: String) -> Dictionary:
	return CAR_SHOP_LISTINGS.get(car_id, {})


func owns_vehicle(car_id: String) -> bool:
	return get_inventory_quantity(car_id) > 0


func get_owned_vehicle_count() -> int:
	var count := 0

	for car_id in CAR_SHOP_ORDER:
		if owns_vehicle(car_id):
			count += 1

	return count


func get_current_car_name() -> String:
	if current_car_id == "" or current_car_id == "none":
		return "None"

	var definition: Dictionary = get_inventory_item_definition(current_car_id)
	return str(definition.get("name", current_car_id.replace("_", " ").capitalize()))


func get_current_car_listing() -> Dictionary:
	return get_car_shop_listing(current_car_id)


func get_current_car_travel_minutes() -> int:
	var listing: Dictionary = get_current_car_listing()
	if listing.is_empty():
		return 25

	return int(listing.get("travel_minutes", 25))


func get_current_car_travel_cost() -> int:
	var listing: Dictionary = get_current_car_listing()
	if listing.is_empty():
		return 0

	return maxi(0, int(listing.get("travel_cost", 0)))


func get_current_car_bonus_text() -> String:
	if current_car_id == "" or current_car_id == "none":
		return "No vehicle equipped"

	var listing: Dictionary = get_current_car_listing()
	if listing.is_empty():
		return "Basic travel"

	return "Travel %d min | Cost $%d | Style +%d | Comfort +%d" % [
		int(listing.get("travel_minutes", 25)),
		int(listing.get("travel_cost", 0)),
		int(listing.get("style_bonus", 0)),
		int(listing.get("comfort_bonus", 0))
	]


func get_current_car_travel_summary() -> String:
	return "%s: %d min, $%d travel cost" % [
		get_current_car_name(),
		get_current_car_travel_minutes(),
		get_current_car_travel_cost()
	]


func can_afford_current_car_travel() -> bool:
	return money >= get_current_car_travel_cost()


func perform_travel(destination_id: String, destination_name: String = "") -> Dictionary:
	var final_destination_name := destination_name.strip_edges()
	if final_destination_name == "":
		final_destination_name = destination_id.replace("_", " ").capitalize()

	var car_name := get_current_car_name()
	var minutes := get_current_car_travel_minutes()
	var cost := get_current_car_travel_cost()

	if money < cost:
		return {
			"success": false,
			"message": "Not enough money to travel to %s. Need $%d." % [final_destination_name, cost],
			"hud_message": "Travel: Need $%d" % cost,
			"destination_id": destination_id,
			"travel_minutes": minutes,
			"travel_cost": cost
		}

	if cost > 0:
		money -= cost

	advance_time(minutes)
	go_to_location(destination_id)
	add_log("Traveled to %s using %s (%d min, $%d)." % [final_destination_name, car_name, minutes, cost], "travel")

	var cost_text := ""
	if cost > 0:
		cost_text = ", -$%d" % cost

	return {
		"success": true,
		"message": "Traveled to %s using %s. Time: %d min | Cost: $%d." % [final_destination_name, car_name, minutes, cost],
		"hud_message": "Travel: %s (%d min%s)" % [final_destination_name, minutes, cost_text],
		"toast_message": "%s | %d min | $%d" % [final_destination_name, minutes, cost],
		"destination_id": destination_id,
		"destination_name": final_destination_name,
		"travel_minutes": minutes,
		"travel_cost": cost,
		"car_name": car_name
	}



func get_current_goal_text() -> String:
	var goal := get_current_goal_data()
	return str(goal.get("text", "Goal: Keep building your life."))

func get_current_goal_data() -> Dictionary:
	var goals := _get_candidate_goals()
	if goals.is_empty():
		return {"id": "free_play", "text": "Goal: Free play - build stats, earn money, or explore."}

	var skipped: Array = flags.get("skipped_goal_ids", [])
	for goal in goals:
		var goal_id := str(goal.get("id", ""))
		if not skipped.has(goal_id):
			flags["current_goal_id"] = goal_id
			return goal

	# If every current goal was skipped, reset the skip list so the player is never stuck without guidance.
	flags["skipped_goal_ids"] = []
	flags["current_goal_id"] = str(goals[0].get("id", "free_play"))
	return goals[0]

func skip_current_goal() -> Dictionary:
	var current := get_current_goal_data()
	var goal_id := str(current.get("id", ""))
	if goal_id != "" and goal_id != "free_play":
		var skipped: Array = flags.get("skipped_goal_ids", [])
		if not skipped.has(goal_id):
			skipped.append(goal_id)
		flags["skipped_goal_ids"] = skipped
	return get_current_goal_data()

func _get_candidate_goals() -> Array[Dictionary]:
	var goals: Array[Dictionary] = []
	if health <= LOW_HEALTH_WARNING_THRESHOLD:
		goals.append({"id": "critical_health", "text": "Goal: Critical Health - visit Clinic or eat healthy food."})
	if hunger <= 20:
		goals.append({"id": "low_food", "text": "Goal: Food is low - eat or buy groceries."})
	if energy < 20:
		goals.append({"id": "low_energy", "text": "Goal: Energy is low - sleep or use an Energy Drink."})
	if happiness <= 10:
		goals.append({"id": "low_happiness", "text": "Goal: Happiness is low - rest, phone someone, or avoid stressful actions."})
	if stress >= 80:
		goals.append({"id": "high_stress", "text": "Goal: Stress is high - clinic advice, sleep, or gym can help."})
	if money < 120:
		goals.append({"id": "earn_cash", "text": "Goal: Work a shift or Burger Town to afford books and food."})
	if not has_credential("Sales Certificate"):
		if get_school_progress("Sales Certificate") < 20:
			if get_inventory_quantity("sales_book") <= 0:
				goals.append({"id": "buy_sales_book", "text": "Goal: Buy a Sales Book for your first credential."})
			else:
				goals.append({"id": "read_sales_book", "text": "Goal: Go to School and read your Sales Book for Sales Certificate progress."})
		else:
			goals.append({"id": "take_sales_exam", "text": "Goal: Take the Sales Certificate exam at School."})
	elif not jobs.has("sales"):
		goals.append({"id": "apply_sales", "text": "Goal: Apply for Sales on the Job Board."})
	elif get_bank_balance() <= 0 and money >= 100:
		goals.append({"id": "bank_savings", "text": "Goal: Optional - deposit some money at the Bank for interest."})
	elif get_owned_vehicle_count() <= 1 and money >= 2000:
		goals.append({"id": "buy_car", "text": "Goal: Visit Car Shop and buy a faster vehicle."})
	else:
		goals.append({"id": "career_growth", "text": "Goal: Pick a higher career track, buy its book, and build the required stats."})
	return goals

func get_health_status_text() -> String:
	if health >= 85:
		return "Excellent"
	if health >= 65:
		return "Stable"
	if health >= 40:
		return "Weak"
	if health >= 20:
		return "Danger"
	return "Critical"


func _can_pay_clinic(cost: int) -> Dictionary:
	if cost <= 0:
		return {"success": true}
	if money < cost:
		return {"success": false, "message": "Not enough money. Need $%d." % cost, "hud_message": "Clinic: Need $%d" % cost}
	return {"success": true}


func do_clinic_checkup() -> Dictionary:
	var pay_check := _can_pay_clinic(CLINIC_CHECKUP_COST)
	if not bool(pay_check.get("success", false)):
		return pay_check

	var old_health: int = health
	var old_stress: int = stress
	var old_money: int = money
	var food_loss: int = get_food_loss_for_minutes(CLINIC_CHECKUP_MINUTES)
	var start_time_text: String = _format_time_text(current_hour, current_minute)

	money -= CLINIC_CHECKUP_COST
	stress = clampi(stress - 1, 0, 100)
	advance_time(CLINIC_CHECKUP_MINUTES)

	var changes := {
		"money": money - old_money,
		"health": health - old_health,
		"stress": stress - old_stress,
		"food": -food_loss
	}
	var full_text := format_stat_changes_full(changes)
	var status := get_health_status_text()
	add_log_at_time("Clinic Checkup: Health %d/100 (%s). %s." % [health, status, full_text], "clinic", start_time_text)
	return {
		"success": true,
		"message": "Checkup complete. Health: %d/100 (%s)." % [health, status],
		"hud_message": "Clinic: Health %d (%s)" % [health, status],
		"toast_message": "Health %d/100 | %s" % [health, status],
		"stat_changes": changes,
		"stat_effects": full_text,
		"minutes_spent": CLINIC_CHECKUP_MINUTES
	}


func do_clinic_treatment() -> Dictionary:
	var pay_check := _can_pay_clinic(CLINIC_TREATMENT_COST)
	if not bool(pay_check.get("success", false)):
		return pay_check

	var old_health: int = health
	var old_stress: int = stress
	var old_happiness: int = happiness
	var old_money: int = money
	var food_loss: int = get_food_loss_for_minutes(CLINIC_TREATMENT_MINUTES)
	var start_time_text: String = _format_time_text(current_hour, current_minute)

	money -= CLINIC_TREATMENT_COST
	advance_time(CLINIC_TREATMENT_MINUTES)
	health = clampi(health + 25, 0, get_max_health())
	stress = clampi(stress - 5, 0, 100)
	happiness = clampi(happiness + 2, 0, 100)

	var changes := {
		"money": money - old_money,
		"health": health - old_health,
		"stress": stress - old_stress,
		"happiness": happiness - old_happiness,
		"food": -food_loss
	}
	var short_text := format_stat_changes_short(changes, true, 4)
	var full_text := format_stat_changes_full(changes)
	add_log_at_time("Clinic Treatment: %s." % full_text, "clinic", start_time_text)
	return {
		"success": true,
		"message": "Treatment complete: %s" % full_text,
		"hud_message": "Clinic: %s" % short_text,
		"toast_message": short_text,
		"stat_changes": changes,
		"stat_effects": full_text,
		"minutes_spent": CLINIC_TREATMENT_MINUTES
	}


func do_clinic_rest_advice() -> Dictionary:
	var old_health: int = health
	var old_stress: int = stress
	var old_happiness: int = happiness
	var food_loss: int = get_food_loss_for_minutes(CLINIC_REST_ADVICE_MINUTES)
	var start_time_text: String = _format_time_text(current_hour, current_minute)

	advance_time(CLINIC_REST_ADVICE_MINUTES)
	health = clampi(health + 2, 0, get_max_health())
	stress = clampi(stress - 3, 0, 100)
	happiness = clampi(happiness + 1, 0, 100)

	var changes := {
		"health": health - old_health,
		"stress": stress - old_stress,
		"happiness": happiness - old_happiness,
		"food": -food_loss
	}
	var short_text := format_stat_changes_short(changes, true, 4)
	var full_text := format_stat_changes_full(changes)
	add_log_at_time("Clinic Rest Advice: %s." % full_text, "clinic", start_time_text)
	return {
		"success": true,
		"message": "Rest advice complete: %s" % full_text,
		"hud_message": "Clinic: %s" % short_text,
		"toast_message": short_text,
		"stat_changes": changes,
		"stat_effects": full_text,
		"minutes_spent": CLINIC_REST_ADVICE_MINUTES
	}


func buy_vehicle(car_id: String) -> Dictionary:
	var definition: Dictionary = get_inventory_item_definition(car_id)
	var listing: Dictionary = get_car_shop_listing(car_id)

	if definition.is_empty() or str(definition.get("category", "")) != "vehicle" or listing.is_empty():
		return {
			"success": false,
			"message": "Unknown vehicle.",
			"hud_message": "Car Shop: Unknown vehicle"
		}

	var car_name: String = str(definition.get("name", car_id))
	if owns_vehicle(car_id):
		return equip_vehicle(car_id)

	var price: int = int(listing.get("price", 0))
	if money < price:
		return {
			"success": false,
			"message": "Not enough money for %s. Need $%d." % [car_name, price],
			"hud_message": "Car Shop: Need $%d" % price
		}

	money -= price
	add_inventory_item(car_id, 1)

	if current_car_id == "" or current_car_id == "none":
		current_car_id = car_id

	add_log("Bought vehicle: %s for $%d." % [car_name, price], "car_shop")

	return {
		"success": true,
		"message": "Bought %s for $%d." % [car_name, price],
		"hud_message": "Car: Bought %s (-$%d)" % [car_name, price],
		"stat_changes": {"money": -price},
		"car_id": car_id
	}


func equip_vehicle(car_id: String) -> Dictionary:
	var definition: Dictionary = get_inventory_item_definition(car_id)

	if definition.is_empty() or str(definition.get("category", "")) != "vehicle":
		return {
			"success": false,
			"message": "Unknown vehicle.",
			"hud_message": "Car Shop: Unknown vehicle"
		}

	var car_name: String = str(definition.get("name", car_id))
	if not owns_vehicle(car_id):
		return {
			"success": false,
			"message": "You do not own %s yet." % car_name,
			"hud_message": "Car Shop: Not owned"
		}

	current_car_id = car_id
	add_log("Equipped vehicle: %s." % car_name, "car_shop")

	return {
		"success": true,
		"message": "Equipped %s." % car_name,
		"hud_message": "Car: Equipped %s" % car_name,
		"car_id": car_id
	}


func get_store_item_definition(item_id: String) -> Dictionary:
	return STORE_ITEMS.get(item_id, {})


func get_inventory_item_definition(item_id: String) -> Dictionary:
	if STORE_ITEMS.has(item_id):
		return STORE_ITEMS.get(item_id, {})
	return INVENTORY_ONLY_ITEMS.get(item_id, {})


func get_food_item_extra_effect_text(item_id: String) -> String:
	var definition: Dictionary = get_store_item_definition(item_id)
	if definition.is_empty():
		definition = get_inventory_item_definition(item_id)
	if definition.is_empty():
		return ""

	var parts: Array[String] = []
	if int(definition.get("energy_effect", 0)) != 0:
		parts.append("Energy %+d" % int(definition.get("energy_effect", 0)))
	if int(definition.get("happiness_effect", 0)) != 0:
		parts.append("Happy %+d" % int(definition.get("happiness_effect", 0)))
	if bool(definition.get("random_gym_stat", false)):
		parts.append("Random FIT/STR/END +%d" % int(definition.get("random_gym_stat_amount", 1)))
	if int(definition.get("stress_chance", 0)) > 0:
		parts.append("%d%% chance Stress %+d" % [int(definition.get("stress_chance", 0)), int(definition.get("stress_effect", 1))])

	return " | ".join(parts)



func get_book_study_stat_effects(item_id: String) -> Dictionary:
	match item_id:
		"study_guide":
			return {}
		"sales_book":
			return {"charisma": 2, "confidence": 2}
		"teaching_credential_book":
			return {"education": 2, "intelligence": 2, "charisma": 2, "discipline": 2}
		"programming_book":
			return {"education": 2, "intelligence": 3, "discipline": 2, "confidence": 2}
		"fitness_book", "finance_book":
			return {}
		"nursing_textbook":
			return {"education": 3, "intelligence": 2, "endurance": 2, "discipline": 3}
		"engineering_textbook":
			return {"education": 3, "intelligence": 3, "discipline": 2, "confidence": 2}
		"advanced_academic_textbook":
			return {"education": 4, "intelligence": 4, "charisma": 3, "discipline": 3}
		"medical_textbook":
			return {"education": 4, "intelligence": 4, "endurance": 4, "discipline": 4}
		_:
			return {}


func get_book_study_effect_text(item_id: String) -> String:
	var definition: Dictionary = get_inventory_item_definition(item_id)
	if item_id == "study_guide" or bool(definition.get("retired", false)):
		return "Retired book | No credential effect"

	var effects: Dictionary = get_book_study_stat_effects(item_id)
	if effects.is_empty():
		return "No credential effect"

	var parts: Array[String] = ["+3 Progress"]
	for key in _ordered_stat_keys(effects):
		var amount := int(effects.get(key, 0))
		if amount != 0:
			parts.append("%s %+d" % [get_stat_display_name(str(key)), amount])
	parts.append("3 hours")
	return " | ".join(parts)


func get_credential_item_id(credential_name: String) -> String:
	return str(CREDENTIAL_TO_ITEM_ID.get(credential_name, ""))


func is_permanent_inventory_item(item_id: String) -> bool:
	var definition: Dictionary = get_inventory_item_definition(item_id)
	return bool(definition.get("permanent", false))


func get_inventory_quantity(item_id: String) -> int:
	for item in inventory:
		if typeof(item) == TYPE_DICTIONARY and str(item.get("id", "")) == item_id:
			return int(item.get("quantity", 0))
	return 0


func add_inventory_item(item_id: String, amount: int = 1) -> void:
	if amount <= 0:
		return

	for item in inventory:
		if typeof(item) == TYPE_DICTIONARY and str(item.get("id", "")) == item_id:
			item["quantity"] = int(item.get("quantity", 0)) + amount
			return

	inventory.append({
		"id": item_id,
		"quantity": amount
	})


func remove_inventory_item(item_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return true

	if is_permanent_inventory_item(item_id):
		return false

	for i in range(inventory.size()):
		var item = inventory[i]
		if typeof(item) != TYPE_DICTIONARY:
			continue

		if str(item.get("id", "")) == item_id:
			var current_quantity: int = int(item.get("quantity", 0))
			if current_quantity < amount:
				return false

			current_quantity -= amount
			if current_quantity <= 0:
				inventory.remove_at(i)
			else:
				item["quantity"] = current_quantity

			return true

	return false


func use_inventory_item(item_id: String) -> Dictionary:
	return use_inventory_item_amount(item_id, 1)


func use_inventory_item_amount(item_id: String, requested_amount: int = 1) -> Dictionary:
	var definition: Dictionary = get_inventory_item_definition(item_id)
	if definition.is_empty():
		return {"success": false, "message": "Unknown item."}

	var category: String = str(definition.get("category", "special"))
	var item_name: String = str(definition.get("name", item_id))
	var requested := maxi(1, requested_amount)

	if category == "food":
		var owned_quantity: int = get_inventory_quantity(item_id)
		if owned_quantity <= 0:
			return {"success": false, "message": "You do not have any %s." % item_name}

		var food_value: int = int(definition.get("hunger_value", 0))
		var needed_food: int = get_max_fullness() - hunger
		var booster_stat: String = str(definition.get("booster_stat", ""))
		var is_booster := booster_stat != ""
		var allow_when_full_for_boost := bool(definition.get("allow_when_full_for_boost", false))
		var booster_needs_value := _get_booster_needed_value(booster_stat) > 0

		if not is_booster:
			if food_value <= 0 or needed_food < food_value:
				return {"success": false, "message": "You are too full to eat %s without wasting it." % item_name, "hud_message": "Too full for %s" % item_name}
		else:
			if not booster_needs_value and (food_value <= 0 or needed_food < food_value):
				return {"success": false, "message": "%s would not help right now." % item_name, "hud_message": "No need for %s" % item_name}

		var amount_to_use: int = mini(requested, owned_quantity)
		if not (is_booster and allow_when_full_for_boost):
			if food_value <= 0:
				return {"success": false, "message": "This item cannot restore Food."}
			amount_to_use = mini(amount_to_use, int(floor(float(needed_food) / float(food_value))))

		if amount_to_use <= 0:
			return {"success": false, "message": "You are too full to use %s." % item_name, "hud_message": "Too full for %s" % item_name}

		if not remove_inventory_item(item_id, amount_to_use):
			return {"success": false, "message": "You do not have enough %s." % item_name}

		var minutes_spent: int = INVENTORY_EAT_MINUTES * amount_to_use
		var changes: Dictionary = {}
		var old_food: int = hunger
		var old_health: int = health
		var old_energy: int = energy
		var old_stress: int = stress
		var old_happiness: int = happiness
		var old_fitness: int = fitness
		var old_strength: int = strength
		var old_endurance: int = endurance

		var fullness_value: int = food_value * amount_to_use
		var health_effect: int = int(definition.get("health_effect", 0)) * amount_to_use
		var energy_effect: int = int(definition.get("energy_effect", 0)) * amount_to_use
		var happiness_effect: int = int(definition.get("happiness_effect", 0)) * amount_to_use

		hunger = clampi(hunger + fullness_value, 0, get_max_fullness())
		health = clampi(health + health_effect, 0, get_max_health())
		energy = clampi(energy + energy_effect, 0, get_max_energy())
		happiness = clampi(happiness + happiness_effect, 0, 100)

		for i in range(amount_to_use):
			_apply_food_special_effects(item_id, definition)

		if hunger > 0:
			flags["starvation_minutes"] = 0

		advance_time(minutes_spent)
		var time_food_loss: int = get_food_loss_for_minutes(minutes_spent)

		var actual_food_gain: int = hunger - old_food
		var actual_health_change: int = health - old_health
		var actual_energy_change: int = energy - old_energy
		var actual_stress_change: int = stress - old_stress
		var actual_happiness_change: int = happiness - old_happiness
		var actual_fitness_change: int = fitness - old_fitness
		var actual_strength_change: int = strength - old_strength
		var actual_endurance_change: int = endurance - old_endurance

		_add_change(changes, "food", actual_food_gain)
		_add_change(changes, "health", actual_health_change)
		_add_change(changes, "energy", actual_energy_change)
		_add_change(changes, "stress", actual_stress_change)
		_add_change(changes, "happiness", actual_happiness_change)
		_add_change(changes, "fitness", actual_fitness_change)
		_add_change(changes, "strength", actual_strength_change)
		_add_change(changes, "endurance", actual_endurance_change)

		var stat_text := format_stat_changes_short(changes, false, 6)
		var full_text := format_stat_changes_full(changes)
		var amount_text := "%dx " % amount_to_use if amount_to_use > 1 else ""
		add_log("Used %s%s: %s. Took %d minutes." % [amount_text, item_name, full_text, minutes_spent], "inventory")
		return {
			"success": true,
			"message": "Used %s%s: %s" % [amount_text, item_name, stat_text],
			"hud_message": "Item: %s" % stat_text,
			"stat_changes": changes,
			"minutes_spent": minutes_spent,
			"time_food_loss": time_food_loss,
			"amount_used": amount_to_use
		}

	if category == "book":
		return {"success": true, "message": "%s is consumed at School when you press Read Book for credential progress." % item_name}
	if category == "credential":
		return {"success": true, "message": "%s is a permanent credential used for job applications." % item_name}
	return {"success": false, "message": "This item cannot be used yet."}


func _get_booster_needed_value(stat_name: String) -> int:
	match stat_name:
		"energy":
			return maxi(0, get_max_energy() - energy)
		"health":
			return maxi(0, get_max_health() - health)
		"food", "hunger":
			return maxi(0, get_max_fullness() - hunger)
		"happiness":
			return maxi(0, 100 - happiness)
		_:
			return 0


func _get_booster_effect_value(definition: Dictionary, stat_name: String) -> int:
	if int(definition.get("booster_effect", 0)) > 0:
		return int(definition.get("booster_effect", 0))
	match stat_name:
		"energy":
			return int(definition.get("energy_effect", 0))
		"health":
			return int(definition.get("health_effect", 0))
		"food", "hunger":
			return int(definition.get("hunger_value", 0))
		"happiness":
			return int(definition.get("happiness_effect", 0))
		_:
			return 0


func use_inventory_item_until_boost_full(item_id: String) -> Dictionary:
	var definition: Dictionary = get_inventory_item_definition(item_id)
	if definition.is_empty() or str(definition.get("category", "")) != "food":
		return {"success": false, "message": "Only booster food or drinks can use this option."}

	var booster_stat: String = str(definition.get("booster_stat", ""))
	if booster_stat == "":
		return use_inventory_item_until_full(item_id)

	var needed := _get_booster_needed_value(booster_stat)
	if needed <= 0:
		return {"success": false, "message": "%s is already full." % booster_stat.capitalize(), "hud_message": "%s full" % booster_stat.capitalize()}

	var effect_value := _get_booster_effect_value(definition, booster_stat)
	if effect_value <= 0:
		return {"success": false, "message": "This item does not restore %s." % booster_stat.capitalize()}

	var owned := get_inventory_quantity(item_id)
	var amount := mini(owned, int(ceil(float(needed) / float(effect_value))))
	if amount <= 0:
		return {"success": false, "message": "You do not have enough items."}

	return use_inventory_item_amount(item_id, amount)


func use_inventory_item_until_full(item_id: String) -> Dictionary:
	var definition: Dictionary = get_inventory_item_definition(item_id)
	if definition.is_empty() or str(definition.get("category", "")) != "food":
		return {"success": false, "message": "Only food can be eaten until full."}
	var value := int(definition.get("hunger_value", 0))
	if value <= 0:
		return {"success": false, "message": "This food cannot restore Food."}
	var needed := get_max_fullness() - hunger
	if needed < value:
		return {"success": false, "message": "You are too full to eat this without wasting it.", "hud_message": "Too full to eat"}
	var owned := get_inventory_quantity(item_id)
	var amount := mini(owned, int(floor(float(needed) / float(value))))
	if amount <= 0:
		return {"success": false, "message": "You do not have enough food to eat."}
	return use_inventory_item_amount(item_id, amount)

func _apply_food_special_effects(_item_id: String, definition: Dictionary) -> void:
	if bool(definition.get("random_gym_stat", false)):
		var stat_options := ["fitness", "strength", "endurance"]
		var stat_name: String = stat_options[randi_range(0, stat_options.size() - 1)]
		var amount := int(definition.get("random_gym_stat_amount", 1))
		_add_to_named_stat(stat_name, amount)

	var stress_chance := int(definition.get("stress_chance", 0))
	if stress_chance > 0 and randi_range(1, 100) <= stress_chance:
		var stress_amount := int(definition.get("stress_effect", 1))
		_add_to_named_stat("stress", stress_amount)


func buy_store_item(item_id: String, amount: int = 1) -> Dictionary:
	if item_id == "study_guide":
		return {
			"success": false,
			"message": "Study Guide is retired and no longer sold. Buy a profession-specific book instead."
		}

	var definition: Dictionary = get_store_item_definition(item_id)
	if definition.is_empty() or bool(definition.get("retired", false)):
		return {
			"success": false,
			"message": "Unknown item."
		}

	var price: int = int(definition.get("price", 0)) * amount
	if money < price:
		return {
			"success": false,
			"message": "Not enough money."
		}

	money -= price
	add_inventory_item(item_id, amount)

	add_log("Bought %dx %s for $%d." % [amount, str(definition.get("name", item_id)), price], "store")

	var item_name: String = str(definition.get("name", item_id))
	return {
		"success": true,
		"message": "Bought %dx %s." % [amount, item_name],
		"hud_message": "Store: -$%d, +%dx %s" % [price, amount, item_name],
		"stat_changes": {"money": -price}
	}


func _get_food_item_ids_in_inventory() -> Array[String]:
	var result: Array[String] = []

	for item in inventory:
		if typeof(item) != TYPE_DICTIONARY:
			continue

		var item_id: String = str(item.get("id", ""))
		var quantity: int = int(item.get("quantity", 0))
		var definition: Dictionary = get_store_item_definition(item_id)

		if quantity > 0 and str(definition.get("category", "")) == "food":
			result.append(item_id)

	return result


func _is_healthy_food(item_id: String) -> bool:
	var definition: Dictionary = get_store_item_definition(item_id)
	return str(definition.get("food_type", "")) == FOOD_TYPE_HEALTHY


func _choose_food_for_needed_hunger(needed: int) -> String:
	var foods: Array[String] = _get_food_item_ids_in_inventory()
	if foods.is_empty() or needed <= 0:
		return ""

	var best_fit := ""
	var best_value := -1
	var best_health := -999

	for item_id in foods:
		var definition: Dictionary = get_store_item_definition(item_id)
		var value: int = int(definition.get("hunger_value", 0))
		if value <= 0 or value > needed:
			continue
		var health_score := int(definition.get("health_effect", 0))
		if value > best_value or (value == best_value and health_score > best_health):
			best_fit = item_id
			best_value = value
			best_health = health_score

	return best_fit


func consume_food_until_full() -> Dictionary:
	var target_hunger: int = get_max_fullness()
	var total_restored: int = 0
	var consumed_counts: Dictionary = {}
	var old_food: int = hunger
	var old_health: int = health
	var old_energy: int = energy
	var old_stress: int = stress
	var old_happiness: int = happiness
	var old_fitness: int = fitness
	var old_strength: int = strength
	var old_endurance: int = endurance

	while hunger < target_hunger:
		var needed: int = target_hunger - hunger
		var item_id: String = _choose_food_for_needed_hunger(needed)

		if item_id == "":
			break

		var definition: Dictionary = get_store_item_definition(item_id)
		var hunger_value: int = int(definition.get("hunger_value", 0))

		if hunger_value <= 0 or hunger_value > needed:
			break

		if not remove_inventory_item(item_id, 1):
			break

		var food_before_item: int = hunger
		_add_to_named_stat("food", hunger_value)
		_add_to_named_stat("health", int(definition.get("health_effect", 0)))
		_add_to_named_stat("energy", int(definition.get("energy_effect", 0)))
		_add_to_named_stat("happiness", int(definition.get("happiness_effect", 0)))
		_apply_food_special_effects(item_id, definition)

		total_restored += hunger - food_before_item
		var item_name: String = str(definition.get("name", item_id))
		consumed_counts[item_name] = int(consumed_counts.get(item_name, 0)) + 1

	if hunger > 0:
		flags["starvation_minutes"] = 0

	var consumed_names: Array[String] = []
	for item_name in consumed_counts.keys():
		var count: int = int(consumed_counts[item_name])
		if count <= 1:
			consumed_names.append(str(item_name))
		else:
			consumed_names.append("%s x%d" % [str(item_name), count])

	var changes: Dictionary = {}
	_add_change(changes, "food", hunger - old_food)
	_add_change(changes, "health", health - old_health)
	_add_change(changes, "energy", energy - old_energy)
	_add_change(changes, "stress", stress - old_stress)
	_add_change(changes, "happiness", happiness - old_happiness)
	_add_change(changes, "fitness", fitness - old_fitness)
	_add_change(changes, "strength", strength - old_strength)
	_add_change(changes, "endurance", endurance - old_endurance)

	return {
		"restored": total_restored,
		"health_change": health - old_health,
		"consumed": consumed_names,
		"stat_changes": changes,
		"effects_text": format_stat_changes_short(changes, false, 8),
		"full_effects_text": format_stat_changes_full(changes)
	}


func _ensure_casino_defaults() -> void:
	if not flags.has("casino") or typeof(flags["casino"]) != TYPE_DICTIONARY:
		flags["casino"] = {
			"blackjack_rounds": 0,
			"blackjack_wins": 0,
			"blackjack_losses": 0,
			"blackjack_pushes": 0,
			"blackjack_blackjacks": 0,
			"slots_spins": 0,
			"slots_wins": 0,
			"casino_net": 0,
			"largest_win": 0,
			"largest_loss": 0
		}

	var data: Dictionary = flags["casino"]
	data["blackjack_rounds"] = maxi(0, int(data.get("blackjack_rounds", 0)))
	data["blackjack_wins"] = maxi(0, int(data.get("blackjack_wins", 0)))
	data["blackjack_losses"] = maxi(0, int(data.get("blackjack_losses", 0)))
	data["blackjack_pushes"] = maxi(0, int(data.get("blackjack_pushes", 0)))
	data["blackjack_blackjacks"] = maxi(0, int(data.get("blackjack_blackjacks", 0)))
	data["slots_spins"] = maxi(0, int(data.get("slots_spins", 0)))
	data["slots_wins"] = maxi(0, int(data.get("slots_wins", 0)))
	data["casino_net"] = int(data.get("casino_net", 0))
	data["largest_win"] = maxi(0, int(data.get("largest_win", 0)))
	data["largest_loss"] = maxi(0, int(data.get("largest_loss", 0)))
	flags["casino"] = data


func get_casino_data() -> Dictionary:
	_ensure_casino_defaults()
	return (flags.get("casino", {}) as Dictionary).duplicate(true)


func can_place_casino_bet(amount: int) -> Dictionary:
	var bet := maxi(0, amount)
	if bet <= 0:
		return {"success": false, "message": "Enter a bet greater than $0.", "hud_message": "Casino: Bet must be > $0"}

	if bet > money:
		return {"success": false, "message": "Not enough cash. Max bet is $%d." % money, "hud_message": "Casino: Need cash"}

	return {"success": true, "bet": bet}


func resolve_blackjack_round(outcome: String, bet: int, player_value: int, dealer_value: int) -> Dictionary:
	_ensure_casino_defaults()
	var pay_check := can_place_casino_bet(bet)
	if not bool(pay_check.get("success", false)):
		return pay_check

	var old_money: int = money
	var old_food: int = hunger
	var old_health: int = health
	var old_stress: int = stress
	var old_happiness: int = happiness
	var start_time_text: String = _format_time_text(current_hour, current_minute)
	var final_outcome := outcome.strip_edges().to_lower()
	var delta := 0
	var headline := "Blackjack finished."

	match final_outcome:
		"blackjack":
			delta = int(round(float(bet) * 1.5))
			headline = "Blackjack! You won."
		"win":
			delta = bet
			headline = "You beat the dealer."
		"push":
			delta = 0
			headline = "Push. Bet returned."
		_:
			final_outcome = "lose"
			delta = -bet
			headline = "Dealer wins."

	money = maxi(0, money + delta)
	advance_time(CASINO_BLACKJACK_MINUTES)

	if delta > 0:
		happiness = clampi(happiness + 2, 0, 100)
		stress = clampi(stress - 1, 0, 100)
	elif delta < 0:
		happiness = clampi(happiness - 1, 0, 100)
		stress = clampi(stress + 2, 0, 100)

	var data: Dictionary = flags["casino"]
	data["blackjack_rounds"] = int(data.get("blackjack_rounds", 0)) + 1
	if final_outcome == "blackjack":
		data["blackjack_blackjacks"] = int(data.get("blackjack_blackjacks", 0)) + 1
		data["blackjack_wins"] = int(data.get("blackjack_wins", 0)) + 1
	elif final_outcome == "win":
		data["blackjack_wins"] = int(data.get("blackjack_wins", 0)) + 1
	elif final_outcome == "push":
		data["blackjack_pushes"] = int(data.get("blackjack_pushes", 0)) + 1
	else:
		data["blackjack_losses"] = int(data.get("blackjack_losses", 0)) + 1
	_update_casino_money_stats(data, delta)
	flags["casino"] = data

	var changes := {
		"money": money - old_money,
		"food": hunger - old_food,
		"health": health - old_health,
		"stress": stress - old_stress,
		"happiness": happiness - old_happiness
	}
	var full_text := format_stat_changes_full(changes)
	add_log_at_time("Blackjack: %s Bet $%d | Player %d vs Dealer %d | %s." % [headline, bet, player_value, dealer_value, full_text], "casino", start_time_text)

	return {
		"success": true,
		"game": "blackjack",
		"outcome": final_outcome,
		"headline": headline,
		"message": "%s Bet $%d | Money %+d." % [headline, bet, money - old_money],
		"hud_message": "Blackjack: %+d" % (money - old_money),
		"toast_message": "%s | %+d" % [headline, money - old_money],
		"bet": bet,
		"money_delta": money - old_money,
		"player_value": player_value,
		"dealer_value": dealer_value,
		"stat_changes": changes,
		"stat_effects": full_text,
		"minutes_spent": CASINO_BLACKJACK_MINUTES
	}


func play_slots_round(bet: int) -> Dictionary:
	_ensure_casino_defaults()
	var pay_check := can_place_casino_bet(bet)
	if not bool(pay_check.get("success", false)):
		return pay_check

	var old_money: int = money
	var old_food: int = hunger
	var old_health: int = health
	var old_stress: int = stress
	var old_happiness: int = happiness
	var start_time_text: String = _format_time_text(current_hour, current_minute)
	var symbols := _roll_slot_symbols()
	var multiplier := _get_slots_multiplier(symbols)
	var payout := int(round(float(bet) * multiplier))
	var delta := payout - bet

	money = maxi(0, money + delta)
	advance_time(CASINO_SLOTS_MINUTES)

	if delta > 0:
		happiness = clampi(happiness + 2, 0, 100)
		stress = clampi(stress - 1, 0, 100)
	elif delta < 0:
		stress = clampi(stress + 1, 0, 100)

	var data: Dictionary = flags["casino"]
	data["slots_spins"] = int(data.get("slots_spins", 0)) + 1
	if delta > 0:
		data["slots_wins"] = int(data.get("slots_wins", 0)) + 1
	_update_casino_money_stats(data, delta)
	flags["casino"] = data

	var changes := {
		"money": money - old_money,
		"food": hunger - old_food,
		"health": health - old_health,
		"stress": stress - old_stress,
		"happiness": happiness - old_happiness
	}
	var full_text := format_stat_changes_full(changes)
	var headline := "Slots win!" if delta > 0 else "No slots win."
	add_log_at_time("Slots: %s %s | Bet $%d | Payout $%d | %s." % [" ".join(symbols), headline, bet, payout, full_text], "casino", start_time_text)

	return {
		"success": true,
		"game": "slots",
		"symbols": symbols,
		"multiplier": multiplier,
		"payout": payout,
		"bet": bet,
		"money_delta": money - old_money,
		"headline": headline,
		"message": "%s Bet $%d | Payout $%d | Money %+d." % [headline, bet, payout, money - old_money],
		"hud_message": "Slots: %+d" % (money - old_money),
		"toast_message": "%s | %+d" % [headline, money - old_money],
		"stat_changes": changes,
		"stat_effects": full_text,
		"minutes_spent": CASINO_SLOTS_MINUTES
	}


func _roll_slot_symbols() -> Array[String]:
	var weighted: Array[String] = ["CHR", "CHR", "CHR", "LEM", "LEM", "BEL", "BEL", "GEM", "7"]
	var result: Array[String] = []
	for i in range(3):
		result.append(weighted[randi_range(0, weighted.size() - 1)])
	return result


func _get_slots_multiplier(symbols: Array[String]) -> float:
	if symbols.size() < 3:
		return 0.0

	var a := symbols[0]
	var b := symbols[1]
	var c := symbols[2]

	if a == "7" and b == "7" and c == "7":
		return 8.0
	if a == "GEM" and b == "GEM" and c == "GEM":
		return 5.0
	if a == b and b == c:
		return 3.0
	if _count_symbol(symbols, "7") == 2:
		return 2.0
	if a == b or a == c or b == c:
		return 1.5
	return 0.0


func _count_symbol(symbols: Array[String], symbol: String) -> int:
	var count := 0
	for item in symbols:
		if item == symbol:
			count += 1
	return count


func _update_casino_money_stats(data: Dictionary, delta: int) -> void:
	data["casino_net"] = int(data.get("casino_net", 0)) + delta
	if delta > 0:
		data["largest_win"] = maxi(int(data.get("largest_win", 0)), delta)
	elif delta < 0:
		data["largest_loss"] = maxi(int(data.get("largest_loss", 0)), abs(delta))

func get_player_name() -> String:
	if player_name.strip_edges() == "" or player_name == "Player":
		player_name = "Bobby"
	return player_name


func set_player_name(new_name: String) -> void:
	var cleaned := new_name.strip_edges()
	if cleaned == "" or cleaned == "Player":
		cleaned = "Bobby"
	player_name = cleaned


func get_skill_stat_keys() -> Array[String]:
	return ["fitness", "strength", "endurance", "education", "intelligence", "discipline", "confidence", "charisma"]


func get_skill_stats_dictionary() -> Dictionary:
	return {
		"fitness": fitness,
		"strength": strength,
		"endurance": endurance,
		"education": education,
		"intelligence": intelligence,
		"discipline": discipline,
		"confidence": confidence,
		"charisma": charisma
	}


func get_total_skill_points() -> int:
	var total := 0
	var stat_values := get_skill_stats_dictionary()
	for key in get_skill_stat_keys():
		total += maxi(0, int(stat_values.get(key, 0)))
	return total


func _get_reincarnation_growth_factor() -> float:
	var effective_wealth := maxi(get_net_worth() - 10000, 0)
	var days_lived := maxi(day, 1)
	var wealth_per_day := float(effective_wealth) / float(days_lived)
	return 1.0 - exp(-wealth_per_day / 20000.0)


func get_reincarnation_balanced_rate() -> float:
	var rate := 0.05 + (0.20 * _get_reincarnation_growth_factor())
	return clampf(rate, 0.05, 0.249)


func get_reincarnation_allocation_rate() -> float:
	var rate := 0.20 * _get_reincarnation_growth_factor()
	return clampf(rate, 0.0, 0.199)


func get_reincarnation_summary() -> Dictionary:
	var old_stats := get_skill_stats_dictionary()
	var total_skill_points := get_total_skill_points()
	var balanced_rate := get_reincarnation_balanced_rate()
	var allocation_rate := get_reincarnation_allocation_rate()
	var allocation_pool := int(floor(float(total_skill_points) * allocation_rate))
	var single_stat_cap := int(floor(float(total_skill_points) * (allocation_rate / 2.0)))
	var effective_wealth := maxi(get_net_worth() - 10000, 0)
	var days_lived := maxi(day, 1)
	var wealth_per_day := float(effective_wealth) / float(days_lived)

	var balanced_preview := {}
	for key in get_skill_stat_keys():
		balanced_preview[key] = int(floor(float(int(old_stats.get(key, 0))) * balanced_rate))

	return {
		"player_name": get_player_name(),
		"days_lived": day,
		"net_worth": get_net_worth(),
		"effective_wealth": effective_wealth,
		"wealth_per_day": wealth_per_day,
		"balanced_rate": balanced_rate,
		"allocation_rate": allocation_rate,
		"single_stat_cap_rate": allocation_rate / 2.0,
		"allocation_pool": allocation_pool,
		"single_stat_cap": single_stat_cap,
		"old_stats": old_stats,
		"balanced_preview": balanced_preview,
		"total_skill_points": total_skill_points,
		"past_lives_count": get_past_lives().size()
	}


func get_past_lives() -> Array:
	var lives = flags.get("past_lives", [])
	if typeof(lives) != TYPE_ARRAY:
		lives = []
		flags["past_lives"] = lives
	return (lives as Array).duplicate(true)


func _sanitize_reincarnation_allocation(allocation: Dictionary, allocation_pool: int, single_stat_cap: int) -> Dictionary:
	var result := {}
	var remaining := maxi(0, allocation_pool)
	var cap := maxi(0, single_stat_cap)

	for key in get_skill_stat_keys():
		var requested := maxi(0, int(allocation.get(key, 0)))
		var accepted := mini(requested, cap)
		accepted = mini(accepted, remaining)
		result[key] = accepted
		remaining -= accepted

	return result


func perform_reincarnation(mode: String = "balanced", new_player_name: String = "", allocation: Dictionary = {}) -> Dictionary:
	var summary := get_reincarnation_summary()
	var old_name := get_player_name()
	var cleaned_name := new_player_name.strip_edges()
	if cleaned_name == "" or cleaned_name == "Player":
		cleaned_name = old_name
	if cleaned_name == "" or cleaned_name == "Player":
		cleaned_name = "Bobby"

	var selected_mode := mode.strip_edges().to_lower()
	if selected_mode != "custom":
		selected_mode = "balanced"

	var inherited_stats := {}
	var old_stats: Dictionary = summary.get("old_stats", {})
	if selected_mode == "custom":
		inherited_stats = _sanitize_reincarnation_allocation(
			allocation,
			int(summary.get("allocation_pool", 0)),
			int(summary.get("single_stat_cap", 0))
		)
	else:
		var balanced_rate: float = float(summary.get("balanced_rate", 0.05))
		for key in get_skill_stat_keys():
			inherited_stats[key] = int(floor(float(int(old_stats.get(key, 0))) * balanced_rate))

	var past_lives := get_past_lives()
	var old_slot_id := slot_id
	var old_save_name := save_name
	var old_created_unix := created_unix
	var life_record := {
		"old_name": old_name,
		"new_name": cleaned_name,
		"days_lived": day,
		"net_worth": get_net_worth(),
		"effective_wealth": int(summary.get("effective_wealth", 0)),
		"wealth_per_day": float(summary.get("wealth_per_day", 0.0)),
		"balanced_rate": float(summary.get("balanced_rate", 0.05)),
		"allocation_rate": float(summary.get("allocation_rate", 0.0)),
		"single_stat_cap_rate": float(summary.get("single_stat_cap_rate", 0.0)),
		"allocation_pool": int(summary.get("allocation_pool", 0)),
		"single_stat_cap": int(summary.get("single_stat_cap", 0)),
		"mode": selected_mode,
		"old_stats": old_stats.duplicate(true),
		"inherited_stats": inherited_stats.duplicate(true),
		"unix": Time.get_unix_time_from_system()
	}
	past_lives.append(life_record)

	var new_data := create_new_game_data(old_slot_id, old_save_name, cleaned_name)
	load_from_dictionary(new_data)
	created_unix = old_created_unix if old_created_unix > 0 else created_unix
	day = 0
	current_hour = 8
	current_minute = 0
	time_of_day = "morning"
	flags["past_lives"] = past_lives
	flags["tutorial_completed"] = true
	flags["last_reincarnation"] = life_record.duplicate(true)

	for key in get_skill_stat_keys():
		_set_skill_stat_value(key, int(inherited_stats.get(key, 0)))

	add_log("Reincarnated from %s into %s. Inherited %s." % [old_name, cleaned_name, format_stat_changes_full(inherited_stats)], "reincarnation")

	var welcome := "Welcome back, %s." % old_name
	if cleaned_name != old_name:
		welcome = "Welcome back, %s... oh, I mean %s." % [old_name, cleaned_name]

	return {
		"success": true,
		"old_name": old_name,
		"new_name": cleaned_name,
		"welcome": welcome,
		"mode": selected_mode,
		"summary": summary,
		"life_record": life_record,
		"inherited_stats": inherited_stats,
		"hud_message": welcome,
		"toast_message": "Inherited %d skill points." % _sum_dictionary_values(inherited_stats)
	}


func _set_skill_stat_value(stat_name: String, value: int) -> void:
	var final_value := clampi(value, 0, 999)
	match stat_name:
		"fitness":
			fitness = final_value
		"strength":
			strength = final_value
		"endurance":
			endurance = final_value
		"education":
			education = final_value
		"intelligence":
			intelligence = final_value
		"discipline":
			discipline = final_value
		"confidence":
			confidence = final_value
		"charisma":
			charisma = final_value


func _sum_dictionary_values(values: Dictionary) -> int:
	var total := 0
	for key in values.keys():
		total += int(values.get(key, 0))
	return total


func get_reincarnation_status_text() -> String:
	var summary := get_reincarnation_summary()
	return "Past Lives: %d | Balanced %.2f%% | Allocate %.2f%% pool / %.2f%% cap" % [
		int(summary.get("past_lives_count", 0)),
		float(summary.get("balanced_rate", 0.05)) * 100.0,
		float(summary.get("allocation_rate", 0.0)) * 100.0,
		float(summary.get("single_stat_cap_rate", 0.0)) * 100.0
	]
