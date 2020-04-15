using RevealedPreferences
using RevealedPreferences: fixedpoint, cycleswosubcycles!
using LightGraphs
using Test
using IterTools: subsets
import StatsBase: mean
import DataFrames: DataFrame


graph_size = 4
small_size = 3
grand_set = collect(1:graph_size)
small_set = collect(1:small_size)

completedg = complete_digraph(graph_size)
completedglooped = copy(completedg)
for i = 1:graph_size
    add_edge!(completedglooped, i, i)
end
we = ones(graph_size, graph_size)

wdg = WeightedDiGraph(completedglooped, we)

df = Dict{Vector{Int}, Int}()
cf = ChoiceFunction{Int}()
dc = Dict{Vector{Int}, Vector{Int}}()
cc = ChoiceCorrespondence{Int}()



for i = 2:graph_size
    for s = subsets(grand_set, i)
        c = minimum(s)
        df[s] = c
        dc[s] = [c]
        cf[s] = c
        cc[s] = [c]
    end
end
   
rationaldg = DiGraph(graph_size)
for i = 1:graph_size, j = (i+1):graph_size
    add_edge!(rationaldg, i, j)
end

rationalweight = [0 4. 4. 4.; 0 0 2 2; 0 0 0 1; 0 0 0 0]

smallcf = ChoiceFunction{Int}()
smallcc = ChoiceCorrespondence{Int}()

smallcf[[1, 2]] = 2
smallcf[[1, 3]] = 3
smallcf[[2, 3]] = 2
smallcf[[1, 2, 3]] = 1

for (k, v) = smallcf
    smallcc[k] = [v]
end

sucrdg = DiGraph(small_size)
add_edge!(sucrdg, 2, 3)

irrationalcc = copy(cc)
irrationalcc[[1, 2]] = [2]

q = [0.2 0.9; 0.9 0.2]
p = [1/2 1; 2 1]

pqdg = DiGraph(2)
add_edge!(pqdg, 1, 2)
add_edge!(pqdg, 2, 1)

P = DiGraph(small_size)
add_edge!(P, 2, 3)

I = Graph(small_size)
add_edge!(I, 1, 2)
add_edge!(I, 1, 3)

@testset "Building blocks for the Module" begin

    @testset "Constructors tests" begin
        @test digraph(WeightedDiGraph(0)) ==  digraph(WeightedDiGraph(DiGraph(0), zeros(Float64, 0, 0)))
        @test RevealedPreferences.weights(WeightedDiGraph(0)) ==  RevealedPreferences.weights(WeightedDiGraph(DiGraph(0), zeros(Float64, 0, 0)))
        @test digraph(wdg) == completedglooped
        @test RevealedPreferences.weights(wdg) == we
        @test cf == df
        @test cc == dc
        @test cc != cf
        @test typeof(cc) == typeof(dc)
        @test typeof(cf) == typeof(df)
        @test typeof(cc) != typeof(cf)
    end

    @testset "Test function `setofalternatives`" begin
        @test graph_size == setofalternatives(cc)
        @test graph_size == setofalternatives(cf)
    end
end
    
@testset "Some functions" begin
    @testset "Testing the overlap function" begin
        @test overlap(Vector{Vector{Int}}()) == zeros(Float64, 0, 0)
        @test overlap([[0]]) == ones(Float64, 1, 1)
        @test overlap([[0], [1]]) == [1. 0; 0 1]
        @test overlap([[1], [1]]) == ones(Float64, 2, 2)
    end
end

@testset "Testing the revealed preferences functions" begin
    @testset "DomainError for revealed preferences functions" begin
        @test_throws DomainError revealedpreferences(cf, -2)
        @test_throws DomainError revealedpreferencesweighted(cf, -2)        
        @test_throws DomainError revealedpreferences(cc, -2)
        @test_throws DomainError weakstrictrevealedpreferences(cc, -2)
        @test_throws DomainError weakstrictrevealedpreferences(cf, -2)
        @test_throws DomainError strictrevealedpreferences(cc, -2)
        @test_throws DomainError indifferentrevealedpreferences(cc, -2)      
        @test_throws DomainError strictUCR(cf, -2)
        @test_throws DomainError strictUCR(cc, -2)       
        @test_throws DomainError fixedpointpreferences(cc, -2)
        @test_throws KeyError fixedpoint(cc, [graph_size + 1, graph_size + 2])
    end

    @testset "Testing empty CFs and CCs" begin
        @test revealedpreferences(Dict{Vector{Int}, Int}()) == DiGraph(0)
        @test digraph(revealedpreferencesweighted(Dict{Vector{Int}, Int}())) == digraph(WeightedDiGraph(DiGraph(0), zeros(Float64, 0, 0)))
        @test digraph(revealedpreferencesweighted(Dict{Vector{Int}, Int}())) == digraph(WeightedDiGraph(0))    
        @test RevealedPreferences.weights(revealedpreferencesweighted(Dict{Vector{Int}, Int}())) == RevealedPreferences.weights(WeightedDiGraph(DiGraph(0), zeros(Float64, 0, 0)))
        @test RevealedPreferences.weights(revealedpreferencesweighted(Dict{Vector{Int}, Int}())) == RevealedPreferences.weights(WeightedDiGraph(0)) 
        @test revealedpreferences(Dict{Vector{Int}, Vector{Int}}()) == (DiGraph(0), Graph(0))
        @test weakstrictrevealedpreferences(Dict{Vector{Int}, Vector{Int}}()) == (DiGraph(0), Graph(0))
        @test weakstrictrevealedpreferences(Dict{Vector{Int}, Int}()) == (DiGraph(0), Graph(0))
        @test strictrevealedpreferences(Dict{Vector{Int}, Vector{Int}}()) == DiGraph(0)    
        @test indifferentrevealedpreferences(Dict{Vector{Int}, Vector{Int}}()) == Graph(0)    
        @test fixedpointpreferences(Dict{Vector{Int}, Vector{Int}}()) == (DiGraph(0), Graph(0))        
    end

    @testset "Testing the Graph creations" begin
        @test revealedpreferences(cf) == rationaldg
        @test revealedpreferences(cf, graph_size) == rationaldg
        @test revealedpreferences(cc, graph_size) == (rationaldg, Graph(graph_size))
        @test revealedpreferences(cc) == (rationaldg, Graph(graph_size))
        @test weakstrictrevealedpreferences(cc) == (rationaldg, Graph(graph_size))
        @test weakstrictrevealedpreferences(cf) == (rationaldg, Graph(graph_size))
        @test weakstrictrevealedpreferences(smallcf) == (P, I)
        @test weakstrictrevealedpreferences(cc, graph_size) == (rationaldg, Graph(graph_size))
        @test weakstrictrevealedpreferences(cf, graph_size) == (rationaldg, Graph(graph_size))
        @test strictrevealedpreferences(cc, graph_size) == rationaldg
        @test strictrevealedpreferences(cc) == rationaldg
        @test indifferentrevealedpreferences(cc) == Graph(graph_size)
        res = revealedpreferencesweighted(cf)
        @test RevealedPreferences.weights(res) == rationalweight
        @test digraph(res) == rationaldg
    end
    
    @testset "The transitive core" begin
        @test transitivecore(completedglooped) == completedglooped
        @test transitivecore(rationaldg) == rationaldg
        @test transitivecore(completedg) == DiGraph(graph_size)        
    end
    
    @testset "The Strict Unambiguous Choice Relation" begin
        @test strictUCR(cf) == rationaldg
        @test strictUCR(cc) == rationaldg
        @test strictUCR(smallcf) == sucrdg
        @test strictUCR(smallcc) == sucrdg
        @test strictUCR(cf, graph_size) == rationaldg
        @test strictUCR(cc, graph_size) == rationaldg
        @test strictUCR(smallcf, small_size) == sucrdg
        @test strictUCR(smallcc, small_size) == sucrdg
        smallcc[[1, 2, 3]] = [1, 3]
        @test strictUCR(smallcc) == DiGraph(small_size)
        @test strictUCR(smallcc, small_size) == DiGraph(small_size)
        @test strictUCR(completedg) == DiGraph(graph_size)
        @test strictUCR(rationaldg) == rationaldg
    end
    
    @testset "Fixed points" begin
        @test fixedpoint(cc, grand_set) == [minimum(grand_set)]
        @test fixedpoint(irrationalcc, grand_set) == []
        @test fixedpointpreferences(cc) == (rationaldg, Graph(graph_size))
        @test fixedpointpreferences(irrationalcc) == (DiGraph(graph_size), Graph(graph_size))
        @test fixedpointpreferences(cc, graph_size) == (rationaldg, Graph(graph_size))
        @test fixedpointpreferences(irrationalcc, graph_size) == (DiGraph(graph_size), Graph(graph_size))  
    end

    @testset "Revealed Preferences with prices and quantities" begin
        @test strictrevealedpreferences(p, q) == pqdg
        @test strictrevealedpreferences(p, q, 1) == pqdg
        @test strictrevealedpreferences(p, q, 0) == DiGraph(2) 
        @test strictrevealedpreferences(p, q, .5) == DiGraph(2)                
    end
end

@testset "Test the `Predictions.jl` file" begin
    @testset "Testing the `optimalset` function" begin
        @test optimalset(rationaldg, grand_set) == [1]
        @test optimalset(P, small_set) == [1, 2]
        @test_throws DomainError optimalset(pqdg, small_set)
        @test optimalset(pqdg, [1, 2]) == []
    end
    
    @testset "Testing the Selten's score" begin
        @test Selten(cc, rationaldg, grand_set) == ((graph_size - 1) /graph_size)
        @test Selten(cf, rationaldg, grand_set) == ((graph_size - 1) /graph_size)
        @test Selten(cf, rationaldg, collect(keys(cc))) ≈ 7/12
        @test Selten(cc, rationaldg, collect(keys(cc))) ≈ 7/12
        @test Selten(cc, rationaldg, collect(keys(cc)), minimum) == 1/2
        @test Selten(cc, rationaldg, collect(keys(cc)), maximum) == ((graph_size - 1) / graph_size)
    end
    
end

@testset "Test the `Degree.jl` file" begin
    @test edgedegree(rationaldg, Edge(1, 2), -, mean) == 2.
    @test edgedegree(rationaldg, Edge(1, 2), -, minimum) == 1.
    @test edgedegree(rationaldg, Edge(1, 2), /, mean) ≈ 5/6
    @test edgedegree(rationaldg, Edge(1, 2), /, minimum) ≈ 2/3
    @test edgedegree(Graph(graph_size), Edge(1, 2), -, mean) == 0
    @test_throws DomainError edgedegree(rationaldg, Edge(graph_size, graph_size + 1), -, mean)
    @test edgesdegree(rationaldg, [Edge(1, 2), Edge(1, 3)]) == 1.5
    @test edgesdegree(rationaldg, [Edge(1, 2), Edge(1, 3)], -, mean, minimum) == 1
    @test missingedgesdegree(rationaldg) == 0
    @test missingedgesdegree(sucrdg) == 0
    @test missingedgesdegree(sucrdg, -, minimum, mean) == -0.5
    @test missingedgesdegree(sucrdg, -, minimum, minimum) == -1
end

@testset "Test the `Cyclicity.jl` file" begin
    @test removeallcycles!(copy(rationaldg)) == rationaldg
    @test removeallcycles!(copy(completedg)) == DiGraph(graph_size)
    @test cycleswosubcycles!(copy(rationaldg)) == []
    @test cycleswosubcycles!(copy(completedg)) == collect(subsets(grand_set, 2))
    @test numbercycleswosubcycles!(copy(completedg), "") == DataFrame(NOSC2 = [6])
    @test numbercycleswosubcycles!(copy(rationaldg), "") == DataFrame()
end

irrationalcc[[1, 3]] = [1, 3]

@testset "Testing rationality axioms" begin
    @test isWARP(cc) == true
    @test isWARP(irrationalcc) == false
    @test isacyclic(P, I) == false    
    rem_edge!(I, 1, 3)
    @test isacyclic(P, I) == true
    add_edge!(P, 3, 2)
    @test isacyclic(P, I) == false    
    @test isacyclic(cf) == true
    @test isalpha(cc) == true
    @test isalpha(irrationalcc) == false
    @test isbeta(cc) == true
    @test isbeta(irrationalcc) == false
    @test isdelta(cc) == true
    @test isdelta(irrationalcc) == false
    @test isgamma(cc) == true
    @test isgamma(irrationalcc) == false
    @test isWARNI(cc) == true
    @test isWARNI(irrationalcc) == false
    @test isoutcast(cc) == true
    @test isoutcast(irrationalcc) == false
    @test isFAs(cc) == true
    @test isFAs(irrationalcc) == false
    @test isJLF(cc) == true
    @test isJLF(irrationalcc) == false
    @test isOO(cc) == true
    @test isOO(irrationalcc) == false
    @test isFP(cc) == true
    @test isFP(irrationalcc) == false
    @test isFA(cc) == true
    @test isFA(irrationalcc) == false
end

@testset "Testing the indices of rationality" begin
    @test  allcombinationchoicesets(2) == [Vector{Int}(), [[1, 2]]]
    @test  allcombinationchoicesets(1) == [[]]  
end


