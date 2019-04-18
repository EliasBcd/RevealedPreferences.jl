module RevealedPreferences

using LightGraphs
using IterTools: subsets
using DataFrames: DataFrame

import GLPK
import Base.weights

export ChoiceFunction, ChoiceCorrespondence,  WeightedDiGraph, weights, digraph, setoflaternatives, revealedpreferences, revealedpreferencesweighted, transitivecore, strictUCR,  allchoicesets, allcombinationchoicesets, cyclesbylength, HMI, swapindex, welfareoptimal

include("Preferences.jl")
include("RationalityIndices.jl")
include("Predictions.jl")

end
