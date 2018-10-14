static class innovation{
  private static int number = 1;
  private static int test = 1;
  public static ArrayList<innovable> innovations_of_current_generation = new ArrayList<innovable>();
  public static int get() {
     return number;
  }
  public static void increment(){
    number++;
  }
  public static int next(){
    return ++number;
  }
  public static int trouver_gene(int input_node_index, int output_node_index){
    for(innovable innovation : innovations_of_current_generation){
      if(innovation instanceof gene){
        gene innovation_gene = (gene)innovation;
        if(innovation_gene.input_node_index == input_node_index && innovation_gene.output_node_index == output_node_index){
          //si oui, on veut son # d'innovation
          return innovation.innovation;
        }
      }
    }
    return -1;
  }
  public static int trouver_node(int node_index){
    for(innovable innovation : innovations_of_current_generation){
      if(innovation instanceof node){
        node innovation_node = (node)innovation;
        if(innovation_node.index == node_index){
          //si oui, on veut son # d'innovation
          return innovation.innovation;
        }
      }
    }
    return -1;
  }
}