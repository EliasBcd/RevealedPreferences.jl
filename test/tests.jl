using RevealedPreferences


graph_size = 4

wdg = WeightedDigraph(complete_digraph(graph_size), ones(Int, graph_size, graph_size))