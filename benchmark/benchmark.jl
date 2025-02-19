
using OrdinaryDiffEq, StaticArrays, BenchmarkTools, Sundials, LSODA

println("Lorenz")
# Lorenz
function lorenz_static(u,p,t)
    @inbounds begin
        dx = p[1]*(u[2]-u[1])
        dy = u[1]*(p[2]-u[3]) - u[2]
        dz = u[1]*u[2] - p[3]*u[3]
    end
    @SVector [dx,dy,dz]
end
u0 = @SVector [1.0,0.0,0.0]
p  = @SVector [10.0,28.0,8/3]
tspan = (0.0,100.0)
prob = ODEProblem(lorenz_static,u0,tspan,p)
@btime solve(prob,Tsit5(),saveat=0.1,reltol=1.0e-8,abstol=1.0e-8) # 2.612 ms (30 allocations: 59.22 KiB)

println("\nRober")
# rober
function rober(du,u,p,t)
    y₁,y₂,y₃ = u
    k₁,k₂,k₃ = p
    @inbounds begin
    du[1] = -k₁*y₁+k₃*y₂*y₃
    du[2] =  k₁*y₁-k₂*y₂^2-k₃*y₂*y₃
    du[3] =  k₂*y₂^2
    end
    nothing
end
prob = ODEProblem(rober,[1.0,0.0,0.0],(0.0,1e5),[0.04,3e7,1e4]) 

@btime solve(prob,Rosenbrock23(),reltol=1.0e-8,abstol=1.0e-8, saveat = 1000) # 1.035 ms (4518 allocations: 250.12 KiB)
@btime solve(prob,TRBDF2(),reltol=1.0e-8,abstol=1.0e-8, saveat = 1000) # 5.765 ms (11415 allocations: 524.14 KiB)
@btime solve(prob,CVODE_BDF(),reltol=1.0e-8,abstol=1.0e-8, saveat = 1000) # 1.115 ms (6954 allocations: 295.83 KiB)
@btime solve(prob,lsoda(),reltol=1.0e-8,abstol=1.0e-8, saveat = 1000) # 263.684 μs (2169 allocations: 185.09 KiB)
