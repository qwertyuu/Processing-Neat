//s'occupe de passer d'une génération à une autre
//doit différencier les espèces basé sur le compatibility_treshold
//doit effectuer les mutations et les tirs au sort
//forganismet le suivi des innovations (nouvelles gènes) de la nouvelle génération
class generation_manager{
  
  int organismes_par_generation = 30;
  
  ArrayList<organisme> population;
  ArrayList<specie> especes;
  int compatibility_treshold = 2;
  
  public generation_manager(ArrayList<organisme> population){
    this.population = population;
    this.especes = new ArrayList<specie>();
    innovation.innovations_of_current_generation = new ArrayList<innovable>();
  }
  public generation_manager(int population_size, int nb_input_nodes, int nb_output_nodes){
    this.population = new ArrayList<organisme>();
    this.especes = new ArrayList<specie>();
    this.organismes_par_generation = population_size;
    innovation.innovations_of_current_generation = new ArrayList<innovable>();
    for(int i = 0; i < population_size; i++){
      organisme nouveau_ne = new organisme(nb_input_nodes, nb_output_nodes);
      boolean ajoute_a_une_espece = false;
      for(specie espece_existante : this.especes){
        ajoute_a_une_espece |= espece_existante.welcome(nouveau_ne, compatibility_treshold);
        if(ajoute_a_une_espece){
          break;
        }
      }
      if(!ajoute_a_une_espece){
        especes.add(new specie(nouveau_ne));
      }
      population.add(nouveau_ne);
    }
  }
  public void compute_new_generation(){
    innovation.test = 0;
    //assume que les fitness sont setté
    //normalise le fitness basé sur la fonction d'ajustement du fitness proposé par le papier
    for(organisme individu : population){
      individu.compute_adjusted_fitness(individu.espece_parent.population_of_specie.size());
    }
    
    innovation.innovations_of_current_generation = new ArrayList<innovable>();
    ArrayList<organisme> nouvelle_generation = new ArrayList<organisme>();
    ArrayList<organisme> copie_de_population;
    Collections.sort(population);
    organisme koth = null;
    for(int i = 0; i < population.size(); i++){
      organisme opponent = population.get(i);
      if(koth == null || koth.fitness < population.get(i).fitness) {
        koth = opponent;
      }
    }
    nouvelle_generation.add(koth);
    while(nouvelle_generation.size() < this.organismes_par_generation){
      copie_de_population = new ArrayList(population);
      organisme[] parents = new organisme[2];
      for(int i = 0; i < parents.length; i++){
        int pop_size = copie_de_population.size();
        int index_choix = (int)(pow(random(1), 1.06) * pop_size);
        organisme parent_choisi = copie_de_population.get(index_choix);
        parents[i] = parent_choisi;
        copie_de_population.remove(index_choix);
      }
      organisme nouveau_ne = parents[0].copuler(parents[1]);
      boolean ajoute_a_une_espece = false;
      for(specie espece_existante : this.especes){
        ajoute_a_une_espece |= espece_existante.welcome(nouveau_ne, compatibility_treshold);
        if(ajoute_a_une_espece){
          break;
        }
      }
      if(!ajoute_a_une_espece){
        especes.add(new specie(nouveau_ne));
      }
      nouvelle_generation.add(nouveau_ne);
    }
    for(specie espece: this.especes){
      espece.set_representative_and_reset();
    }
    this.population = nouvelle_generation;
  }
}