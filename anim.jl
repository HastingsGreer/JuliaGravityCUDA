using FLoops, FoldsCUDA
#using DynamicalSystems
#using OrdinaryDiffEq
using GLMakie
using DataStructures: CircularBuffer
using LinearAlgebra
using CUDA

using GLMakie

function doit()
    N = 37588

	#px =2 * (CuArray( Float32.(rand(N) )) .- .5f0)
    #py =2 * (CuArray( Float32.(rand(N) )) .- .5f0)
    #pz =2 * (CuArray( Float32.(rand(N) )) .- .5f0)
	px =CuArray( Float32.(randn(N) ) )
    py =CuArray( Float32.(randn(N) ) )
    pz =CuArray( Float32.(randn(N) ) )
    pz[100:end] .*= .4f0
    vx = CuArray( (py) / 660 )
    vy = CuArray( (-px) / 660 )
    vz = CuArray( vx .* 1f-1 )

    px_cpu = Array(px)
    py_cpu = Array(py)


    px_n = Observable(px_cpu)
    py_n = Observable(py_cpu)

	clear!()
	
	plot!([0], focus_on_show=false)


    scatter!(px_n, py_n, focus_on_show=false, markersize=.5)
	xlims!(-4, 4)
	ylims!(-4, 4)



    for t in 1:60
		px .= px + vx
		py .= py + vy
		pz .= pz + vz

        @floop CUDAEx() for i in eachindex(vx, vy, vz)
			fx = 0.0f1
			fy = 0.0f1
			fz = 0.0f1

			for j in 1:N
				dx = -px[i] + px[j]
				dy = -py[i] + py[j]
				dz = -pz[i] + pz[j]

				dist = sqrt(dx^2 + dy ^2 + dz ^2)
				dist = (dist + 1f-6 )^-3

				dx *= dist
				dy *= dist
				dz *= dist

				fx += dx
				fy += dy
				fz += dz
			end
			vx[i] = vx[i] + fx / 5000000000
			vy[i] = vy[i] + fy / 5000000000
			vz[i] = vz[i] + fz / 5000000000
		end



        px_cpu .= Array(px)
		#py_cpu .= Array(pz)
		py_cpu .= Array(py) .* .5 .+ Array(pz) .* sqrt(3) ./ 2
	

        py_n[] = py_n[]
    end
end
@time doit()
