class specie{
  public organisme representative;
  public ArrayList<organisme> population_of_specie;
  public specie(organisme representative){
    population_of_specie = new ArrayList<organisme>();
    set_representative(representative);
    population_of_specie.add(representative);
    representative.espece_parent = this;
  }
  
  public boolean in_specie(organisme toCheck){
    return population_of_specie.contains(toCheck);
  }
  
  public void set_representative(organisme representative){
    this.representative = representative;
  }
  public void set_representative_and_reset(){
    this.representative = population_of_specie.get((int)random(population_of_specie.size()));
    population_of_specie = new ArrayList<organisme>();
    population_of_specie.add(this.representative);
  }
  
  public boolean welcome(organisme toAdd, int compatibility_treshold){
    float compat_dist = representative.compute_compatibility_distance(toAdd);
    if(compat_dist <= compatibility_treshold){
      population_of_specie.add(toAdd);
      toAdd.espece_parent = this;
      return true;
    }
    return false;
  }
  
}