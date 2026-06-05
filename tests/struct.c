typedef struct Point {
    int x;
    int y;
} Point;

int dot(Point a, Point b) {
    return a.x * b.x + a.y * b.y;
}

int classify(int v) {
    switch (v) {
        case 0: return 0;
        case 1: return 1;
        default: return -1;
    }
}

int main() {
    Point p;
    Point q;
    p.x = 3;
    p.y = 4;
    q.x = 1;
    q.y = 2;
    return classify(dot(p, q));
}
