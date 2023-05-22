#define BUTTONS ((volatile long *) 0xFF200050)
#define SWITCHES ((volatile long *) 0xFF200040)
#define LED ((volatile long *) 0xFF200000)
#define VGA ((volatile short *) 0x08000000)
#define WIDTH 512
	
int main() {
 clear();
 line(100,100,120,120);
 line(120,120,160,120);
 line(160,120,180,100);
 line(130,80,130,60);
 line(150,80,150,60);
	
 return 0;
}

void line(int x0, int y0, int x1, int y1) {
    int dx = abs(x1 - x0);
    int sx = (x0 < x1) ? 1 : -1;
    int dy = -abs(y1 - y0);
    int sy = (y0 < y1) ? 1 : -1;
    int error = dx + dy;
    
    while (1) {
        plot(x0, y0);
        if (x0 == x1 && y0 == y1) break;
        int e2 = 2*error;
        if (e2 >= dy) {
            if (x0 == x1) break;
            error = error + dy;
            x0 += sx;
		}
        if (e2 <= dx) {
            if (y0 == y1) break;
            error += dx;
            y0 += sy;
		}
	}
}

void plot(int x, int y) {
	VGA[y*WIDTH+x] = 0xFF00;
}

void clear() {
	for (int i = 0; i < (1<<17); i++) {
		VGA[i] = 0x00FF;
	}
}