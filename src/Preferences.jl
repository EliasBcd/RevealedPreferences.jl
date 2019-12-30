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
ChoiceCorrespondence{T} = Dict{Vector{T}, Vector{T}} where T <:Int

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
function setoflaternatives(cf::Union{ChoiceFunction{T}, ChoiceCorrespondence{T}}) where T <: Int
    set = Set{T}()
    for key in keys(cf)
        union!(set, key)
    end
    return length(set)
end

"""
```overlap(sets::Vector{Vector{T}}) where T <: Number```

Compute the matrix of vector overlap, filling the whole matrix, so that the information is in double.

# Arguments

- `sets`, a vector of vectors, over which we wish to compute the overlap.
"""
function overlap(sets::Vector{Vector{T}}) where T <: Number
    l = length(sets)
    if l == 0
        return zeros(Float64, 0, 0)
    elseif l == 1
        return ones(Float64, 1, 1)
    end
    res = zeros(Float64, l, l)
    for i in 1:l, j in  (i+1):l
        res[i, j] = length(intersect(sets[i], sets[j])) / length(union(sets[i], sets[j]))
    end
    for i in 1:l
        res[i, i] = 1.
    end
    for i in 1:length(sets), j in 1:(i-1)
        res[i, j] = res[j, i]
    end
    return res
end

"""
```revealedpreferences(cf::ChoiceFunction{T}, n::Int = 0) where T <: Int```

Create the revealed preferences from an observed choice function, assuming that the preferences revealed are strict.

# Arguments

- `cf`, a choice function.
- `n`, the number of alternatives. If no value is provided, look at all the alternatives in the choice function, which is much slower.
"""
function revealedpreferences(cf::ChoiceFunction{T}, n::Int = 0) where T <: Int
    if n == 0
        n = setoflaternatives(cf)
    elseif n < 0
        DomainError(n, "should be positive.")
    end    
    result = DiGraph(n)
    for (key, value) in cf
        for i in key
            if !(i == value)
                add_edge!(result, value, i)
            end
        end
    end
    return result
end

"""
```weakstrictrevealedpreferences(cf::ChoiceFunction{T}, n::Int = 0) where T <: Int```

Create the revealed preferences from an observed choice function. It assumes that if in the choice function, we have a set were x in chosen and y was available, and a set where y is chosen and x is available, then x and y are indifferent.

# Arguments

- `cf`, a choice function.
- `n`, the number of alternatives. If no value is provided, look at all the alternatives in the choice function, which is much slower.
"""
function weakstrictrevealedpreferences(cf::ChoiceFunction{T}, n::Int = 0) where T <: Int
    if n == 0
        n = setoflaternatives(cf)
    elseif n < 0
        DomainError(n, "should be positive.")
    end    
    P = DiGraph(n)
    I = Graph(n)
    for (S, cS) in cf
        for y in S
            if cS == y
                continue
            elseif has_edge(P, y, cS)
                add_edge!(I, cS, y)
                rem_edge!(P, y, cS)
            elseif !has_edge(I, cS, y)
                add_edge!(P, cS, y)
            end
        end
    end
    return P, I
end

"""
```weakstrictrevealedpreferences(cc::ChoiceCorrespondence{T}, n::Int = 0) where T <: Int```

Create the revealed preferences from an observed choice function. It assumes that if in the choice correspondence, we have a set were x in chosen and y was available, and a set where y is chosen and x is available, then x and y are indifferent.

# Arguments

- `cf`, a choice function.
- `n`, the number of alternatives. If no value is provided, look at all the alternatives in the choice function, which is much slower.
"""
function weakstrictrevealedpreferences(cc::ChoiceCorrespondence{T}, n::Int = 0) where T <: Int
    if n == 0
        n = setoflaternatives(cc)
    elseif n < 0
        DomainError(n, "should be positive.")
    end    
    P = DiGraph(n)
    I = Graph(n)
    for (S, cS) in cc
        for y in S, x in cS
            if x == y
                continue
            elseif in(y, cS)
                add_edge!(I, x, y)
                rem_edge!(P, x, y)
                rem_edge!(P, y, x)
            elseif has_edge(P, y, x)
                add_edge!(I, x, y)
                rem_edge!(P, y, x)
            elseif !has_edge(I, x, y)
                add_edge!(P, x, y)
            end
        end
    end
    return P, I
end

"""
```strictrevealedpreferences(cc::ChoiceCorrespondence{T}, n::Int = 0) where T <: Int```

Create the strict revealed preferences from an observed choice correspondence.

# Arguments

- `cc`, a choice function.
- `n`, the number of alternatives. If no value is provided, look at all the alternatives in the choice function, which is much slower.
"""
function strictrevealedpreferences(cc::ChoiceCorrespondence{T}, n::Int = 0) where T <: Int
    if n == 0
        n = setoflaternatives(cc)
    elseif n < 0
        DomainError(n, "should be positive.")
    end    
    result = DiGraph(n)
    for (S, cS) in cc
        for x in cS,  y in S
            if !in(y, cS)
                add_edge!(result, x, y)
            end
        end
    end
    return result
end

"""
```strictrevealedpreferences(cc::ChoiceCorrespondence{T}, n::Int = 0) where T <: Int```

Create the revealed indifferences from an observed choice correspondence.

# Arguments

- `cc`, a choice function.
- `n`, the number of alternatives. If no value is provided, look at all the alternatives in the choice function, which is much slower.
"""
function indifferentrevealedpreferences(cc::ChoiceCorrespondence{T}, n::Int = 0) where T <: Int
    if n == 0
        n = setoflaternatives(cc)
    elseif n < 0
        DomainError(n, "should be positive.")
    end  
    result = Graph(n)
    for cS in values(cc)
        for x in cS,  y in cS
            if !(x == y)
                add_edge!(result, x, y)
            end
        end
    end
    return result
end

"""
```revealedpreferences(cc::ChoiceCorrespondence{T}, n::Int = 0) where T <: Int```

Create the revealed preferences from an observed choice correspondence, including indifference and strict preferences.

# Arguments

- `cc`, a choice correspondence.
- `n`, the number of alternatives. If no value is provided, look at all the alternatives in the choice function, which is much slower.
"""
function revealedpreferences(cc::ChoiceCorrespondence{T}, n::Int = 0) where T <: Int
    if n == 0
        n = setoflaternatives(cc)
    elseif n < 0
        DomainError(n, "should be positive.")
    end  
    P = strictrevealedpreferences(cc, n)
    I = indifferentrevealedpreferences(cc, n)  
    return P, I
end

"""
```revealedpreferencesweighted(cf::ChoiceFunction{T}, n::Int = 0) where T <: Int```

Create the revealed preferences from an observed choice function, weighting each relation by its frequency.

# Arguments

- `cf`, a choice function.
- `n`, the number of alternatives. If no value is provided, look at all the alternatives in the choice function, which is much slower.
"""
function revealedpreferencesweighted(cf::ChoiceFunction{T}, n::Int = 0) where T <: Int
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
```strictrevealedpreferences(price::Matrix{T}, quantity::Matrix{T}) where T <: Number```

Create the strict revealed preferences from observed prices and quantities. Assumes that each period is a row, and that the prices and goods are in the same place for the same period in the matrices.

# Arguments

- `price`, the observed prices;
- `quantity`, the observed quantities purchased at the given prices;
- `aei`, a coefficient to loosen or tighten the budget constraint. Used to compute the Afriat Efficiency Index. When equal to 1 (the default), it is traditional revealed preferences.
"""
function strictrevealedpreferences(price::Matrix{T}, quantity::Matrix{T}, aei::Number = 1) where T <: Number
    l = size(price, 1)
    result = DiGraph(l)
    expenditures = price .* quantity
    budget = sum(price .* quantity, dims = 2)
    normalizedprice = price ./ budget
    for i in 1:l
        for j in  findall(quantity * normalizedprice[i, :] .- aei .<= eps(1.)) # To take into account rounding errors in the computations.
            if i != j
                add_edge!(result, i, j)
            end
        end
    end
    return result
end

"""
```transitivecore(dg::DiGraph)```

Compute the transitive core of a directed graph.
To speed-up computations, provide `n`, the number of alternatives.

# Arguments

- `dg`, a digraph from which we will build the transitive core.
"""
function transitivecore(dg::DiGraph)
    tc = DiGraph(nv(dg))
    for e in edges(dg)
        (s,t) = (src(e), dst(e))
        if (issubset(outneighbors(dg, t), outneighbors(dg, s)) && issubset(inneighbors(dg, s), inneighbors(dg, t)))
            add_edge!(tc, e)
        end
    end
    return tc
end

"""
```strictUCR(cf::ChoiceFunction{T}, n::Int = 0) where T <: Int```

Create the Strict UCR graph from an observed choice function.
To speed-up computations, provide `n`, the number of alternatives.

# Arguments

- `cf`, a choice function.
- `n`, the number of alternatives. If no value is provided, look at all the alternatives in the choice function, which is much slower.
"""
function strictUCR(cf::ChoiceFunction{T}, n::Int = 0) where T <: Int
    if n == 0
        n = setoflaternatives(cf)
    elseif n < 0
        DomainError(n, "should be positive.")
    end    
    result = DiGraph(n)
    forbidden = Set{Tuple{Int, Int}}()
    for (key, value) in cf
        for i in key
            if i == value
                continue
            elseif has_edge(result, i, value)
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

"""
```strictUCR(cc::ChoiceCorrespondence{T}, n::Int = 0) where T <: Int```

Create the Strict UCR graph from an observed choice correspondence.
To speed-up computations, provide `n`, the number of alternatives.

# Arguments

- `cc`, a choice correspondence.
- `n`, the number of alternatives. If no value is provided, look at all the alternatives in the choice function, which is much slower.
"""
function strictUCR(cc::ChoiceCorrespondence{T}, n::Int = 0) where T <: Int
    if n == 0
        n = setoflaternatives(cc)
    elseif n < 0
        DomainError(n, "should be positive.")
    end    
    result = DiGraph(n)
    forbidden = Set{Tuple{Int, Int}}()
    for (key, value) in cc
        for k in key, v in value
            if k == v
                continue
            elseif has_edge(result, k, v)
                rem_edge!(result, k, v) 
                push!(forbidden, (k, v))
                push!(forbidden, (v, k))
            elseif !in((v, k), forbidden)                
                add_edge!(result, v, k)
            end
        end
    end
    return result
end

"""
```strictUCR(dg::DiGraph)```

Create the Strict UCR graph from an observed strict revealed preference.

# Arguments

- `dg`, a digraph from which we will build the strict unambiguous choice relation. This digraph should be the revealed preferences relation.
"""
function strictUCR(dg::DiGraph)
    res = DiGraph(nv(dg))
    for e in edges(dg)
        if !has_edge(dg, reverse(e))
            add_edge!(res, e)
        end
    end
    return res
end

"""
```fixedpoint(cc::ChoiceCorrespondence{T}, S::Vector{T}) where T <: Int```

Find the fixed points of a choice correspondence `cc` in a set `S`, according to the definition of Aleskerov et al (2007).

# Arguments

- `cc`, the choice correspondence;
- `S`, the set considered.
"""
function fixedpoint(cc::ChoiceCorrespondence{T}, S::Vector{T}) where T <: Int
    result = Vector{T}()
    for x in S
        bestx = true
        if in(x, cc[S]) 
            for (U, cU) in cc
                if issubset(U, S) & !(U == S) & in(x, U) & !in(x, cU)
                    bestx = false
                end
            end
            if bestx 
                push!(result, x)
            end
        end
    end
    return result
end

"""
```fixedpointpreferences(cc::ChoiceCorrespondence{T}, n::Int = 0) where T <: Int```

Return the preferences revealed with the Fixed Point axio of Aleskerov et al (2007).

# Arguments

- `cc`, the choice correspondence;
- `n`, the number of alternatives considered.
"""
function fixedpointpreferences(cc::ChoiceCorrespondence{T}, n::Int = 0) where T <: Int
    if n == 0
        n = setoflaternatives(cc)
    elseif n < 0
        DomainError(n, "should be positive.")
    end    
    dg = DiGraph(n)
    g = Graph(n)
    S = collect(1:n)
    FP = Vector{T}()
    while (length(S) >=2)
        bestS = fixedpoint(cc, S)
        if issubset(bestS, FP)
            return dg, g
        else
            FP = union(FP, bestS)
        end
        for x in bestS
            setdiff!(S, FP)
            for t in S
                add_edge!(dg, x, t)
            end
            for t in bestS
                if !(t == x) 
                    add_edge!(g, x, t)
                end
            end
        end
    end
    return dg, g
end
