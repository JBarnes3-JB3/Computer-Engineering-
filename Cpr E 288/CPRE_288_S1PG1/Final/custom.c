
#include "timer.h"
#include "adc.h"
#include "uart_extra_help.h"
#include "string.h"
#include "math.h"
#include "open_interface.h"
#include "servo.h"
#include "ping.h"


//PRINT STRING TO PUTTY
void puttyPrint(char out[]){
    int i=0;
    for( i= 0; i < strlen(out); ++i){
        char b = out[i];
        uart_sendChar(b);
    }
}

//CONVERT IR RAW TO DISTANCE
float convertIR(int rawIR){

    //int IR_Raw = sensor_Scan.IR_raw_val;

    // y = 600(x)^-1.5  +10
	// x = 71.13786608/ (y-10)^0.6666

    //IR CALC
    float IR_Dist =0;
    float y_Val = ((float)rawIR/100) -10;
    IR_Dist = 71.13786608/pow(y_Val, 0.6666);

    return IR_Dist;


}

int scanIR(int samples){

    int value = 0;
    int i=0;

    for (i = 0; i < samples; ++i)
    {
        value += adc_read();
        timer_waitMillis(10);
    }
    value = value / i;

    return value;

}

int boundCheck(oi_t *sensor){
    //TEST
    int valueL = 0;
    int valueR = 0;
    int valueFR = 0;
    int valueFL = 0;
    int i =0;
    char out[100] ="";
    short sampSize =1;
    int lowVal = 350;
    int highVal = 2680;

    for (i = 0; i < sampSize; ++i){
        valueFR += sensor->cliffFrontRightSignal;
        valueFL += sensor->cliffFrontLeftSignal;
        valueR += sensor->cliffRightSignal;
        valueL += sensor->cliffLeftSignal;
    }
    valueL = valueL / sampSize;
    valueR = valueR / sampSize;
    valueFR = valueFR / sampSize;
    valueFL = valueFL / sampSize;

    if(valueL > highVal || valueL <lowVal){
        sprintf(out, "SENSOR L: %d \n\r", valueL);
        puttyPrint(out);
        if(valueL <lowVal){
            return 0;
        }
        return 1;
    }
    else if(valueFL > highVal || valueFL <lowVal){
       sprintf(out, "SENSOR FL: %d \n\r", valueFL);
       puttyPrint(out);
       if(valueFL <lowVal){
           return 0;
       }
       return 2;
    }
    else if(valueFR > highVal || valueFR <lowVal){
       sprintf(out, "SENSOR FR: %d \n\r", valueFR);
       puttyPrint(out);
       if(valueFR <lowVal){
           return 6;
       }
       return 4;
    }
    else if(valueR > highVal || valueR <lowVal){
       sprintf(out, "SENSOR R: %d \n\r", valueR);
       puttyPrint(out);
       if(valueR <lowVal){
           return 6;
       }
       return 5;
    }
    else{
        return 3;
    }


}

int quickScan(oi_t *sensor){
    int start = 0;
    int object = 0;
    float temp =0;
    float i=0;
    int angle=0;
    char out[20]= "OBJECT FRONT";
    oi_setWheels(0,0);
    servo_move2(0);
    timer_waitMillis(700);

    sprintf(out, "\n\r");
    puttyPrint(out);

    for(i=0; i<18; ++i){
        angle = start+ (i*10);
        servo_move2(angle);
        timer_waitMillis(100);
        temp = ping_distance();

        if (temp < 25.8 - abs(9-i)){  //- abs(7-i)

            uart_sendChar('X');

            if(angle<=94){
                timer_waitMillis(150);
               return 1;
            }else{
                return 2;
            }
        } else{
//            sprintf(out, "%d %0.2f,  ", angle, temp);
//            puttyPrint(out);
            uart_sendChar('O');
        }
        timer_waitMillis(100);
    }


    if(object == 0){
        sprintf(out, "Front clear \n\r");
        puttyPrint(out);
    }

    return object;
}

int forwardRotate(oi_t *sensor){
               oi_setWheels(0,0);
               int scan = quickScan(sensor);
               timer_waitMillis(1000);
               int turn = 2;
               int lastate =0;
               int quickCount =1;

               while(scan >0){
                   if(scan==1){
                       turn_any(sensor, turn*quickCount);
                       if(lastate==2){
                           quickCount+=2;
                       }
                       lastate =1;
                   }else if(scan==2){
                       turn_any(sensor, -turn*quickCount);
                       if(lastate==1){
                           quickCount+=2;
                       }
                       lastate =2;
                   }
                   scan = quickScan(sensor);
               }
               quickCount=1;

               return 0;
}


