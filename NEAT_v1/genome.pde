class genome{
  public ArrayList<innovable> genetique;
  public ArrayList<node> nodes;
  public ArrayList<gene> connexions;
  public int nb_input_nodes;
  public int nb_output_nodes;
  public int nb_node_genes;
  public int nb_connexion_genes;
  public int index_derniere_node_ajoute;
  public boolean au_moins_une_connexion;
  public genome(int nb_input_nodes, int nb_output_nodes, boolean empty){
    this.genetique = new ArrayList<innovable>();
    this.nodes = new ArrayList<node>();
    this.connexions = new ArrayList<gene>();
    this.au_moins_une_connexion = false;
    this.nb_connexion_genes = 0;
    this.nb_node_genes = 0;
    this.index_derniere_node_ajoute = 0;
    this.nb_input_nodes = nb_input_nodes;
    this.nb_output_nodes = nb_output_nodes;
    if(!empty){
      for(int i = 0; i < nb_input_nodes; i++){
        node a_ajouter = new node(1, i);
        int innovation_number_node = innovation.trouver_node(a_ajouter.index);
        if(innovation_number_node == -1){
          innovation_number_node = innovation.next();
          innovation.innovations_of_current_generation.add(a_ajouter);
        }
        a_ajouter.innovation = innovation_number_node;
        add_gene(a_ajouter); //1 = input, 2 = output, 3 = hidden
      }
      for(int i = 0; i < nb_output_nodes; i++){
        node a_ajouter = new node(2, i + nb_input_nodes);
        int innovation_number_node = innovation.trouver_node(a_ajouter.index);
        if(innovation_number_node == -1){
          innovation_number_node = innovation.next();
          innovation.innovations_of_current_generation.add(a_ajouter);
        }
        a_ajouter.innovation = innovation_number_node;
        
        add_gene(a_ajouter); //1 = input, 2 = output, 3 = hidden
      }
    }
    
  }
  
  public void add_gene(innovable gene){
    boolean reorder = false;
    if(this.genetique.size() > 0 && gene.innovation < this.genetique.get(this.genetique.size() - 1).innovation){
      reorder = true;
    }
    genetique.add(gene);
    if(gene instanceof gene){
      this.connexions.add((gene)gene);
      this.au_moins_une_connexion = true;
    }
    else if(gene instanceof node){
      node node_ajoutee = ((node)gene);
      this.nodes.add(node_ajoutee);
      this.index_derniere_node_ajoute = node_ajoutee.index;
    }
    if(reorder){
      Collections.sort(this.genetique);
      Collections.sort(this.nodes);
      Collections.sort(this.connexions);
    }
  }
  
  public void print(){
    for(innovable connexion_gene : this.genetique){
      if(connexion_gene instanceof gene){
        gene connexion = (gene)connexion_gene;
        println(connexion.input_node_index, connexion.output_node_index);
      }
    }
  }
  
  public boolean check_if_nodes_already_connected(int index_node_1, int index_node_2){
    boolean do_debug = false;
    for(innovable connexion_gene : this.genetique){
      if(connexion_gene instanceof gene){
        gene connexion = (gene)connexion_gene;
        if(do_debug){
          println(connexion.input_node_index, connexion.output_node_index);
        }
        if(
          (connexion.input_node_index == index_node_1 && connexion.output_node_index == index_node_2) ||
          (connexion.input_node_index == index_node_2 && connexion.output_node_index == index_node_1)
        ){
          if(do_debug){
            println("ALREADY EXISTS");
          }
          return true;
        }
      }
    }
    if(do_debug){
      println("NOT FOUND");
    }
    return false;
  }
}