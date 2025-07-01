params.graph = "test_graph.gfa"
params.base_config = "base_config.yaml"

process panacus_config {
	publishDir 'results/config'

    input:
	path graph
	path base_config

    output:
    path "${graph.getBaseName()}.yaml"

    script:
    """
    cat ${base_config} | sed "s|{{GRAPH}}|${graph}|" > "${graph.getBaseName()}.yaml"
    """	
}

process panacus {
	conda 'bioconda::panacus'
	publishDir 'results/panacus'

	input:
	path config
	path graph

	output:
	path "${config.getBaseName()}.html"

	script:
	"""
	panacus report '${config}' > "${config.getBaseName()}.html"
	"""
}

workflow {
	def ch_graph = channel.fromPath(params.graph)
	panacus_config(ch_graph, file(params.base_config))
	panacus(panacus_config.out, ch_graph)
}
