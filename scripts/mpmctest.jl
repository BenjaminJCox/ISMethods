using DrWatson
using Optim
using Distributions
using Plots
using LinearAlgebra

plotlyjs()

include(srcdir("pop_mc.jl"))
include(srcdir("gapis.jl"))

tgt(x, y) =
    0.5 * pdf(MvNormal([-5.0, -5.0], [1.0 0.0; 0.0 1.0]), [x, y]) + 0.5 * pdf(MvNormal([5.0, 5.0], [1.0 0.0; 0.0 1.0]), [x, y])
tgt(x) = tgt(x[1], x[2])

xsq = collect(range(-10, 10, length = 100))
ysq = xsq

fv = zeros(100, 100)
for i = 1:100
    for j = 1:100
        fv[j, i] = tgt(xsq[j], ysq[i])
    end
end

plot(xsq, ysq, fv, st = :heatmap)

pf1 = MvNormal
pf2 = MvNormal

function rcf(x::Vector, no)
    rv = [x[1], x[2]]
    return [rv, no[1]]
end


pfs = [pf1, pf2]
rcfs = [rcf, rcf]
pws = [1.0, 1.0]
parameters = [[[2.0, 2.0], [1.0 0.0; 0.0 1.0]], [[-2.0, -2.0], [1.0 0.0; 0.0 1.0]]]
nooptim = [[2], [2]]
global nv = mpmc_step(tgt, pfs, pws, parameters, 500, rcfs, nooptim, 2)

for t = 1:10
    global nv = mpmc_step(tgt, pfs, nv[2], nv[3], 500, rcfs, nooptim, 2)
end

plot!(nv[1][1, :], nv[1][2, :], st = :scatter, legend = false)

pfs = [pf1, pf2]
locations = [[2.0, 2.0], [-2.0, -2.0]]
scales = [[1.0 0.0; 0.0 1.0], [1.0 0.0; 0.0 1.0]]
global nv = gapis_step(tgt, pfs, locations, scales, 250, 0.1, 2)

for t = 1:40
    global nv = gapis_step(tgt, pfs, nv[2], nv[3], 250, 0.1, 2)
end

plot!(nv[1][1, :], nv[1][2, :], st = :scatter, legend = false)