MF_CokePlant = {}
local MFD = MF_CokePlant

MFD.FoodDrainSpeed      = 0.0120
MFD.WaterDrainSpeed     = 0.0200
MFD.QualityDrainSpeed   = 0.0050

MFD.GrowthGainSpeed     = 5.0 --0.0010
MFD.QualityGainSpeed    = 5.0 --0.010

MFD.SyncDist = 50.0
MFD.InteractDist = 1.5
MFD.PoliceJobLabel = "police"
MFD.WeedPerBag = 5
MFD.JointsPerBag = 10
MFD.BagsPerPapers = 1

MFD.DopePerJoints = { ['neededDope'] = 2, ['neededPapers'] = 5, ['awardedJoints'] = 5 }

MFD.PlantTemplate = {
  ["Gender"] = "Female",
  ["Quality"] = 0.0,
  ["Growth"] = 0.0,
  ["Water"] = 20.0,
  ["Food"] = 20.0,
  ["Stage"] = 1,
}

MFD.ItemTemplate = {
  ["Type"] = "Water",
  ["Quality"] = 0.0,
}

MFD.Objects = {
  [1] = "pw_prop_coke_01",
  [2] = "pw_prop_coke_02",
  [3] = "pw_prop_coke_03",
  [4] = "pw_prop_coke_04",
  [5] = "pw_prop_coke_05",
  [6] = "pw_prop_coke_06",
  [7] = "pw_prop_coke_07"
}

MFD.CheckForCollision = {
  [1] = "bkr_prop_weed_01_small_01c",
  [2] = "bkr_prop_weed_01_small_01b",
  [3] = "bkr_prop_weed_01_small_01a",
  [4] = "bkr_prop_weed_med_01a",
  [5] = "bkr_prop_weed_med_01b",
  [6] = "bkr_prop_weed_lrg_01a",
  [7] = "bkr_prop_weed_lrg_01b",
}