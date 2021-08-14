### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 918f19ba-fbea-11eb-3ea2-69264fd4e3f8
begin 
	using PlutoUI
	using CSV
	using HTTP
	using DataFrames
end

# ╔═╡ 5d6aa767-53f5-402b-96e5-5a81da74e751
md"""Esta es una implementación para solucionar el problema del agente viajero para los pueblos mágicos de interes de un estado dado. Este problema utiliza exploración exhaustiva para resolver este problema NP-Hard, en específico utiliza el método de backtracking.}

Este programa asume que el usuario desea empezar y terminar en un pueblo mágico específico


Artemio Santiago Padilla Robles"""

# ╔═╡ cdfe08c5-01ea-4917-b1d1-991e68eedc4a
md"Importamos una matriz de distancias entre los pueblos mágicos"

# ╔═╡ a781bb30-c3bf-4c15-9792-08d3c1759a70
begin
	url = "https://raw.githubusercontent.com/ArtemioPadilla/MxMagicTowns-PueblosMagicosMx/main/dataframes/dist_df.csv";
	magic_distances = CSV.File(HTTP.get(url).body);
	df = DataFrame(magic_distances);
	df;
	print()
end

# ╔═╡ 483ae95a-0480-4e73-90e9-41921d4016ec
estados = ["Aguascalientes", "Baja California", "Baja California Sur", "Campeche", "Coahuila", "Colima", "Chiapas","Chihuahua", "Durango", "Guanajuato","Guerrero", "Hidalgo", "Jalisco", "Mexico","Michoacan","Morelos","Nayarit","Nuevo Leon","Oaxaca","Puebla","Queretaro","Quintana Roo","San Luis Potosi","Sinaloa","Sonora","Tabasco","Tamaulipas","Tlaxcala","Veracruz","Yucatan","Zacatecas"];

# ╔═╡ beccd2f7-2c1f-45f6-bd85-6b67f21274c0
md"""¿Qué estado quieres conocer? $(@bind estado_selected Select(estados))"""

# ╔═╡ 7049e8ec-9e75-4aa0-b898-001fe689c41a
begin
	if length(estados) == 0
		"No has seleccionado ningun estado"
	else
		cond1 = startswith.(df.Column1, estado_selected)
		mask1 = [i for (i, mask) in enumerate(cond1) if mask == 1]
		cond2 = startswith.(names(df), estado_selected)
		mask2 = [i for (i, mask) in enumerate(cond2) if mask == 1]
		#select(df, cond1,df.Column1)
		dists = df[mask1,mask2]
		
		pueblos_raw = names(dists)
		pueblos = [replace(pueblo,estado_selected*", " => "") for pueblo in pueblos_raw];
		rename!(dists, pueblos);
		print()
	end
end

# ╔═╡ d86c2589-5472-4645-a0a7-94a2283dceb2
md"""¿Qué pueblos mágicos quieres conocer? $(@bind pueblos_selected MultiCheckBox(pueblos,  select_all=true))"""

# ╔═╡ f1685d1b-c200-4569-9dbc-6cbf31a4824c
md"La matriz de distancias entre los pueblos mágicos seleccionados es:"

# ╔═╡ 52c9fffe-2b4b-475f-8dd8-822778e09ec7
begin
	mask_1_ = [i for (i,pueblo) in enumerate(pueblos) if pueblo in pueblos_selected]
	mask_2_ = [pueblo for (i,pueblo) in enumerate(pueblos) if pueblo in pueblos_selected]
	graph = dists[mask_1_,mask_2_]
end

# ╔═╡ 7f9ae6f4-afa4-4d42-8371-da291c6fd54a
md"""¿En cual pueblo mágico deseas empezar? $(@bind start Select(names(graph)))"""

# ╔═╡ d99c7128-88e0-40cf-b9f2-25a266f2ce39
begin 
idx = 0
	for i in 1:length(pueblos_selected)
		if start == pueblos_selected[i]
			idx = i
		end
	end
	idx
end;

# ╔═╡ aa7d6056-915d-4699-a4b1-cf53998de29b
md"Definimos la función para resolver TSP por backtrack"

# ╔═╡ d1b72a99-300f-45f7-9881-ffcc831fda66
function TSP(DistMat, vis=nothing, actual=nothing, n=nothing, count=nothing, km=nothing, path=nothing) 
	if vis == nothing
	  global bestpath
	  global costomin
      n = length(DistMat) # El número de nodos es una de las dimensiones de la matriz de distancias
      vis = [false for i in 1:n] # Inicializamos una lista para guardar los nodos visitados
      # Inicializamos las variables necesarias
      vis[1] = true
      km = 0
      # Contamos el inicio y lo marcamos como visitado
      count = 1 
      actual = 1
      path = [1]
      # Inicializamos el costo mínimo como un número muy grande
      costomin=10e20
	end
	
	
    if count == n # Si hemos recorrido los n vértices 
		if km + DistMat[actual][1] < costomin  # Si el costo acumulado + el costo de regresar es menor al costo mínimo actualizamos la mejor solución
			costomin = km + DistMat[actual][1]# Actualizamos el costo
			bestpath = path # Actualizamos la mejor ruta
			push!(bestpath, 1) # Agregamos el 1 para indicar que regresamos
			return costomin, bestpath
		end
	end
			
    for i in 1:n  # Para cada nodo
      # Si no lo hemos visitado, no nos quemos en el mismo vertice y el costo es menor al costo mínimo al momento
		if vis[i] == false && DistMat[actual][i] != 0
			  push!(path, i) # Agregamos el nodo al camino
			  vis[i] = true # Marcamos como visitado el nodo i
			  TSP(DistMat, copy(vis), i, n, count + 1, km + DistMat[actual][i], copy(path)) # Exploramos el espacio de estados
			  filter!(x->x≠i,path)#path.remove(i) # Hacemos backtrack
			  vis[i] = false # Quitamos el nodo de los nodos visitados
		end
	end
	
    return costomin, bestpath
	
end

# ╔═╡ 2c7ca528-735e-4f73-a432-539b091aca57
md"Una prueba"

# ╔═╡ e52f592e-f8d9-486a-9051-0e477b65cd20
begin
	graph_test = [[10e10, 2, 10e10, 6, 10e10],  
        [2, 10e10, 3, 8, 5]  , 
        [10e10, 3, 10e10, 10e10, 7],  
        [6, 8, 10e10, 10e10, 9], 
        [10e10, 5, 7, 9, 10e10]] 
end;

# ╔═╡ e333972f-939e-4927-8000-660ed66344e6
TSP(graph_test)

# ╔═╡ f18f67bf-bb52-46a5-a679-ad7cfc39b112
md"Solucionamos el problema"

# ╔═╡ 6812cb1e-e7f2-4091-b168-84cb9172f134
to_solve = [graph[:,i] for i in 1:nrow(graph)];

# ╔═╡ 792fb062-088e-4d00-acda-f235821aeab0
begin
	if length(pueblos_selected)==0
		with_terminal() do 
		println("No ha seleccionado ningún pueblo")
		end
	elseif length(pueblos_selected)<4
		with_terminal() do 
			println("Necesita seleccionar al menos 4 pueblos")
			println("Con 3 o menos pueblos solo recorralos como guste")
		end
	else
		start_idx = 0
		with_terminal() do 
			println("Procediendo a calcular ruta optima")
			km,ruta = TSP(to_solve)
			println()
			println("La ruta recomendada es:")
			println()
			n = length(pueblos_selected)
			for i in 1:n
				if ruta[i] == idx
					start_idx = i
				end
			end
			
			for i in start_idx:n+start_idx
				j = mod(i-1, n)+1
				println(names(graph)[ruta[j]])
			end
			
			println()
			println("Con un recorrido aproximado de " * string(floor(km))* " kms")
			
		end
		
	end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CSV = "~0.8.5"
DataFrames = "~1.2.2"
HTTP = "~0.9.13"
PlutoUI = "~0.7.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[CSV]]
deps = ["Dates", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode"]
git-tree-sha1 = "b83aa3f513be680454437a0eee21001607e5d983"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.8.5"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "344f143fa0ec67e47917848795ab19c6a455f32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.32.0"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "ee400abb2298bd13bfc3df1c412ed228061a2385"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.7.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d785f42445b63fc86caa08bb9a9351008be9b765"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "44e3b40da000eab4ccb1aecdc4801c040026aeb5"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.13"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InvertedIndices]]
deps = ["Test"]
git-tree-sha1 = "15732c475062348b0165684ffe28e85ea8396afc"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.0.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "4ea90bd5d3985ae1f9a908bd4500ae88921c5ce7"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "bfd7d8c7fd87f04543810d9cbd3995972236ba1b"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.2"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "cde4ce9d6f33219465b55162811d8de8139c0414"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.2.1"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "0d1245a357cc61c8cd61934c07447aa569ff22e6"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.1.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "a3a337914a035b2d59c9cbe7f1a38aaba1265b02"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.6"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "d0c690d37c73aeb5ca063056283fde5585a41710"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.5.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─5d6aa767-53f5-402b-96e5-5a81da74e751
# ╠═918f19ba-fbea-11eb-3ea2-69264fd4e3f8
# ╟─cdfe08c5-01ea-4917-b1d1-991e68eedc4a
# ╟─a781bb30-c3bf-4c15-9792-08d3c1759a70
# ╟─483ae95a-0480-4e73-90e9-41921d4016ec
# ╟─beccd2f7-2c1f-45f6-bd85-6b67f21274c0
# ╟─7049e8ec-9e75-4aa0-b898-001fe689c41a
# ╟─d86c2589-5472-4645-a0a7-94a2283dceb2
# ╟─f1685d1b-c200-4569-9dbc-6cbf31a4824c
# ╟─52c9fffe-2b4b-475f-8dd8-822778e09ec7
# ╟─7f9ae6f4-afa4-4d42-8371-da291c6fd54a
# ╟─d99c7128-88e0-40cf-b9f2-25a266f2ce39
# ╟─aa7d6056-915d-4699-a4b1-cf53998de29b
# ╠═d1b72a99-300f-45f7-9881-ffcc831fda66
# ╟─2c7ca528-735e-4f73-a432-539b091aca57
# ╠═e52f592e-f8d9-486a-9051-0e477b65cd20
# ╠═e333972f-939e-4927-8000-660ed66344e6
# ╟─f18f67bf-bb52-46a5-a679-ad7cfc39b112
# ╟─6812cb1e-e7f2-4091-b168-84cb9172f134
# ╟─792fb062-088e-4d00-acda-f235821aeab0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
