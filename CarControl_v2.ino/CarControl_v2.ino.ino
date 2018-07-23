/*
 * rosserial Publisher Example
 * Prints "hello world!"
 */

const float pi = 3.141592;

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

float steer_max = 20;
float steer_min = -20;
float steer_tol = 2;

int val;    // variable to read the value from the analog pin
double d_val;
double result;
float steer_cmd = 0;
float speed_cmd = 0;
float steer = 0;
int start = 0;
int pub_count = 0;
int pub_max = 9;

ros::NodeHandle  nh;

int turn = 0;
int forward = 0;

void startCb( const std_msgs::Int16& start_msg){
  start = start_msg.data;
}

void steerCb( const std_msgs::Float32& steer_cmd_msg){
  steer_cmd = steer_cmd_msg.data;
}

void speedCb( const std_msgs::Float32& speed_cmd_msg){
  speed_cmd = speed_cmd_msg.data;
}

ros::Subscriber<std_msgs::Int16> startSub("/start", &startCb);
ros::Subscriber<std_msgs::Float32> steerSub("/steer", &steerCb);
ros::Subscriber<std_msgs::Float32> speedSub("/speed", &speedCb);




std_msgs::Float32 steer_msg;
ros::Publisher steerPub("steer_fb", &steer_msg);

std_msgs::Int16 pot1_msg;
ros::Publisher pot1Pub("pot1", &pot1_msg);

std_msgs::Int16 pot2_msg;
ros::Publisher pot2Pub("pot2", &pot2_msg);

std_msgs::Int16 pot3_msg;
ros::Publisher pot3Pub("pot3", &pot3_msg);

void setup()
{
  nh.initNode();
  nh.subscribe(startSub);
  nh.subscribe(steerSub);
  nh.subscribe(speedSub);
  nh.advertise(steerPub);
  nh.advertise(pot1Pub);
  nh.advertise(pot2Pub);
  nh.advertise(pot3Pub);

  pinMode(stepPin,OUTPUT); 
  pinMode(dirPin,OUTPUT);
  pinMode(enPin,OUTPUT);
  pinMode(fwPin, OUTPUT);
  digitalWrite(enPin,LOW);
}

void loop()
{

  //int potVal = analogRead(A2);

  if(start){
    analogWrite(LED_BUILTIN,1.5*255/5);
    analogWrite(fwPin,speed_cmd);

    if(fabs(steer_cmd-steer)>steer_tol){
      if(steer_cmd > steer && steer < steer_max){
        
        digitalWrite(dirPin,HIGH);
        digitalWrite(stepPin,HIGH); 
        delayMicroseconds(500); 
        digitalWrite(stepPin,LOW); 
        delayMicroseconds(500); 
      }

      if(steer_cmd < steer && steer > steer_min){
        
        digitalWrite(dirPin,LOW);
        digitalWrite(stepPin,HIGH); 
        delayMicroseconds(500); 
        digitalWrite(stepPin,LOW); 
        delayMicroseconds(500);
        
      }

      
      
    }  
  }
  else{
    analogWrite(LED_BUILTIN,0.5*255/5);
    analogWrite(fwPin,0.5*255/5);

    
  }

  if(pub_count > pub_max){

    result= 0;
    val = analogRead(pp0);            // reads the value of the potentiometer (value between 0 and 1023)
    d_val = val+1;

    
    pot1_msg.data = val;
    
    pot1Pub.publish( &pot1_msg );
    
    if (d_val < 512){
      d_val = a1*exp(b1*d_val)+c1*exp(d1*d_val);
    }
    else{
      d_val = a2*exp(b2*d_val)+c2*exp(d2*d_val);
      d_val = l_max-d_val;
    }
    
    result = d_val;
    
    val = analogRead(pp1);
    d_val = val+1;

    pot2_msg.data = val;
    pot2Pub.publish( &pot2_msg );
    
    if (d_val < 512){
      d_val = a1*exp(b1*d_val)+c1*exp(d1*d_val);
    }
    else{
      d_val = a2*exp(b2*d_val)+c2*exp(d2*d_val);
      d_val = l_max-d_val;
    }
    
    result = result + d_val; 
    
    val = analogRead(pp2);
    d_val = val+1;

    pot3_msg.data = val;
    pot3Pub.publish( &pot3_msg );
    
    if (d_val < 512){
      d_val = a1*exp(b1*d_val)+c1*exp(d1*d_val);
    }
    else{
      d_val = a2*exp(b2*d_val)+c2*exp(d2*d_val);
      d_val = l_max-d_val;
    }
    
    result = result + d_val; 
    
    steer_msg.data = -(result/l_max/3-0.7)*70;

    steer = -(result/l_max/3-0.7)*70;
    
    steerPub.publish( &steer_msg );

    
    pub_count = 0;
    
    nh.spinOnce();
  }

  pub_count++;
    

  delayMicroseconds(4000);


 
}
