using RevealedPreferences
using LightGraphs
using Test
using IterTools: subsets


graph_size = 4
small_size = 3
grand_set = collect(1:graph_size)

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
    end

    @testset "Testing the Graph creations" begin
        @test revealedpreferences(cf) == rationaldg
        @test revealedpreferences(cf, graph_size) == rationaldg
        @test revealedpreferences(cc, graph_size) == (rationaldg, Graph(graph_size))
        @test revealedpreferences(cc) == (rationaldg, Graph(graph_size))
        @test weakstrictrevealedpreferences(cc) == (rationaldg, Graph(graph_size))
        @test weakstrictrevealedpreferences(cf) == (rationaldg, Graph(graph_size))
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

    
end





