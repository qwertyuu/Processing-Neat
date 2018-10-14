class gene extends innovable{
  public node input_node_object;
  public node output_node_object;
  public float weight;
  public boolean enabled;
  public gene(node input_node, node output_node, float weight, boolean enable){
    this.input_node_object = input_node;
    this.output_node_object = output_node;
    this.weight = weight;
    this.enabled = enable;
  }
  
  @Override
  public gene clone()  {
    gene toClone = new gene(input_node_object, output_node_object, weight, enabled);
    toClone.innovation = this.innovation;
    return toClone;
  }
  
  public void draw(int x, int y){
    
    if(true) return;
    fill(this.enabled ? 255 : 190);
    rect(x, y, this.draw_width, this.draw_height);
    fill(0, 102, 153);
    String s = this.innovation + "\n";
    s += this.input_node_object.innovation + ">" + this.output_node_object.innovation;
    text(s, x + 2, y + 2, this.draw_width, this.draw_height); 
  }
  
  public void print(){
    node input_node = this.input_node_object;
    node output_node = this.output_node_object;
    String lettre_input = "";
    if(input_node.node_type == 1){
      lettre_input = "I";
    }
    else if(input_node.node_type == 2){
      lettre_input = "O";
    }
    else{
      lettre_input = "H";
    }
    String lettre_output = "";
    if(output_node.node_type == 1){
      lettre_output = "I";
    }
    else if(output_node.node_type == 2){
      lettre_output = "O";
    }
    else{
      lettre_output = "H";
    }
    println(lettre_input + input_node.index + " -> " + lettre_output + output_node.index);
  }
  
  public void draw_phenotype_connection(int x1, int y1, int x2, int y2){
    color vert = color(0, 255, 0);
    color rouge = color(255, 0, 0);
    strokeWeight(abs(this.weight));
    stroke(this.weight > 0 ? vert : rouge);
    line(x1, y1, x2, y2);
  }
  
  public void draw_phenotype_label(int x1, int y1, int x2, int y2){
    stroke(0);
    fill(0);
    float weightLabelX = lerp(x1, x2, 0.9);
    float weightLabelY = lerp(y1, y2, 0.9);
    rect(weightLabelX-10, weightLabelY-10, 50, 15);
    fill(255);
    text(this.weight, weightLabelX, weightLabelY);
  }
  
}
