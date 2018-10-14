//s'occupe de l'évolution globale( du début jusqu'à la fin de l'apprentissage),
//du suivi de fitness
//va etre le pont entre l'app et le AI
class evolution_manager{
  public generation_manager generation_manager;
  public evolution_manager(){
    this.generation_manager = new generation_manager(2000, 4, 4);
    FileReader fr = null;
    try{
      fr = new FileReader("C:\\Users\\cotla\\Downloads\\VA.csv");
    }
    catch(IOException e){
      println(e.getMessage());
    }
    
    CSVReader reader = new CSVReader(fr);
    List<String[]> mesIris = new ArrayList<String[]>();
    try{
      mesIris = reader.readAll();
      reader.close();
      if(fr != null){
        fr.close();
      }
      
    }
    catch(IOException e){
      
    }
    input = new float[mesIris.size()][];
    output = new int[mesIris.size()][];
    int index_data = 0;
    for(String[] irisInfo : mesIris){
      input[index_data] = new float[]{
        Float.parseFloat(irisInfo[0]),
        Float.parseFloat(irisInfo[1]),
        Float.parseFloat(irisInfo[2]),
        1
      };
      //println(input[index_data]);
      switch(irisInfo[3]){
        case "0":
          output[index_data] = new int[]{1, 0, 0, 0};
          break;
        case "0.3333333333":
          output[index_data] = new int[]{0, 1, 0, 0};
          break;
        case "0.6666666667":
          output[index_data] = new int[]{0, 0, 1, 0};
          break;
        case "1":
          output[index_data] = new int[]{0, 0, 0, 1};
          break;
      }
      index_data++;
    }
  }
  float[][] input;
  int[][] output;
  float ever_best = 0;
  organisme bff = null;
  public void update(){
    
    float highest_fitness = 0;
    organisme meilleur_ami = null;
    ArrayList<organisme> corruptOrganisms = new ArrayList<organisme>();
    for(organisme ami : this.generation_manager.population){
      //exporter le neural net
      ami.compute_phenotype(false);
      ami.fitness = 0f;
      //evaluer le neural net. Trouver une façon de tracker une node précise? IID? Index?
      for(int truth_line_index = 0; truth_line_index < input.length; truth_line_index++){
        int input_node_index = 0;
        for(node input_node : ami.inputs){
          input_node.value = input[truth_line_index][input_node_index];
          input_node_index++;
        }
        try {
          ami.propagate(false);
        } catch(RuntimeException x) {
          corruptOrganisms.add(ami);
          continue;
        }
        int highest_index = 0;
        double highest_sigmoid = 0;
        for(int i = 0; i < ami.outputs.size(); i++){
          double current_sigmoid = sigmoid(ami.outputs.get(i).value);
          if (current_sigmoid > highest_sigmoid){
            highest_index = i;
            highest_sigmoid = current_sigmoid;
          }
          //println("raw:" + ami.outputs.get(0).value + " on a: " + (sigmoid(ami.outputs.get(i).value) > 0.5 ? 1 : 0) + " et on veut: " + output[truth_line_index][i]);
        }
        if(output[truth_line_index][highest_index] == 1){
          ami.fitness+=1;
        }
        //println("raw:" + ami.outputs.get(0).value + " on a: " + sigmoid(ami.get(0).value) + " et on veut: " + output[truth_line_index]);
      }
      if(ami.fitness > highest_fitness){
        highest_fitness = ami.fitness;
        meilleur_ami = ami;
        meilleur_ami.phenotype = null;
        meilleur_ami.compute_phenotype(false);
      }
    }
    if(corruptOrganisms.size() > 0) {
      println("Removed " + corruptOrganisms.size() + " corrupt organisms");
      this.generation_manager.population.remove(corruptOrganisms);
    }
    if(bff == null || meilleur_ami != null && bff.fitness < meilleur_ami.fitness) {
      bff = meilleur_ami;
      for(int truth_line_index = 0; truth_line_index < input.length; truth_line_index++){
        int input_node_index = 0;
        
        for(node input_node : bff.inputs){
          input_node.value = input[truth_line_index][input_node_index];
          print(input_node.value + " ");
          input_node_index++;
        }
        bff.propagate(false);
        int highest_index = 0;
        double highest_sigmoid = 0;
        for(int i = 0; i < bff.outputs.size(); i++){
          double current_sigmoid = sigmoid(bff.outputs.get(i).value);
          if (current_sigmoid > highest_sigmoid){
            highest_index = i;
            highest_sigmoid = current_sigmoid;
          }
        }
        int real_answer = 0;
        for(int i = 0; i < output[truth_line_index].length; i++){
          if (output[truth_line_index][i] == 1) {
            real_answer = i;
            break;
          }
        }
        println(highest_index + " " + real_answer);
      }
    }
    if(bff != null){
        background(255);
        bff.draw_phenotype();
    }
    //print(highest_fitness + " ");
    
    generation_manager.compute_new_generation();
    if(ever_best < highest_fitness){
      ever_best = highest_fitness;
      println( round(highest_fitness) + " " + round(ever_best));
    }
    
    if(round(highest_fitness) == 64 && meilleur_ami != null){
      background(255);
      meilleur_ami.phenotype = null;
      meilleur_ami.compute_phenotype(false);
      meilleur_ami.draw_phenotype();
      noLoop();
    }
  }
  
  double sigmoid(float x){
    double y = 0;
    if( x < -10 )
        y = 0;
    else if( x > 10 )
        y = 1;
    else
        y = 1.0 / (1.0 + Math.exp(-x));
    return y;
  }

  
}
