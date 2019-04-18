## Definition of type aliases, to avoir writing Dict of Vector.

ChoiceFunction{T} = Dict{Vector{T}, T} where T <:Int

ChoiceCorrespondence{T} = Dict{Vector{T}, Vector{T}} where T <:Int # Useless here.

"""
```WeightedDiGraph{T<:Int}```

Composite types to store all the informations about a DiGraph with weights.
More adapted to my purpose than the WeightGraphs available in LightGraphs.
"""
mutable struct WeightedDiGraph{T<:Int}
    dg::DiGraph{T}
    weights::Matrix{Float64}
end

function WeightedDiGraph(n::T) where T <: Int
    dg = DiGraph{T}(n)
    we = zeros(Float64, n, n)
    return WeightedDiGraph(dg, we)
end

weights(wdg::WeightedDiGraph) = wdg.weights

digraph(wdg::WeightedDiGraph) = wdg.dg

function setoflaternatives(cf::ChoiceFunction{T}) where T <: Int
    set = Set{T}()
    for key in keys(cf)
        push!(set, key)
    end
    return length(set)
end

"""
```revealedpreferences(cf::ChoiceFunction{Int})```

Create the revealed preferences from an observed choice function.

# Arguments

- `cf`, a choice function.
"""
function revealedpreferences(cf::ChoiceFunction{Int}; n::Int = 0)
    if n == 0
        n = setoflaternatives(cf)
    end    
    result = DiGraph(n)
    for (key, value) in cf
        for i in key
            i == value && continue
            add_edge!(result, value, i)
        end
    end
    return result
end

"""
```revealedpreferencesweighted(cf::ChoiceFunction{Int})```

Create the revealed preferences from an observed choice function, weighting each relation by its frequency.

# Arguments

- `cf`, a choice function.
"""
function revealedpreferencesweighted(cf::ChoiceFunction{Int}; n::Int = 0)
    if n == 0
        n = setoflaternatives(cf)
    end    
    result = WeightedDiGraph(n)
    for (key, value) in cf
        for i in key
            i == value && continue
            add_edge!(digraph(result), value, i)
            weights(result)[value, i] += 1
        end
    end
    @assert !(sum(weights(result)) == n) "The weights in the preference graph do not add up to $n. PROBLEM."    
    weights(result) = weights(result) ./ nchoices
    return result
end

"""
```transitivecore(dg::DiGraph)```

Compute the transitive core of a directed graph.

# Arguments

- `dg` a directed graph from which we will build the transitive core.
"""
function transitivecore(dg::DiGraph; n::Int = 0)
    if n == 0
        n = nv(dg)
    end
    tc = DiGraph(n)
    for e in edges(dg)
        (s,t) = (src(e), dst(e))
        if (issubset(outneighbors(dg, t), outneighbors(dg, s)) && issubset(inneighbors(dg, s), inneighbors(dg, t)))
            add_edge!(tc, e)
        end
    end
    return tc
end

"""
```strictUCR(cf::ChoiceFunction{Int})```

Create the Strict UCR graph from an observed choice function.

# Arguments

- `cf`: a choice function.
"""
function strictUCR(cf::ChoiceFunction{Int}; nalternatives::Int = 0)
    if nalternatives == 0
        nalternatives = setoflaternatives(cf)
    end    
    result = DiGraph(nalternatives)
    forbidden = Set{Tuple{Int, Int}}()
    for (key, value) in cf
        for i in key
            i == value && continue
            if has_edge(result, i, value)
                rem_edge!(result, i, value) 
                push!(forbidden, (i, value))
                push!(forbidden, (value, i))
            elseif !in((value, i), forbidden)                
                add_edge!(result, value, i)
            end
        end
    end
    return result
end
