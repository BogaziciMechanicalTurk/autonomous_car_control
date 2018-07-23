const int stepPin = 5; 
const int dirPin = 2; 
const int enPin = 8;
//const int potPin='A2';
int potValPrev=0;

const int tol = 30;

void setup() {
  
  // Sets the two pins as Outputs
  pinMode(stepPin,OUTPUT); 
  pinMode(dirPin,OUTPUT);
  pinMode(enPin,OUTPUT);
  digitalWrite(enPin,LOW);
  
}
void loop() {
  
  int potVal = analogRead(A2);
  
  int turn = 1;
  
  
  if(potVal>  127 + tol){
    digitalWrite(dirPin,HIGH);
  }
  else if(potVal<  127 - tol){
    digitalWrite(dirPin,LOW);
  }
  else{
    turn = 0;
  }
  
  if(turn){
    digitalWrite(stepPin,HIGH); 
    delayMicroseconds(500); 
    digitalWrite(stepPin,LOW); 
    delayMicroseconds(500); 
  } 
   delayMicroseconds(4000);  
    
  
  
  //delay(100);
  potValPrev=potVal;
  
}
