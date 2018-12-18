void organisme_export(organisme o, String file) {
  o.compute_phenotype(false);
  JSONObject json = new JSONObject();
  JSONArray nodes = new JSONArray();
  for(node n : o.all_nodes) {
    JSONObject node_json = new JSONObject();
    String lettre = "";
    if(n.node_type == 1){
      lettre = "input";
    }
    else if(n.node_type == 2){
      lettre = "output";
    }
    else{
      lettre = "hidden";
    }
    node_json.setString("type", lettre);
    node_json.setInt("innovation_number", n.innovation);
    node_json.setInt("index", n.index);
    node_json.setInt("topological_sort_value", n.topological_sort_value);
    nodes.append(node_json);
  }
  JSONArray links = new JSONArray();
  for(gene g : o.phenotype) {
    JSONObject gene_json = new JSONObject();
    gene_json.setInt("input_node_innovation_number", g.input_node_object.innovation);
    gene_json.setInt("output_node_innovation_number", g.output_node_object.innovation);
    gene_json.setFloat("weight", g.weight);
    gene_json.setBoolean("enabled", g.enabled);
    links.append(gene_json);
  }
  
  json.setJSONArray("nodes", nodes);
  json.setJSONArray("links", links);
  
  saveJSONObject(json, "export/" + file, "compact");
}
