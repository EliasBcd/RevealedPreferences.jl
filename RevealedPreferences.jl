module RevealedPreferences

using LightGraphs
using IterTools: subsets

import GLPK

export ChoiceFunction, ChoiceCorrespondence,  WeightedDiGraph, weights, digraph, setoflaternatives, revealedpreferences, revealedpreferencesweighted, transitivecore, strictUCR,  allchoicesets, allcombinationchoicesets, cyclesbylength, HMI, swapindex, welfareoptimal

include("Preferences.jl")
include("RationalityIndices.jl")
include("Predictions.jl")

end