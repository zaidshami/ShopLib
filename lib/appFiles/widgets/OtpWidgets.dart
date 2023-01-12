


import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' as yy;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:localstorage/localstorage.dart';

import '../common/tools/flash.dart';
import '../services/dependency_injection.dart';
import 'CountDownTimer.dart';
import 'package:http/http.dart' as http;
Future<dynamic> show_otp_dialog(context,String phone_number,VoidCallback createuser) async {
  List otp_data=(await checkotp_valid());
  my_showMessage(context,otp_data[1],isError:!otp_data[0] );
  if(otp_data[0]) {
    var rng = new Random();
    var code = rng.nextInt(9000) + 1000;
    // var res = await httpGet(
    //     'http://173.212.208.44/engazsms2/?username=RAHAFSTORE&pass=RAHAFSTORE5252&number=770401373&massage=$code'.toUri()!,
    //     );
   await  SendOtp(code.toString());
    print(code);
    return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      //  shape: ShapeBorder(r),
      builder: (context) {
        return
          Directionality(
            textDirection: yy.TextDirection.ltr,
            child: Container(
              // height: 600,
              padding: EdgeInsets.only(
                  bottom: MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: [
                    SizedBox(height: 20,),

                    Image.asset("assets/images/newot.jpg", height: 200,),
                    SizedBox(height: 20,),

                    Text.rich(


                        TextSpan(
                            text: 'يرجى ادخال الرمز الذي تم ارسالة الى رقم الهاتف  ',

                            children: <InlineSpan>[
                              TextSpan(
                                text: "( "+phone_number+" )",

                                recognizer: new TapGestureRecognizer()
                                  ..onTap = () {

                                  },


                              ),   TextSpan(
                                text: "\n"+"الرمز التجريبي $code",


                                style: TextStyle(color:  Colors.brown,
                                    fontSize: 15,

                                    fontWeight: FontWeight.bold),
                              ),
                            ]
                        ),
                    textAlign:TextAlign.center ),

                    SizedBox(height: 20,),
                    Container(
                      width: 60.0,
                      padding: EdgeInsets.only(top: 3.0, right: 4.0),
                      child: CountDownTimer(
                        secondsRemaining: 90,
                        whenTimeExpires: () {

                        },
                        countDownTimerStyle: TextStyle(
                         // color: Color(0XFFf5a623),
                          fontSize: 17.0,
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),

                    OtpTextField(
                      numberOfFields: 4,
                      showCursor: true,
                      borderColor: Colors.brown,
                      showFieldAsBox: true,
                      cursorColor: Colors.black,
                      enabledBorderColor: Colors.teal,
                      focusedBorderColor:  Colors.brown,
                      onCodeChanged: (String code) {},
                      autoFocus: true,
                      filled: true,

                      //runs when every textfield is filled
                      onSubmit: (String verificationCode) {
                        if (verificationCode.trim() == code.toString().trim()) {
                          // _showMessage('الرمز خاطئ');
                          Navigator.pop(context);

                          createuser();
                        } else {
                          my_showMessage(context,'الرمز خاطئ');
                        }
                      }, // end onSubmit
                    ),
                    SizedBox(height: 20,),

                    Text.rich(
                        TextSpan(
                            text: 'لم يصل الرمز ؟ ',
                            children: <InlineSpan>[
                              TextSpan(
                                text: 'اعادة ارسال ',
                                recognizer: new TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pop(context);
                                    show_otp_dialog(context,phone_number, createuser);
                                  },

                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              )
                            ]
                        )),
                    SizedBox(height: 20,),

                  ],
                ),
              ),
            ),
          );
      },
    );
  }
}
 SendOtp(String code) async {
  try {
    var req = await http.post(
      Uri.parse('https://www.msegat.com/gw/sendsms.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userName': 'qanaterzzzzzzzzzzzzzzzzzzzzzz',
        'numbers': '966563064444',
        'userSender': 'qanaterzzzzzzzzzzzzzzzzz',
        'apiKey': 'ac376b5cbbf2b9c08aeb546b6f2ea833',
        'msg': "رمز التحقق: $code"
        //("$codeرمز التحقق لتأكيد حسابك في قناطر ").toString()

      }),

    ).timeout(Duration(seconds: 5));
    print("ottttp status code  " + req.statusCode.toString());

    print("ottttp response " + req.body.toString());
  }catch(k){

  }
}

void my_showMessage(context,String text, {bool isError = true,}) {

  if(!isError){
    FlashHelper.message(
      context,
      message: text,
    );}else{
    FlashHelper.errorMessage(
      context,
      message: text,
    );
  }
}

Future<List> checkotp_valid() async {
  final storage = injector<LocalStorage>();
  DateTime now = DateTime.now();
  print( now.millisecondsSinceEpoch.toString());
  int half_our=1800000;
  //otp_tries=0;
  try {
    final ready = await storage.ready;
    if (ready) {
      final json = storage.getItem('otp_request');
      if (json != null) {
        int past_millisecend=json;
        print(now.millisecondsSinceEpoch.toString()+" "+(past_millisecend+half_our).toString());

        if(now.millisecondsSinceEpoch>(past_millisecend+half_our)){

          if(otp_tries<6) {
            await storage.setItem('otp_request', null);

          }else{
            otp_tries++;

          }

          return Future.value([true,true_msg]);

        }else{
          double minutes= (((past_millisecend+half_our)-now.millisecondsSinceEpoch)/60000);
          return Future.value([false,"يرجى المحاولة بعد "+ minutes.roundToDouble().toString()+" دقيقة"] );

        }
      } else {


        if(otp_tries<6) {
          otp_tries++;
          return Future.value([true,true_msg] );
        }else{
          otp_tries=0;
          await storage.setItem('otp_request', now.millisecondsSinceEpoch);
          return Future.value([false,false_msg] );
        }



      }
    }
  } catch (err) {
    print("test"+err.toString());

    return Future.value([false,false_msg]);

  }
  return Future.value([false,false_msg]);

}
String true_msg="تم ارسال الرمز الى رقم هاتفك ";
String false_msg="يرجى المحاولة في وقت لاحق  ";


int otp_tries=0;