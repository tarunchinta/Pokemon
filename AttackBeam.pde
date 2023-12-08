class AttackBeam {
    int startTime;
    float xPos, yPos; // Position of the attack beam
    boolean isFinished = false; // Flag to track whether the attack is finished
    ArrayList<AttackBeamParticle> particles = new ArrayList<AttackBeamParticle>();
    color c;

    AttackBeam(float x, float y, color c) {
        startTime = millis();
        xPos = x;
        yPos = y;
        this.c = c;

        for (int i = 0; i < 360; i += 36) { // 36 degrees apart
            particles.add(new AttackBeamParticle(radians(i), 75, 15, c)); // 30 pixels radius, 5 pixels size
        }
        
  }

    float angle = PI / 8; // Initial angle (45 degrees)

    void updateAttack() {
        float speed = 10.0;

        float elapsed = (millis() - startTime) / 1000.0;

        xPos += speed * elapsed * cos(angle);
        yPos -= speed * elapsed * sin(angle);

        // Check if the attack has reached the desired position
        if (xPos >= 750 && yPos <= 250) {
            isFinished = true;
        }
        
        for (AttackBeamParticle particle : particles) {
            particle.update(xPos, yPos);
        }
    }

    void displayAttack() {
        if (!isFinished) {
            fill(c);
            circle(xPos, yPos, 50);
              
            for (AttackBeamParticle particle : particles) {
                particle.display();
            }
        }
    }
}
