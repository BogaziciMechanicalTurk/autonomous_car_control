/*
 * rosserial Publisher Example
 * Prints "hello world!"
 */

//const int stepPin = 5; 
//const int dirPin = 2; 
//const int enPin = 9;

//const int fwPin = 11;
//const int brPin = 3;

const int stepPin = 9; 
const int dirPin = 10; 
const int enPin = 11;

const int fwPin = 2; 
const int brPin = 5;


#include <ros.h>
#include <std_msgs/Int16.h>
#include <std_msgs/Float32.h>

#include "stdlib.h"


ros::NodeHandle  nh;

int turn = 0;
int forward = 0;
int brake = 0;

void messageCb( const std_msgs::Int16& keyboard_msg){
  turn = keyboard_msg.data;
}

void messageCb1( const std_msgs::Int16& keyboard_msg){
  forward = keyboard_msg.data;
}

void messageCb2( const std_msgs::Int16& keyboard_msg){
  brake = keyboard_msg.data;
}
ros::Subscriber<std_msgs::Int16> sub("turn", &messageCb);
ros::Subscriber<std_msgs::Int16> sub1("forward", &messageCb1);
ros::Subscriber<std_msgs::Int16> sub2("brake", &messageCb2);

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
  pinMode(brPin, OUTPUT);
  digitalWrite(enPin,LOW);
  digitalWrite(brPin,LOW);
}

void loop()
{

  if(forward == 1){
      analogWrite(LED_BUILTIN,1.5*255/5);
      analogWrite(fwPin,1.9*255/5);
  }
  else{
      analogWrite(LED_BUILTIN,0.0*255/5);
      analogWrite(fwPin,0.0*255/5);   
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

   
  if(brake == 1){
      digitalWrite(brPin,LOW);
  }
  else{
      digitalWrite(brPin,HIGH);  
  }


  delayMicroseconds(3000);

  nh.spinOnce();

 
}
