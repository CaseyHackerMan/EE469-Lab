#define BUTTONS ((volatile long *) 0xFF200050)
#define LED ((volatile long *) 0xFF200000)
	
int main() {
	
 while (1) {
  *LED = *BUTTONS;
 }
	
 return 0;
}
