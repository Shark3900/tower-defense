--!strict
export type Group = {
	["Path"]: number,
	["Name"]: string,
	["Amount"]: number,
	["UnitDelay"]: number,
	["GroupDelay"]: number
}

--Num Paths
  --Wave
    --Group

local Waves = {
	[1] = {
		[1] = {
			[1] = {
				["Path"] = 1,
				["Name"] = "Basic",
				["Amount"] = 5,
				["UnitDelay"] = 0.2,
				["GroupDelay"] = 1
			}
		},
		[2] = {
			[1] = {
				["Path"] = 1,
				["Name"] = "Basic",
				["Amount"] = 10,
				["UnitDelay"] = 0.2,
				["GroupDelay"] = 1
			}
		},
		[3] = {
			[1] = {
				["Path"] = 1,
				["Name"] = "Basic",
				["Amount"] = 7,
				["UnitDelay"] = 0.2,
				["GroupDelay"] = 1
			},
			[2] = {
				["Path"] = 2,
				["Name"] = "Fast",
				["Amount"] = 1,
				["UnitDelay"] = 0.2,
				["GroupDelay"] = 1
			}
		},
		[4] = {
			[1] = {
				["Path"] = 1,
				["Name"] = "Basic",
				["Amount"] = 15,
				["UnitDelay"] = 0.1,
				["GroupDelay"] = 1
			}
		},
		[5] = {
			[1] = {
				["Path"] = 1,
				["Name"] = "Basic",
				["Amount"] = 10,
				["UnitDelay"] = 0.2,
				["GroupDelay"] = 3
			},
			[2] = {
				["Path"] = 2,
				["Name"] = "Fast",
				["Amount"] = 4,
				["UnitDelay"] = 0.25,
				["GroupDelay"] = 1
			}
		}
	},
	[2] = {
		[1] = {
			[1] = {
				["Path"] = 1,
				["Name"] = "Basic",
				["Amount"] = 5,
				["UnitDelay"] = 0.2,
				["GroupDelay"] = 1
			}
		},
		[2] = {
			[1] = {
				["Path"] = 1,
				["Name"] = "Basic",
				["Amount"] = 10,
				["UnitDelay"] = 0.2,
				["GroupDelay"] = 1
			}
		},
		[3] = {
			[1] = {
				["Path"] = 1,
				["Name"] = "Basic",
				["Amount"] = 7,
				["UnitDelay"] = 0.2,
				["GroupDelay"] = 1
			},
			[2] = {
				["Path"] = 2,
				["Name"] = "Fast",
				["Amount"] = 1,
				["UnitDelay"] = 0.2,
				["GroupDelay"] = 1
			}
		},
		[4] = {
			[1] = {
				["Path"] = 1,
				["Name"] = "Basic",
				["Amount"] = 15,
				["UnitDelay"] = 0.1,
				["GroupDelay"] = 1
			}
		},
		[5] = {
			[1] = {
				["Path"] = 1,
				["Name"] = "Basic",
				["Amount"] = 10, 
				["UnitDelay"] = 0.2,
				["GroupDelay"] = 3
			},
			[2] = {
				["Path"] = 2,
				["Name"] = "Fast",
				["Amount"] = 4,
				["UnitDelay"] = 0.25,
				["GroupDelay"] = 1
			}
		}
	}
}

return Waves