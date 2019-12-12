module RevealedPreferences

using LightGraphs
using IterTools: subsets
using DataFrames: DataFrame

import GLPK
import StatsBase.mean

export ChoiceFunction, ChoiceCorrespondence, WeightedDiGraph, weights, digraph, setoflaternatives, revealedpreferences, strictrevealedpreferences, indifferencerevealedpreferences, revealedpreferencesweighted, weakstrictrevealedpreferences, transitivecore, strictUCR,  allchoicesets, allcombinationchoicesets, cyclesbylength, HMI, swapindex, optimalset, isWARP, isWARNI, isoutcast, isFAs, isFP, isOO, isalpha, isbeta, isgamma, isdelta, isJLF, isFA, isacyclic, fixedpointpreferences, Selten

include("Preferences.jl")
include("Rationality/Indices.jl")
include("Rationality/Axioms.jl")
include("Predictions.jl")

end
