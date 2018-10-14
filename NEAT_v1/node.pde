class node extends innovable{
 public int node_type; //1 = input, 2 = output, 3 = hidden
 public int index;
 public float value;
 public boolean has_triggered;
 public boolean temporary_mark;
 public int x;
 public int y;
 
 public node(int type, int index){
   this.node_type = type;
   this.index = index;
   this.value = 0;
   this.has_triggered = false;
   this.temporary_mark = false;
   this.draw_width = 30;
   this.draw_height = 50;
   this.x = -1;
   this.y = -1;
 }
 
  @Override
  public node clone()  {
    node toClone = new node(node_type, index);
    toClone.innovation = this.innovation;
    toClone.has_triggered = this.has_triggered;
    toClone.temporary_mark = this.temporary_mark;
    toClone.value = this.value;
    return toClone;
  }
  
  public void draw(int x, int y){
    if(true) return;
    fill(255);
    rect(x, y, this.draw_width, this.draw_height);
    fill(0, 102, 153);
    String s = this.innovation + "\n";
    String lettre = "";
    if(node_type == 1){
      lettre = "I";
    }
    else if(node_type == 2){
      lettre = "O";
    }
    else{
      lettre = "H";
    }
    s += lettre + ":" + this.index;
    text(s, x + 2, y + 2, this.draw_width, this.draw_height);
  }
  
  public void draw_phenotype(){
    strokeWeight(1);
    stroke(0);
    fill(255);
    ellipse(this.x, this.y, 50, 50);
    String lettre = "";
    if(node_type == 1){
      lettre = "I";
    }
    else if(node_type == 2){
      lettre = "O";
    }
    else{
      lettre = "H";
    }
    fill(0, 102, 153);
    text(lettre + this.index, this.x - 10, this.y - 10, 20, 20);
  }
  
}
