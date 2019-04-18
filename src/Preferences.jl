## Definition of type aliases, to avoir writing Dict of Vector.

"""
```ChoiceFunction{T}```

Wrapper to define a choice function.
"""
ChoiceFunction{T} = Dict{Vector{T}, T} where T <:Int

"""
```ChoiceCorrespondence{T}```

Wrapper to define a choice correspondence.
"""
ChoiceCorrespondence{T} = Dict{Vector{T}, Vector{T}} where T <:Int # Useless for now.

"""
```WeightedDiGraph{T<:Int}```

Composite types to store all the informations about a DiGraph with weights.
More adapted to my purpose than the WeightGraphs available in LightGraphs.
"""
mutable struct WeightedDiGraph{T<:Int}
    dg::DiGraph{T}
    weights::Matrix{Float64}
end

"""
```WeightedDiGraph(n::T) where T <: Int```

Constructor of an empty WeightedDiGraph of size `n`.
"""
function WeightedDiGraph(n::T) where T <: Int
    dg = DiGraph{T}(n)
    we = zeros(Float64, n, n)
    return WeightedDiGraph(dg, we)
end

"""
```weights(wdg::WeightedDiGraph)```

Return the weights of a given `wdg`.
"""
weights(wdg::WeightedDiGraph) = wdg.weights


"""
```digraph(wdg::WeightedDiGraph)```

Return the digraph of a given `wdg`.
"""
digraph(wdg::WeightedDiGraph) = wdg.dg

"""
```setoflaternatives(cf::ChoiceFunction{T}) where T <: Int```

Look at the number of alternatives in a choice function. It might be slow if the number of alternatives is large.

# Arguments

- `cf`, a choice function.
"""
function setoflaternatives(cf::ChoiceFunction{T}) where T <: Int
    set = Set{T}()
    for key in keys(cf)
        push!(set, key)
    end
    return length(set)
end

"""
```revealedpreferences(cf::ChoiceFunction{Int}; n::Int = 0) where T <: Int```

Create the revealed preferences from an observed choice function.

# Arguments

- `cf`, a choice function.
- `n` the number of alternatives. If no value is provided, look at all the alternatives in the choice function, which is much slower.
"""
function revealedpreferences(cf::ChoiceFunction{T}; n::Int = 0) where T <: Int
    if n == 0
        n = setoflaternatives(cf)
    elseif n < 0
	DomainError(n, "should be positive.")
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
```revealedpreferencesweighted(cf::ChoiceFunction{T}; n::Int = 0) where T <: Int```

Create the revealed preferences from an observed choice function, weighting each relation by its frequency.

# Arguments

- `cf`, a choice function.
- `n` the number of alternatives. If no value is provided, look at all the alternatives in the choice function, which is much slower.
"""
function revealedpreferencesweighted(cf::ChoiceFunction{T}; n::Int = 0) where T <: Int
    if n == 0
        n = setoflaternatives(cf)
    elseif n < 0
	DomainError(n, "should be positive.")
    end    
    result = WeightedDiGraph(n)
    for (key, value) in cf
        for i in key
            i == value && continue
            add_edge!(digraph(result), value, i)
            RevealedPreferences.weights(result)[value, i] += 1
        end
    end
    @assert !(sum(weights(result)) == n) "The weights in the preference graph do not add up to $n. PROBLEM."    
    result.weights = result.weights ./ n
    return result
end

"""
```transitivecore(dg::DiGraph)```

Compute the transitive core of a directed graph.
To speed-up computations, provide `n`, the number of alternatives.

# Arguments

- `dg` a digraph from which we will build the transitive core.
- `n` the number of alternatives. If no value is provided, use the size of the original graph.
"""
function transitivecore(dg::DiGraph; n::Int = 0)
    if n == 0
        n = nv(dg)
    elseif n < 0
	DomainError(n, "should be positive.")
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
```strictUCR(cf::ChoiceFunction{Int}; n::Int = 0)```

Create the Strict UCR graph from an observed choice function.
To speed-up computations, provide `n`, the number of alternatives.

# Arguments

- `cf`: a choice function.
- `n` the number of alternatives. If no value is provided, look at all the alternatives in the choice function, which is much slower.
"""
function strictUCR(cf::ChoiceFunction{Int}; n::Int = 0)
    if n == 0
        n = setoflaternatives(cf)
    elseif n < 0
	DomainError(n, "should be positive.")
    end    
    result = DiGraph(n)
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
