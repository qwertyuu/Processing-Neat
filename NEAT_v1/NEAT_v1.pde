import java.util.Collections;
import java.util.LinkedList;
import java.util.Queue;
import java.io.FileReader;
import java.util.List;
evolution_manager em;
void setup(){
  //size(800, 1000);
  fullScreen(1);
  frameRate(100);
  em = new evolution_manager();
  randomSeed(12);
}

void draw(){
  em.update();
}
