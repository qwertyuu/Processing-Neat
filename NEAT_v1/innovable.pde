class innovable implements Comparable<innovable>{
  public int innovation = -1;
  public int draw_width = 30;
  public int draw_height = 50;
  @Override
  public innovable clone()  {
    innovable toClone = new innovable();
    toClone.innovation = this.innovation;
    return toClone;
  }
  @Override
  public int compareTo(innovable autre) {
      return ((Integer)this.innovation).compareTo(autre.innovation);
  }
}