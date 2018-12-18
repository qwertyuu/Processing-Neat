import java.util.Collections;
import java.util.LinkedList;
import java.util.Queue;
import java.io.FileReader;
import java.util.List;
import java.util.UUID;
evolution_manager em;
void setup(){
  //size(800, 1000);
  fullScreen(1);
  frameRate(60);
  em = new evolution_manager();
  thread("tick");
  randomSeed(12);
}

void draw(){
  em.draw();
}

void tick() {
  while(true) {
    em.update();
  }
}

void keyPressed() {
  em.keyPressed();
}

void mouseClicked() {
  em.mouseClicked();
}
