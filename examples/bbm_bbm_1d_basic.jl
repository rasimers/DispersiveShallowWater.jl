using OrdinaryDiffEq
using DispersiveShallowWater

###############################################################################
# Semidiscretization of the BBM-BBM equations

equations = BBMBBMEquations1D(gravity_constant = 9.81, D = 2.0)

# initial_condition_convergence_test needs periodic boundary conditions
initial_condition = initial_condition_convergence_test
boundary_conditions = boundary_condition_periodic

# create homogeneous mesh
coordinates_min = -35.0
coordinates_max = 35.0
N = 512
mesh = Mesh1D(coordinates_min, coordinates_max, N + 1)

# create solver with periodic SBP operators of accuracy order 4
solver = Solver(mesh, 4)

# semidiscretization holds all the necessary data structures for the spatial discretization
semi = Semidiscretization(mesh, equations, initial_condition, solver,
                          boundary_conditions = boundary_conditions)

###############################################################################
# Create `ODEProblem` and run the simulation
tspan = (0.0, 30.0)
dt = 0.025
ode = semidiscretize(semi, tspan)
analysis_callback = AnalysisCallback(semi; interval = 10,
                                     extra_analysis_errors = (:conservation_error,),
                                     extra_analysis_integrals = (waterheight_total,
                                                                 velocity, entropy))
callbacks = CallbackSet(analysis_callback)

saveat = range(tspan..., length = 100)
sol = solve(ode, RK4(), abstol = 1.0e-7, reltol = 1.0e-7, dt = dt, adaptive = false,
            save_everystep = false, callback = callbacks, saveat = saveat)
