Config = {}

Config.BankLockdown = 10 * 60 -- use < * 60 > to set minutes or < * 3600 > to set hours, remove it to set seconds, IRL time for the bank to be locked after a robbery
Config.CountersLockdown = 3 * 60 -- same as above about the time, IRL time to disable computer hacking after robbery started
Config.VaultGateScannerLockdown = 3 * 60 -- same as above but for the Vault Gate scanner

Config.BankCardChance = 100 -- chance to get a bank card from the cashier counters
Config.UniversalCardChance = 100 -- chance to get an universal bank card from the cashier counters
Config.LockpickBreakChance = 0 -- chance to break a lockpick at the storage boxes outside the vault gates
Config.CountersMoney = { ['min'] = 0, ['max'] = 2000 }
Config.VaultMoney = { ['min'] = 0, ['max'] = 10000 }
Config.VaultValuableGoods = { ['min'] = 0, ['max'] = 3 }
Config.MoneyBags = { ['min'] = 50000, ['max'] = 100000 }
Config.PaletoBagChance = 50 -- Chance of obtaining a money bag from paleto last storage boxes
Config.PaletoMoneyBags = { ['min'] = 25000, ['max'] = 40000 }

Config.NeededPolice = { -- Needed police for each type of bank robbery
    ['Small']   = 0,
    ['Paleto']  = 0,
    ['Big']     = 0
}



