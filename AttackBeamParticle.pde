class AttackBeamParticle {
    float angle;
    float radius;
    float x, y;
    int size;
    color c;

    AttackBeamParticle(float angle, float radius, int size, color c) {
        this.angle = angle;
        this.radius = radius;
        this.size = size;
        this.c = c;
    }

    void update(float centerX, float centerY) {
        x = centerX + cos(angle) * radius;
        y = centerY + sin(angle) * radius;

        angle += 0.05;
    }

    void display() {
        fill(c);
        ellipse(x, y, size, size);
    }
}
