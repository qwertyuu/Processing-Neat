class tictactoe {
  public int[][] board;
  private int size = 3;
  int moveCount;
  int whoWon;
  public tictactoe() {
    this.board = new int[3][3];
    moveCount = 0;
    whoWon = 0;
  }
  
  public boolean play(int player, int col, int row)
  {
    if (this.board[col][row] != 0) {
      return false;
    }
    this.board[col][row] = player;
    for(int i = 0; i < size; i++){
        if(board[col][i] != player)
            break;
        if(i == size-1){
          whoWon = player;
          return true;
        }
    }
    for(int i = 0; i < size; i++){
        if(board[i][row] != player)
            break;
        if(i == size-1){
          whoWon = player;
          return true;
        }
    }
    
    //check diag
    if(col == row){
        //we're on a diagonal
        for(int i = 0; i < size; i++){
            if(board[i][i] != player)
                break;
            if(i == size-1){
              whoWon = player;
              return true;
            }
        }
    }

    //check anti diag (thanks rampion)
    if(col + row == size - 1){
        for(int i = 0; i < size; i++){
            if(board[i][(size-1)-i] != player)
                break;
            if(i == size-1){
                //report win for s
            }
        }
    }

    //check draw
    if(moveCount == (Math.pow(size, 2) - 1)){
        whoWon = 2;
    }
    return true;
  }
  
  public boolean checkWin(){
    return whoWon != 0;
  }
  
  public void mouseClicked() {
  }
  
  public void draw() {
    stroke(0);
    line(200, 0, 200, 599);
    line(400, 0, 400, 599);
    line(0, 200, 599, 200);
    line(0, 400, 599, 400);

    
    for(int col = 0; col < this.board.length; col++) {
      for (int row = 0; row < this.board[col].length; row++) {
        int x = col * 200 + 100;
        int y = row * 200 + 100;
        if (this.board[col][row] == -1) {
          rect(x-25, y-25, 50, 50);
        } else if (this.board[col][row] == 1) {
          ellipse(x, y, 50, 50);
        }
      }
    }

  }
}
