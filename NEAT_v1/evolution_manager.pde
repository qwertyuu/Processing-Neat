//s'occupe de l'évolution globale( du début jusqu'à la fin de l'apprentissage),
//du suivi de fitness
//va etre le pont entre l'app et le AI
class evolution_manager{
  public generation_manager generation_manager;
  public tictactoe ttt;
  public int userCol = -1;
  public int userRow = -1;
  public evolution_manager(){
    this.generation_manager = new generation_manager(3000, 10, 9);
  }
  float[][] input;
  int[][] output;
  float ever_best = 0;
  organisme bff = null;
  organisme current = null;
  public void update(){
    ArrayList<organisme> corruptOrganisms = new ArrayList<organisme>();
    for(organisme ami : this.generation_manager.population){
      //exporter le neural net
      current = ami;
      ami.compute_phenotype(false);
      ami.fitness = 0f;
      int gamescount = 0;
      //evaluer le neural net. Trouver une façon de tracker une node précise? IID? Index?
      // jouer au tic tac toe. Laisser la personne commencer toujours
      ttt = new tictactoe();
      boolean playerIsOpponent = true;
      boolean somethingBadHappened = false;
      do
      {
        if (playerIsOpponent) {
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
          float[] amiInputs = new float[10];
          int amiInputsIndex = 0;
          for(int col = 0; col < ttt.board.length; col++) {
            for (int row = 0; row < ttt.board[col].length; row++) {
              amiInputs[amiInputsIndex++] = ttt.board[col][row];
            }
          }
          amiInputs[9] = 1; // bias
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
        }

        if(ttt.whoWon == 2) { // tie 
          ami.fitness += 1f;
          gamescount++;
          //println("current tied! starting new game! "  + gamescount);
          ttt = new tictactoe();
          playerIsOpponent = (int)random(0, 2) == 0;
          somethingBadHappened = false;
        } else if(ttt.whoWon == -1) {
          ami.fitness = 0f;
        } else if (ttt.whoWon == 1) {
          ami.fitness += 5f;
        }
        playerIsOpponent = !playerIsOpponent;
      } while (!ttt.checkWin() && gamescount < 1000);

      if (somethingBadHappened) {
        ami.fitness = 0f;
      }
      current = null;

      if(bff == null || ami.fitness > ever_best){
        bff = ami;
        ever_best = ami.fitness;
        println(round(ever_best));
      }
    }
    if(corruptOrganisms.size() > 0) {
      println("Removed " + corruptOrganisms.size() + " corrupt organisms");
      this.generation_manager.population.remove(corruptOrganisms);
    }
    generation_manager.compute_new_generation();
  }

  void draw() {
    background(255);
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
    organisme_export(bff, "TTT-" + round(ever_best) + "-" + uniqueID + ".json");
    println("DONE !");
    println("--- ");
  }
}
