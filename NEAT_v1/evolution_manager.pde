//s'occupe de l'évolution globale( du début jusqu'à la fin de l'apprentissage),
//du suivi de fitness
//va etre le pont entre l'app et le AI
class evolution_manager{
  public generation_manager generation_manager;
  public tictactoe ttt;
  public int userCol = -1;
  public int userRow = -1;
  public evolution_manager(){
    this.generation_manager = new generation_manager(50, 9, 9);
  }
  float[][] input;
  int[][] output;
  float ever_best = 0;
  organisme bff = null;
  organisme current = null;
  public void update(){
    
    float highest_fitness = 0;
    ArrayList<organisme> corruptOrganisms = new ArrayList<organisme>();
    for(organisme ami : this.generation_manager.population){
      //exporter le neural net
      ami.compute_phenotype(false);
      ami.fitness = 0f;
      current = ami;
      //evaluer le neural net. Trouver une façon de tracker une node précise? IID? Index?
      // jouer au tic tac toe. Laisser la personne commencer toujours
      ttt = new tictactoe();
      boolean playerIsHuman = true;
      boolean somethingBadHappened = false;
      do
      {
        if (playerIsHuman) {
          ArrayList<Integer> emptySpots = new ArrayList<Integer>();
          for(int col = 0; col < ttt.board.length; col++) {
            for (int row = 0; row < ttt.board[col].length; row++) {
              if (ttt.board[col][row] == 0) {
                emptySpots.add(row * 3 + col);
              }
            }
          }
          int randomIndex = (int)random(0, emptySpots.size());
          userCol = emptySpots.get(randomIndex) % 3;
          userRow = emptySpots.get(randomIndex) / 3;
          ttt.play(-1, userCol, userRow);
          //delay(100);
        } else {
          // set ami inputs
          float[] amiInputs = new float[9];
          int amiInputsIndex = 0;
          for(int col = 0; col < ttt.board.length; col++) {
            for (int row = 0; row < ttt.board[col].length; row++) {
              amiInputs[amiInputsIndex++] = ttt.board[col][row];
            }
          }
          ami.setInputs(amiInputs);

          try {
            ami.propagate(false);
          } catch(RuntimeException x) {
            corruptOrganisms.add(ami);
            somethingBadHappened = true;
            break;
          }

          // get ami outputs
          int amiIndex = ami.getHighestValueIndex();
          int amiCol = amiIndex / 3;
          int amiRow = amiIndex % 3;
          if (!ttt.play(1, amiCol, amiRow)) {
            somethingBadHappened = true;
            break;
          }

          if(ttt.whoWon == 2) { // tie 
            ami.fitness = 50f;
          } else if (ttt.whoWon == 1) {
            ami.fitness = 100f;
          } else if (ttt.whoWon == -1) {
            ami.fitness = 10f;
          } else {
            ami.fitness++;
          }

        }
        playerIsHuman = !playerIsHuman;
      } while (!ttt.checkWin());

      if (somethingBadHappened) {
        //continue;
      }
      current = null;

      if(bff == null || ami.fitness > highest_fitness){
        bff = ami;
        highest_fitness = ami.fitness;
      }
    }
    if(corruptOrganisms.size() > 0) {
      println("Removed " + corruptOrganisms.size() + " corrupt organisms");
      this.generation_manager.population.remove(corruptOrganisms);
    }
    if(ever_best < highest_fitness){
      ever_best = highest_fitness;
      println(round(highest_fitness));
    }
    generation_manager.compute_new_generation();
  }

  void draw() {
    background(100);
    // check for user input here
    // also update draw
    if(bff != null){
        bff.draw_phenotype();
    }
    if(current != null){
      //current.draw_phenotype();
    }
    if (ttt != null) {
      ttt.draw();
    }
  }
  
  void keyPressed() {
    if (keyCode == 32) { // SPACE
      save_best();
    }
  }
  
  void mouseClicked() {
    ttt.mouseClicked();
    if (mouseX <= 600 && mouseY <= 600) {
      if (mouseX <= 200) {
        userCol = 0;
      } else if (mouseX <= 400) {
        userCol = 1;
      } else {
        userCol = 2;
      }

      if (mouseY <= 200) {
        userRow = 0;
      } else if (mouseY <= 400) {
        userRow = 1;
      } else {
        userRow = 2;
      }
    }
  }
  
  void save_best() {
    println("--- ");
    print("SAVING BEST TO DISK... ");
    String uniqueID = UUID.randomUUID().toString();
    organisme_export(bff, "VA-" + round(bff.fitness) + "-" + uniqueID + ".json");
    println("DONE !");
    println("--- ");
  }
}
