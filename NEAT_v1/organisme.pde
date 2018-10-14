class organisme implements Comparable<organisme>{
  public genome genome;
  public Float fitness;
  public float factor_excess = 1;
  public float factor_disjoint = 1;
  public float factor_matching_genes = 1;
  public ArrayList<gene> phenotype;
  public ArrayList<node> inputs;
  public ArrayList<node> outputs;
  public ArrayList<node> all_nodes;
  float weight_mutation_chance = 0.015;
  float add_connection_mutation_chance = 0.005;
  float add_node_mutation_chance = 0.0001;
  float disabled_if_any_chance = 0.5;
  float enabled_if_any_chance = 2;  
  public specie espece_parent;
  public float adjusted_fitness;
  public organisme(int nb_input_nodes, int nb_output_nodes){
    this.fitness = 0f;
    this.genome = new genome(nb_input_nodes, nb_output_nodes, false);
  }
  
  public void propagate(Boolean debug){
    //suppose que le phenotype est généré
    for(node node_to_reset : this.all_nodes){
      if(node_to_reset.node_type != 1){
        node_to_reset.value = 0;
      }
      node_to_reset.has_triggered = false;
      
    }
    if(this.phenotype.size() == 0){
      return;
    }
    for(gene connexion : this.phenotype){
      if (debug) {
        println(connexion.input_node_index + " (" + connexion.input_node_object.innovation + ") " + "->" + connexion.output_node_index + " (" + connexion.output_node_object.innovation + ")");
      }
      
      connexion.output_node_object.value += connexion.input_node_object.value * connexion.weight;
    }
  }
  
  public void draw_phenotype(){
    if(this.phenotype == null){
      return;
    }
    HashMap<Integer,Integer> highestNodeIndexPerType = new HashMap<Integer,Integer>();
    HashMap<Integer,Integer> lowestNodeIndexPerType = new HashMap<Integer,Integer>();
    for(gene connexion : this.phenotype){
      Integer highestInputIndex = highestNodeIndexPerType.get(connexion.input_node_object.node_type);
      if (highestInputIndex == null || highestInputIndex < connexion.input_node_index) {
        highestNodeIndexPerType.put(connexion.input_node_object.node_type, connexion.input_node_index);
      }
      Integer lowestInputIndex = lowestNodeIndexPerType.get(connexion.input_node_object.node_type);
      if (lowestInputIndex == null || lowestInputIndex > connexion.input_node_index) {
        lowestNodeIndexPerType.put(connexion.input_node_object.node_type, connexion.input_node_index);
      }
      
      Integer highestOutputIndex = highestNodeIndexPerType.get(connexion.output_node_object.node_type);
      if (highestOutputIndex == null || highestOutputIndex < connexion.output_node_index) {
        highestNodeIndexPerType.put(connexion.output_node_object.node_type, connexion.output_node_index);
      }
      Integer lowestOutputIndex = lowestNodeIndexPerType.get(connexion.output_node_object.node_type);
      if (lowestOutputIndex == null || lowestOutputIndex > connexion.output_node_index) {
        lowestNodeIndexPerType.put(connexion.output_node_object.node_type, connexion.output_node_index);
      }
    }
    for(gene connexion : this.phenotype){
      node input_node = connexion.input_node_object;
      node output_node = connexion.output_node_object;
      
      if(input_node.x == -1 && input_node.y == -1){
        int mult = 0;
        if (input_node.node_type == 2){
          mult = 2;
        } else if(input_node.node_type == 3) {
          mult = 1;
        }
        input_node.x = mult * (width/3) + 50;
        int nodeIndexDiff = highestNodeIndexPerType.get(input_node.node_type) - lowestNodeIndexPerType.get(input_node.node_type);
        input_node.y = (input_node.index - lowestNodeIndexPerType.get(input_node.node_type)) * (height/(nodeIndexDiff + 1)) + 50;
      }
      if(output_node.x == -1 && output_node.y == -1){
        int mult = 0;
        if (output_node.node_type == 2){
          mult = 2;
        } else if(output_node.node_type == 3) {
          mult = 1;
        }
        output_node.x = mult * (width/3) + 50;
        int nodeIndexDiff = highestNodeIndexPerType.get(output_node.node_type) - lowestNodeIndexPerType.get(output_node.node_type);
        output_node.y = (output_node.index - lowestNodeIndexPerType.get(output_node.node_type)) * (height/(nodeIndexDiff + 1)) + 50;
      }
      connexion.draw_phenotype_connection(input_node.x, input_node.y, output_node.x, output_node.y);
      input_node.draw_phenotype();
      output_node.draw_phenotype();
    }
    for(gene connexion : this.phenotype){
      node input_node = connexion.input_node_object;
      node output_node = connexion.output_node_object;
      connexion.draw_phenotype_label(input_node.x, input_node.y, output_node.x, output_node.y);
    }
  }
  
  public void compute_phenotype(boolean output){
    if(this.phenotype != null){
      return;
    }
    this.inputs = new ArrayList<node>();
    this.outputs = new ArrayList<node>();
    Queue<node> node_queue = new LinkedList<node>();
    ArrayList<node> nodes_deja_connectes = new ArrayList<node>();
    this.all_nodes = new ArrayList<node>();
    ArrayList<gene> mes_connexions = new ArrayList<gene>();
    this.phenotype = new ArrayList<gene>();
    if(output){
      println("");
    }
    for(innovable element_genome : this.genome.genetique){
      if(element_genome instanceof node){
        node element_node = (node)element_genome;
        //Ajoute toutes les nodes input à une queue de node
        if(element_node.node_type == 1){
          this.inputs.add(element_node);
          node_queue.add(element_node);
          nodes_deja_connectes.add(element_node);
        }
        else if(element_node.node_type == 2){
          this.outputs.add(element_node);
        }
        this.all_nodes.add(element_node);
        
      }
      else{
        gene element_connexion = (gene)element_genome;
        if(output){
          println(element_connexion.input_node_index, "->", element_connexion.output_node_index);
        }
        if(element_connexion.enabled){
          mes_connexions.add(element_connexion);
        }
      }
    }
    
    //Tant qu'il y a des nodes dans la queue de node
    ArrayList<gene> connexions_a_supprimer = new ArrayList<gene>();
    while(node_queue.size() != 0){
      //Dequeue la node courante
      node node_a_connecter = node_queue.remove();
      //Trouve les liens vers autre nodes qui sont actifs
      for(gene connexion : mes_connexions){
        if(connexion.input_node_index == node_a_connecter.index){
          boolean a = false;
          for(node node_output_recherche : this.all_nodes){
            if(node_output_recherche.index == connexion.output_node_index){
              if(!nodes_deja_connectes.contains(node_output_recherche)){
                //Ajoute la node out a la queue de node si elle n'y est pas déjà ou n'y a pas déjà été
                node_queue.add(node_output_recherche);
                nodes_deja_connectes.add(node_output_recherche);
              }
              a = true;
              connexion.output_node_object = node_output_recherche;
              break;
            }
          }
          if(!a){
            for(node node_output_recherche : this.all_nodes){
              println(node_output_recherche.index + " I:" + node_output_recherche.innovation);
            }
            for(gene connexion_debug : mes_connexions){
              println("connexion: " + connexion_debug.input_node_index + "->" + connexion_debug.output_node_index + " I:" + connexion_debug.innovation);
            }
            println(connexion.output_node_index);
          }
          connexion.input_node_object = node_a_connecter;
          //Ajoute les liens à la liste de liens en ordre
          this.phenotype.add(connexion);
          connexions_a_supprimer.add(connexion);
        }
      }
      mes_connexions.removeAll(connexions_a_supprimer);
      connexions_a_supprimer.clear();
    }
  }
  
  public organisme(genome genome){
    this.fitness = 0f;
    this.genome = genome;
  }
  
  @Override
  public int compareTo(organisme ai) {
      return ((Float)adjusted_fitness).compareTo(ai.adjusted_fitness);
  }
  
  public float compute_compatibility_distance(organisme autre){
    int number_of_genes_in_larger_genome = autre.genome.genetique.size() > this.genome.genetique.size() ? autre.genome.genetique.size() : this.genome.genetique.size();
    //TODO : Paramétriser le 20
    if(autre.genome.genetique.size() < 20 && this.genome.genetique.size() < 20){
      number_of_genes_in_larger_genome = 1;
    }
    int index_watcher = 0;
    int plus_grand_genome_offset = 0;
    int plus_petit_genome_offset = 0;
    float weight_difference_of_matching_genes = 0;
    int number_of_matching_genes = 0;
    
    genome plus_petit_genome = null;
    genome plus_grand_genome = null;
    if(autre.genome.genetique.size() <  this.genome.genetique.size()){
      plus_petit_genome = autre.genome;
      plus_grand_genome = this.genome;
    }
    else{
      plus_grand_genome = autre.genome;
      plus_petit_genome = this.genome;
    }
    while((index_watcher - plus_petit_genome_offset) < plus_petit_genome.genetique.size() && (index_watcher - plus_grand_genome_offset) < plus_grand_genome.genetique.size()){
      innovable plus_petit_genome_innovable = plus_petit_genome.genetique.get(index_watcher - plus_petit_genome_offset);
      innovable plus_grand_genome_innovable = plus_grand_genome.genetique.get(index_watcher - plus_grand_genome_offset);
      int plus_petit_genome_innovation = plus_petit_genome_innovable.innovation;
      int plus_grand_genome_innovation = plus_grand_genome_innovable.innovation;
      if(plus_petit_genome_innovation > plus_grand_genome_innovation){
        plus_petit_genome_offset++;
      }
      else if(plus_grand_genome_innovation > plus_petit_genome_innovation){
        plus_grand_genome_offset++;
      }
      else if(plus_petit_genome_innovable instanceof gene && plus_grand_genome_innovable instanceof gene){
        gene plus_petit_genome_gene = (gene)plus_petit_genome_innovable;
        gene plus_grand_genome_gene = (gene)plus_grand_genome_innovable;
        number_of_matching_genes++;
        weight_difference_of_matching_genes += abs(plus_grand_genome_gene.weight - plus_petit_genome_gene.weight);
      }
      
      index_watcher++;
    }
    
    int disjoint_count = plus_grand_genome_offset + plus_petit_genome_offset;
    int excess_count = ((index_watcher - plus_petit_genome_offset) >= plus_petit_genome.genetique.size() ? plus_grand_genome.genetique.size() : plus_petit_genome.genetique.size()) - index_watcher;
    
    if(number_of_matching_genes == 0){
      number_of_matching_genes = 1;
    }
    return 
      (factor_excess * excess_count / number_of_genes_in_larger_genome) + 
      (factor_disjoint * disjoint_count / number_of_genes_in_larger_genome) + 
      (factor_matching_genes * (weight_difference_of_matching_genes / number_of_matching_genes));
  }
  public void compute_adjusted_fitness(int denominateur){
    this.adjusted_fitness = this.fitness / (float)denominateur;
  }
  
  public float get_adjusted_fitness(){
    compute_adjusted_fitness(this.espece_parent.population_of_specie.size());
    return this.adjusted_fitness;
  }
  
  public organisme copuler(organisme amant){
    int index_watcher = 0;
    int plus_grand_genome_offset = 0;
    int plus_petit_genome_offset = 0;
    organisme plus_petit_genome = null;
    organisme plus_grand_genome = null;
    if(amant.genome.genetique.size() <  this.genome.genetique.size()){
      plus_petit_genome = amant;
      plus_grand_genome = this;
    }
    else{
      plus_grand_genome = amant;
      plus_petit_genome = this;
    }
    genome nouveau_genome = new genome(this.genome.nb_input_nodes, this.genome.nb_output_nodes, true);
    organisme excess_genome = null;
    boolean excess_genome_is_fittest = false;
    boolean excess_genome_is_petit = false;
    boolean plus_grand_genome_is_fittest = plus_grand_genome.fitness > plus_petit_genome.fitness;
    boolean plus_petit_genome_is_fittest = plus_grand_genome.fitness < plus_petit_genome.fitness;
    boolean egal_fitness = plus_grand_genome.fitness.equals(plus_petit_genome.fitness);
    if(egal_fitness){
      if(random(2) < 1){
        plus_grand_genome_is_fittest = true;
        plus_petit_genome_is_fittest = false;
      }
      else{
        plus_grand_genome_is_fittest = false;
        plus_petit_genome_is_fittest = true;
      }
    }
    int excess_genome_offset = 0;
    //CROSSOVER
    while((index_watcher - plus_petit_genome_offset) < plus_petit_genome.genome.genetique.size() || (index_watcher - plus_grand_genome_offset) < plus_grand_genome.genome.genetique.size()){
      
      if(excess_genome == null){
        boolean draw_petit = false;
        boolean draw_grand = false;
        innovable plus_petit_genome_innovable = plus_petit_genome.genome.genetique.get(index_watcher - plus_petit_genome_offset);
        innovable plus_grand_genome_innovable = plus_grand_genome.genome.genetique.get(index_watcher - plus_grand_genome_offset);
        
        int plus_petit_genome_innovation = plus_petit_genome_innovable.innovation;
        int plus_grand_genome_innovation = plus_grand_genome_innovable.innovation;
        if(plus_petit_genome_innovation > plus_grand_genome_innovation){
          if(plus_grand_genome_is_fittest){
            nouveau_genome.add_gene(plus_grand_genome_innovable.clone());
          }
          draw_grand = true;
          plus_petit_genome_offset++;
        }
        else if(plus_grand_genome_innovation > plus_petit_genome_innovation){
          if(plus_petit_genome_is_fittest){
            nouveau_genome.add_gene(plus_petit_genome_innovable.clone());
          }
          draw_petit = true;
          plus_grand_genome_offset++;
        }
        else{
          draw_grand = true;
          draw_petit = true;
          if(plus_petit_genome_innovable instanceof gene && plus_grand_genome_innovable instanceof gene){
            gene plus_petit_genome_gene = (gene)plus_petit_genome_innovable;
            gene plus_grand_genome_gene = (gene)plus_grand_genome_innovable;
            gene nouveau_gene = random(2) < 1 ? plus_petit_genome_gene.clone() : plus_grand_genome_gene.clone();
            if(nouveau_gene.enabled && (!plus_grand_genome_gene.enabled || !plus_petit_genome_gene.enabled) && random(1) < disabled_if_any_chance){
              nouveau_gene.enabled = false;
            }
            if(!nouveau_gene.enabled && (plus_grand_genome_gene.enabled || plus_petit_genome_gene.enabled) && random(1) < enabled_if_any_chance){
              nouveau_gene.enabled = true;
            }
            nouveau_genome.add_gene(nouveau_gene);
          }
          else{
            node plus_petit_genome_node = (node)plus_petit_genome_innovable;
            node plus_grand_genome_node = (node)plus_grand_genome_innovable;
            node nouvelle_node = random(2) < 1 ? plus_petit_genome_node.clone() : plus_grand_genome_node.clone();
            nouveau_genome.add_gene(nouvelle_node);
          }
        }
        
        if(draw_petit){
          if(plus_petit_genome_innovable instanceof node){
            node i_as_node = (node)plus_petit_genome_innovable;
            i_as_node.draw(index_watcher * i_as_node.draw_width, innovation.test * (i_as_node.draw_height * 3 + 5));
          }
          else{
            gene i_as_gene = (gene)plus_petit_genome_innovable;
            i_as_gene.draw(index_watcher * i_as_gene.draw_width, innovation.test * (i_as_gene.draw_height * 3 + 5));
          }
        }
        if(draw_grand){
          if(plus_grand_genome_innovable instanceof node){
            node i_as_node = (node)plus_grand_genome_innovable;
            i_as_node.draw(index_watcher * i_as_node.draw_width, innovation.test * (i_as_node.draw_height * 3 + 5) + 50);
          }
          else{
            gene i_as_gene = (gene)plus_grand_genome_innovable;
            i_as_gene.draw(index_watcher * i_as_gene.draw_width, innovation.test * (i_as_gene.draw_height * 3 + 5) + 50);
          }
        }
        
        boolean fin_du_plus_grand_genome = (index_watcher - plus_grand_genome_offset) == (plus_grand_genome.genome.genetique.size() - 1);
        boolean fin_du_plus_petit_genome = (index_watcher - plus_petit_genome_offset) == (plus_petit_genome.genome.genetique.size() - 1);
        
        if(fin_du_plus_grand_genome){
          excess_genome = plus_petit_genome;
          excess_genome_is_petit = true;
          excess_genome_is_fittest = !plus_grand_genome_is_fittest;
          excess_genome_offset = plus_petit_genome_offset;
        }
        else if(fin_du_plus_petit_genome){
          excess_genome = plus_grand_genome;
          excess_genome_is_petit = false;
          excess_genome_is_fittest = !plus_petit_genome_is_fittest;
          excess_genome_offset = plus_grand_genome_offset;
        }
        
      }
      else if(excess_genome_is_fittest){
        innovable excess_genome_innovable = excess_genome.genome.genetique.get(index_watcher - excess_genome_offset);
        nouveau_genome.add_gene(excess_genome_innovable.clone());
        if(excess_genome_is_petit){
          if(excess_genome_innovable instanceof node){
            node i_as_node = (node)excess_genome_innovable;
            i_as_node.draw(index_watcher * i_as_node.draw_width, innovation.test * (i_as_node.draw_height * 3 + 5));
          }
          else{
            gene i_as_gene = (gene)excess_genome_innovable;
            i_as_gene.draw(index_watcher * i_as_gene.draw_width, innovation.test * (i_as_gene.draw_height * 3 + 5));
          }
          plus_grand_genome_offset++;
        }
        else{
          if(excess_genome_innovable instanceof node){
            node i_as_node = (node)excess_genome_innovable;
            i_as_node.draw(index_watcher * i_as_node.draw_width, innovation.test * (i_as_node.draw_height * 3 + 5) + 50);
          }
          else{
            gene i_as_gene = (gene)excess_genome_innovable;
            i_as_gene.draw(index_watcher * i_as_gene.draw_width, innovation.test * (i_as_gene.draw_height * 3 + 5) + 50);
          }
          plus_petit_genome_offset++;
        }
      }
      else{
        break;
      }
      
      index_watcher++;
    }
    if(plus_petit_genome_is_fittest){
      //text("F", index_watcher * 30, innovation.test * 155);
    }
    else if(plus_grand_genome_is_fittest){
      //text("F", index_watcher * 30, innovation.test * 155 + 50);
    }
    else{
      //text("=", index_watcher * 30, innovation.test * 155 + 50);
    }
    index_watcher = 0;
    //MUTATION POIDS
    while(index_watcher < nouveau_genome.genetique.size()){
      innovable gene_a_muter = nouveau_genome.genetique.get(index_watcher);
      if(gene_a_muter instanceof node){
        node i_as_node = (node)gene_a_muter;
        i_as_node.draw(index_watcher * i_as_node.draw_width, innovation.test * (i_as_node.draw_height * 3 + 5) + 100);
      }
      else{
        gene i_as_gene = (gene)gene_a_muter;
        i_as_gene.draw(index_watcher * i_as_gene.draw_width, innovation.test * (i_as_gene.draw_height * 3 + 5) + 100);
      }
      if(random(1) < weight_mutation_chance && gene_a_muter instanceof gene){
        ((gene)gene_a_muter).weight = random(-2, 2);
      }
      index_watcher++;
    }
    //MUTATION STRUCTURELLE - AJOUT D'UN LIEN
    //TODO: Eventuellement, changer la méthode de recherche de nodes pour l'ajout de connection.
    //une idée: créer une liste de nodes connectables par la première node et déterminer la prochaine depuis cette liste (si elle en vaut la peine, c'est-à-dire s'il y a au moins une node pouvant s'y rattacher)
    //peut-être faire un suivi du nombre de connections possibles afin de ne pas essayer pour rien?
    if(random(1) < add_connection_mutation_chance){
      int[] index_des_nodes_a_connecter = new int[2];
      int essais_while = 0;
      boolean probleme = false;
      
      essais_while = 0;
      node node_0 = null;
      do  {
        index_des_nodes_a_connecter[0] = (int)random(nouveau_genome.nodes.size());
        essais_while++;
        node_0 = nouveau_genome.nodes.get(index_des_nodes_a_connecter[0]);
      } while (
        // We do not want to propagate from an output node
        node_0.node_type == 2
      );
      
      essais_while = 0;
      node node_1 = null;
      do{
        index_des_nodes_a_connecter[1] = (int)random(nouveau_genome.nodes.size());
        essais_while++;
        node_1 = nouveau_genome.nodes.get(index_des_nodes_a_connecter[1]);
      }while(
        (
          !isValidLink(node_0, node_1) || 
          nouveau_genome.check_if_nodes_already_connected(node_0.index, node_1.index) 
        ) && essais_while < 100);
      if(essais_while == 100){
        //Pas de nodes non connectés
        probleme = true;
      }
      if(!probleme){
        node premiere_node_a_connecter = node_0;
        node seconde_node_a_connecter = node_1;
        gene nouvelle_connexion = new gene(premiere_node_a_connecter.index, seconde_node_a_connecter.index, random(-2, 2), true);
        
        //on vérifie si cette combinaison de node-in et node-out a déjà été faite auparavant
        int innovation_number = innovation.trouver_gene(premiere_node_a_connecter.index, seconde_node_a_connecter.index);
        
        if(innovation_number == -1){
          innovation_number = innovation.next();
          innovation.innovations_of_current_generation.add(nouvelle_connexion);
        }
        nouvelle_connexion.innovation = innovation_number;
        nouveau_genome.add_gene(nouvelle_connexion);
      }
      
    }
    //MUTATION STRUCTURELLE - AJOUT D'UNE NODE
    //TODO: Une des deux mutations possible à la fois?
    else if(nouveau_genome.au_moins_une_connexion && random(1) < add_node_mutation_chance){
      gene gene_a_scinder = null;
      boolean probleme = false;
      int essais_while = 0;
      do{
        int index_du_gene_a_scinder = (int)random(nouveau_genome.connexions.size());
        gene_a_scinder = nouveau_genome.connexions.get(index_du_gene_a_scinder);
        essais_while++;
      }while(!gene_a_scinder.enabled && essais_while < 100);
      if(essais_while == 100){
        probleme = true;
      }
      if(!probleme){
        gene_a_scinder.enabled = false;
        node nouvelle_node = new node(3, nouveau_genome.index_derniere_node_ajoute + 1); //1 = input, 2 = output, 3 = hidden
        int innovation_number_node = innovation.trouver_node(nouvelle_node.index);
        if(innovation_number_node == -1){
          innovation_number_node = innovation.next();
          innovation.innovations_of_current_generation.add(nouvelle_node);
        }
        nouvelle_node.innovation = innovation_number_node;
        nouveau_genome.add_gene(nouvelle_node);
        
        gene nouvelle_connexion_ancien_a_nouveau = new gene(gene_a_scinder.input_node_index, nouvelle_node.index, 1, true);
        int innovation_number_gene_ancien_a_nouveau = innovation.trouver_gene(nouvelle_connexion_ancien_a_nouveau.input_node_index, nouvelle_connexion_ancien_a_nouveau.output_node_index);
        if(innovation_number_gene_ancien_a_nouveau == -1){
          innovation_number_gene_ancien_a_nouveau = innovation.next();
          innovation.innovations_of_current_generation.add(nouvelle_connexion_ancien_a_nouveau);
        }
        nouvelle_connexion_ancien_a_nouveau.innovation = innovation_number_gene_ancien_a_nouveau;
        nouveau_genome.add_gene(nouvelle_connexion_ancien_a_nouveau);
        
        
        gene nouvelle_connexion_nouveau_a_ancien = new gene(nouvelle_node.index, gene_a_scinder.output_node_index, gene_a_scinder.weight, true);
        int innovation_number_gene_nouveau_a_ancien = innovation.trouver_gene(nouvelle_connexion_nouveau_a_ancien.input_node_index, nouvelle_connexion_nouveau_a_ancien.output_node_index);
        if(innovation_number_gene_nouveau_a_ancien == -1){
          innovation_number_gene_nouveau_a_ancien = innovation.next();
          innovation.innovations_of_current_generation.add(nouvelle_connexion_nouveau_a_ancien);
        }
        nouvelle_connexion_nouveau_a_ancien.innovation = innovation_number_gene_nouveau_a_ancien;
        nouveau_genome.add_gene(nouvelle_connexion_nouveau_a_ancien);
      }
      
    }
    innovation.test++;
    return new organisme(nouveau_genome);
  }
  
  private Boolean isValidLink(node node_0, node node_1)
  {
    if (node_0.node_type == 3 && node_1.node_type == 3) {
      //CAS: La node input est H et la node output est H, regarder si l'index de l'output est plus grande que celle de l'input
      return node_1.index > node_0.index;
    }
    if (node_0.node_type == 1 && node_1.node_type == 1) {
      return false;
    }
    return true;
  }
  
  public void draw(int x, int y){
    int x_offset = 0;
    for(innovable i : this.genome.genetique){
      if(i instanceof gene){
        gene i_as_gene = (gene)i;
        i_as_gene.draw(x + x_offset, y);
      }
      else{
        node i_as_node = (node)i;
        i_as_node.draw(x + x_offset, y);
      }
      x_offset += 40;
    }
  }
  
}
