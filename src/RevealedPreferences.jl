module RevealedPreferences

using Graphs
using IterTools: subsets
using DataFrames: DataFrame

import GLPK
import StatsBase: mean, countmap
import Base: copy, ==, !=
import Graphs: rem_edge!

export ChoiceFunction, ChoiceCorrespondence, WeightedDiGraph, weights, digraph, setofalternatives, overlap, revealedpreferences, strictrevealedpreferences, indifferentrevealedpreferences, revealedpreferencesweighted, weakstrictrevealedpreferences, transitivecore, strictUCR,  allchoicesets, allcombinationchoicesets, cyclesbylength, HMI, swapindex, optimalset, isWARP, isWARNI, isoutcast, isFAs, isFP, isOO, isalpha, isbeta, isgamma, isdelta, isJLF, isFA, isacyclic, fixedpointpreferences, Selten, edgedegree, edgesdegree, missingedgesdegree, removeallcycles!, cyclieswosubcycles!, numbercycleswosubcycles!, copy, ==, !=, rem_edge!, graphsize

include("Preferences.jl")
include("Rationality/Indices.jl")
include("Rationality/Axioms.jl")
include("Predictions.jl")
include("Degree.jl")
include("Cyclicity.jl")

end
