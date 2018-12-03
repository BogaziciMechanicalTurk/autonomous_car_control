
const float pi = 3.141592;

//pins

const int stepPin = 9; 
const int dirPin = 10; 
const int enPin = 11;

const int fwPin = 2;
const int brPin = 5;


//const int potPin='A2';
#include <ros.h>
#include <std_msgs/Int16.h>
#include <std_msgs/Float32.h>


#include "stdlib.h"

int pp0 = 2;  // analog pin used to connect the potentiometer

// steer variables

float steer_max = 23;
float steer_min = -23;
float steer_tol = 2;

float speed_max = 30/3.6;
float voltage_max = 4.5;

float steer_cmd = 0;
float speed_cmd = 0;
float break_cmd = -1;

float steer = 0;
int start = 0;
int pub_count = 0;
int pub_max = 9;


float mid_offset = 259;
float normalization_coeff = 120.0/1024.0;

// locked wheel parameters

float start_angle = 0.0;
float actual_turn = 0.0;
float expected_turn = 0.0;
float lock_th = 2.0;
int lock_delay_ms = 1000;

int step_delay_us = 2000;
float pulse_rev = 800;

ros::NodeHandle  nh;

void startCb( const std_msgs::Int16& start_msg){
  start = start_msg.data;
}

void steerCb( const std_msgs::Float32& steer_cmd_msg){
  steer_cmd = steer_cmd_msg.data;
}

void speedCb( const std_msgs::Float32& speed_cmd_msg){
  speed_cmd = speed_cmd_msg.data;
}

void breakCb( const std_msgs::Float32& break_cmd_msg){
  break_cmd = break_cmd_msg.data;
}

ros::Subscriber<std_msgs::Int16> startSub("/start", &startCb);
ros::Subscriber<std_msgs::Float32> steerSub("/steer", &steerCb);
ros::Subscriber<std_msgs::Float32> speedSub("/speed", &speedCb);
ros::Subscriber<std_msgs::Float32> breakSub("/break", &breakCb);


std_msgs::Float32 steer_msg;
ros::Publisher steerPub("steer_fb", &steer_msg);

void setup()
{
  nh.initNode();
  nh.subscribe(startSub);
  nh.subscribe(steerSub);
  nh.subscribe(speedSub);
  nh.subscribe(breakSub);
  
  nh.advertise(steerPub);
  

  // steer setup

  pinMode(stepPin,OUTPUT); 
  pinMode(dirPin,OUTPUT);
  pinMode(enPin,OUTPUT);
  digitalWrite(enPin,LOW);

  // speed setup

  pinMode(fwPin, OUTPUT);

  // break setup

  pinMode(brPin, OUTPUT);
  digitalWrite(brPin,HIGH);
}

void loop()
{

  if(start){
    analogWrite(LED_BUILTIN,255*speed_cmd/speed_max*voltage_max);
    analogWrite(fwPin,255*speed_cmd/speed_max*voltage_max);

    if(break_cmd > 0){
      digitalWrite(brPin,LOW);
    }
    else{
      digitalWrite(brPin,HIGH);
    }

    if(fabs(steer_cmd-steer)>steer_tol){

      // locked wheel check
      actual_turn = steer - start_angle;

      if(fabs(actual_turn - expected_turn) > lock_th){

        actual_turn = 0.0;
        expected_turn = 0.0;
        steer = (analogRead(pp0)-mid_offset)*normalization_coeff;
        start_angle = steer;

        delayMicroseconds(lock_delay_ms*1000);
        
      }

      if(steer_cmd > steer && steer < steer_max){
        
        digitalWrite(dirPin,HIGH);
        digitalWrite(stepPin,HIGH); 
        delayMicroseconds(500); 
        digitalWrite(stepPin,LOW); 
        delayMicroseconds(500);

        expected_turn = expected_turn + 360.0/pulse_rev;
      }

      if(steer_cmd < steer && steer > steer_min){
        
        digitalWrite(dirPin,LOW);
        digitalWrite(stepPin,HIGH); 
        delayMicroseconds(500); 
        digitalWrite(stepPin,LOW); 
        delayMicroseconds(500);

        expected_turn = expected_turn - 360.0/pulse_rev;
        
      }
    }
    else{
      expected_turn = 0.0;
      actual_turn = 0.0;
      start_angle = steer;  
    }  
  }
  else{
    // analogWrite(LED_BUILTIN,speed_cmd/speed_max*voltage_max);
    analogWrite(fwPin,255*speed_cmd/speed_max*voltage_max);
    expected_turn = 0.0;
    actual_turn = 0.0;
    start_angle = steer;
  }

  if(pub_count > pub_max){
    
    steer = (analogRead(pp0)-mid_offset)*normalization_coeff;
    steer_msg.data = steer;
    
    steerPub.publish( &steer_msg );
    
    pub_count = 0;
    
    nh.spinOnce();
  }

  pub_count++;
    
  delayMicroseconds(step_delay_us);
 
}
