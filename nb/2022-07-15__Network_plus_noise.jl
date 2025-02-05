# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     formats: ipynb,jl:light
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.13.7
#   kernelspec:
#     display_name: Julia 1.7.0
#     language: julia
#     name: julia-1.7
# ---

# # 2022-07-15 • Network + VI Noise

# ## Imports

# +
#
# -

using Revise

using MyToolbox

using VoltoMapSim

# ## Params

# Based on Roxin; same as previous nb's.

d = 6
p = get_params(
    duration = 10minutes,
    p_conn = 0.04,
    g_EE = 1   / d,
    g_EI = 18  / d,
    g_IE = 36  / d,
    g_II = 31  / d,
    ext_current = Normal(-0.5 * pA/√seconds, 5 * pA/√seconds),
    E_inh = -80 * mV,
    to_record = [1, 801],
);
dumps(p)

# ## Run sim

s = cached(sim, [p.sim]);

s = augment_simdata(s, p);

# ## Add VI noise; eval conntest perf

SNRs = [Inf, 10, 4, 2, 1];

function get_detection_rates(m; verbose = true)
    detrates = []
    for SNR in SNRs
        q = (@set p.imaging.spike_SNR = SNR)
        vi = add_VI_noise(s.signals[m].v, q)
        ii = get_input_info(m, s, q)
        verbose && @show SNR
        perf = cached(evaluate_conntest_perf, [vi, ii.spiketrains, q], key = [q, m])
        verbose && println(perf.detection_rates, "\n")
        push!(detrates, perf.detection_rates)
    end
    return detrates
end;

# ## Plot

import PyPlot

using VoltoMapSim.Plot

function plotdetrates(m, title)
    rates = get_detection_rates(m, verbose = false)
    plot_detection_rates(rates, p; title,
        xticklabels = [@sprintf "%.3G" x for x in SNRs],
        xlabel = "Imaging noise (spike-SNR)",
    )
end;

fig, ax = plotdetrates(1, "Excitatory neuron");

plotdetrates(801, "Inhibitory neuron");


