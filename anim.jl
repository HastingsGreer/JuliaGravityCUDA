using DynamicalSystems
using OrdinaryDiffEq
using GLMakie
using DataStructures: CircularBuffer
using LinearAlgebra
using CUDA

using GLMakie

function doit()
	N = 17588

	px =CuArray( randn(N) )
	py =CuArray( randn(N) ) 
	pz =CuArray( randn(N) ) 
	pz[100:end] .*= .1
	vx =CuArray( (py) / 66 )
	vy =CuArray( (-px) / 66 )
	vz =CuArray( vx .* .1 )

	px_cpu = Array(px)
	py_cpu = Array(py)


	px_n = Observable(px_cpu)
	py_n = Observable(py_cpu)

	display(plot([0]))


	scatter!(px_n, py_n, focus_on_show=false, markersize=1)

	#ylims!(-1, 2)
	#xlims!(-1, 2)
	#
	dx = CuArray(zeros(N, N))
	dy = CuArray(zeros(N, N))
	dz = CuArray(zeros(N, N))
	dist = CuArray(zeros(N, N))


	for t in 1:90
	    px .= px .+ vx
	    py .= py .+ vy
	    pz .= pz .+ vz

	    dx .= px .- px'
	    dy .= py .- py'
	    dz .= pz .- pz'

	    
	    dist .= (sqrt.(dx .^ 2 .+ dy .^ 2 .+ dz .^ 2) .+ .01) .^ (-3)



	    dx .*= dist
	    dy .*= dist
	    dz .*= dist


	    fxs = dropdims(sum(dx, dims=1), dims=1)

	    fys = dropdims(sum(dy, dims=1), dims=1)
	    fzs = dropdims(sum(dz, dims=1), dims=1)


	    vx .= vx .+ fxs ./ 10000000
	    vy .= vy .+ fys ./ 10000000
	    vz .= vz .+ fzs ./ 10000000




		px_cpu .= Array(px)
		py_cpu .= Array(py)

	    py_n[] = py_n[]
	    sleep(0.01)
	end
end
doit()
