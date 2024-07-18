# RevealedPreferences.jl

![Build Status](https://github.com/EliasBcd/RevealedPreferences.jl/actions/workflows/CI.yml/badge.svg?branch=master)
[![codecov.io](https://codecov.io/github/EliasBcd/RevealedPreferences.jl/coverage.svg?branch=master)](https://app.codecov.io/github/EliasBcd/RevealedPreferences.jl?branch=master)

A library for revealed preferences analysis using Julia.
The analysis can start from a choice function, a choice correspondence or prices and quantities.

The library implements classical axioms of revealed preferences (Sen's axioms, the Weak and Strong Axiom of Revealed Preferences, and so on)
It also implements some indices of rationality (Houtman-Maks and the swap index for now).

<!--MCI should be computed from a weighted DiGraph.
MCI, MPI and HMI should be computed from prices and quantities directly, at the individual level.-->
