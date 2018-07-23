/*
 * rosserial Publisher Example
 * Prints "hello world!"
 */

const int stepPin = 5; 
const int dirPin = 2; 
const int enPin = 8;
const int fwPin = 11;
//const int potPin='A2';
int potValPrev=0;

#include <ros.h>
#include <std_msgs/Int16.h>
#include <std_msgs/Float32.h>

#include "stdlib.h"

int pp0 = 0;  // analog pin used to connect the potentiometer
int pp1 = 1;  // analog pin used to connect the potentiometer
int pp2 = 2;  // analog pin used to connect the potentiometer

double a1 =       50.26;
double b1 =    0.001145;
double c1 =      -53.15;
double d1 =    -0.04186;

double a2 =   -7.83e-13;
double b2 =     0.03076;
double c2 =       116.3;
double d2 =   -0.001007;

double l_max = 157;

int val;    // variable to read the value from the analog pin
double d_val;
double result;

ros::NodeHandle  nh;

int turn = 0;
int forward = 0;

void messageCb( const std_msgs::Int16& keyboard_msg){
  turn = keyboard_msg.data;
}

void messageCb1( const std_msgs::Int16& keyboard_msg){
  forward = keyboard_msg.data;
}

ros::Subscriber<std_msgs::Int16> sub("turn", &messageCb);
ros::Subscriber<std_msgs::Int16> sub1("forward", &messageCb1);

std_msgs::Float32 steer_msg;
ros::Publisher steerPub("steer_fb", &steer_msg);

void setup()
{
  nh.initNode();
  nh.subscribe(sub);
  nh.subscribe(sub1);
  nh.advertise(steerPub);

  pinMode(stepPin,OUTPUT); 
  pinMode(dirPin,OUTPUT);
  pinMode(enPin,OUTPUT);
  pinMode(fwPin, OUTPUT);
  digitalWrite(enPin,LOW);
}

void loop()
{

  //int potVal = analogRead(A2);

  if(forward == 1){
      analogWrite(LED_BUILTIN,1.5*255/5);
      analogWrite(fwPin,1.9*255/5);
  }
  else{
      analogWrite(LED_BUILTIN,0.5*255/5);
      analogWrite(fwPin,0.5*255/5);   
  }
  

  if(turn == 2){
      digitalWrite(dirPin,HIGH);
      digitalWrite(stepPin,HIGH); 
      delayMicroseconds(500); 
      digitalWrite(stepPin,LOW); 
      delayMicroseconds(500); 
  }
  else if (turn == 1){
      digitalWrite(dirPin,LOW);
      digitalWrite(stepPin,HIGH); 
      delayMicroseconds(500); 
      digitalWrite(stepPin,LOW); 
      delayMicroseconds(500);
   }


  delayMicroseconds(4000);

  nh.spinOnce();

 
}
