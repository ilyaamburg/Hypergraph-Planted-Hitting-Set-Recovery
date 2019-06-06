include("common.jl")
function BorgattiEverett_order(A::SpIntMat, max_iter::Int64=10000,
                               tol::Float64=1e-10)
    n = size(A, 1)
    d = vec(sum(A, dims=2))
    c = rand(n)
    c[d .== 0] .= 0
    c /= norm(c, 2)
    for iter = 1:max_iter
        num = A * c
        denom = sum(c .^ 2) .- c .^ 2
        next_c = num ./ denom
        next_c /= norm(next_c, 2)
        diff = norm(next_c - c, 2)
        c = next_c
        if diff < tol; break; end
    end
    return sort(collect(1:n), by= v -> c[v], rev=true)
end
