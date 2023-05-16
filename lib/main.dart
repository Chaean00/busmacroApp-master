import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

var _id = '';
var _pw = '';
var _upTime = '';
var _downTime = '';
var _upSeat = '';
var _downSeat = '';

void main() {
  // 앱 시작해주세요~
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('버스 매크로'),
        ),
        body: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  SizedBox(height: 20,),
                  SizedBox(
                    width: 150, height: 50,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'ID',
                        hintText: 'ID를 입력해주세요',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (text) {_id = text;},
                    ),
                  ),
                  SizedBox(height: 20,),
                  SizedBox(
                    width: 150, height: 50,
                    child: TextField(
                        decoration: InputDecoration(
                          labelText: 'PW',
                          hintText: 'PW를 입력해주세요',
                          border: OutlineInputBorder(),
                        ),
                      onChanged: (text) {_pw = text;},
                    ),
                  ),
                  SizedBox(height: 20,),
                  SizedBox(
                    width: 150, height: 50,
                    child: TextField(
                        decoration: InputDecoration(
                          labelText: '등교시간',
                          hintText: '등교시간을 입력해주세요',
                          border: OutlineInputBorder(),
                        ),
                      onChanged: (text) {_upTime = text;},
                    ),
                  ),
                  SizedBox(height: 20,),
                  SizedBox(
                    width: 150, height: 50,
                    child: TextField(
                        decoration: InputDecoration(
                          labelText: '하교시간',
                          hintText: '하교시간을 입력해주세요',
                          border: OutlineInputBorder(),
                        ),
                      onChanged: (text) {_downTime = text;},
                    ),
                  ),
                  SizedBox(height: 20,),
                  SizedBox(
                    width: 150, height: 50,
                    child: TextField(
                        decoration: InputDecoration(
                          labelText: '등교좌석',
                          hintText: '등교좌석번호를 입력해주세요',
                          border: OutlineInputBorder(),
                        ),
                      onChanged: (text) {_upSeat = text;},
                    ),
                  ),
                  SizedBox(height: 20,),
                  SizedBox(
                    width: 150, height: 50,
                    child: TextField(
                        decoration: InputDecoration(
                          labelText: '하교좌석',
                          hintText: '하교좌석번호를 입력해주세요',
                          border: OutlineInputBorder(),
                        ),
                      onChanged: (text) {_downSeat = text;},
                    ),
                  ),
                  SizedBox(height: 50,),
                  ElevatedButton(onPressed: () {
                    executeThread();
                  },
                    child: Text('슛'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.amberAccent,
                      onPrimary: Colors.black,
                      fixedSize: const Size(150, 50),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(height: 20,),
                  Container(
                    margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                    child: Text("등교\n\n07:50\n08:00\n08:10\n08:20\n08:30\n08:40\n08:50\n09:00\n09:10\n09:20\n09:30\n09:40\n09:50\n10:00\n10:10\n10:20\n10:30\n10:40\n10:50\n11:00\n11:10\n11:20\n11:30\n11:40\n11:50\n12:00\n12:20\n12:40"),
                  )
              ],
              ),
              Column(
                children: [
                  SizedBox(height: 20,),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Text("하교\n\n09:10\n09:20\n09:30\n09:40\n09:50\n10:00\n10:10\n10:20\n10:30\n10:40\n10:50\n11:00\n11:20\n11:40\n12:00\n13:00\n13:20\n13:40\n14:00\n14:20\n14:40\n15:00\n15:10\n15:20\n15:30\n15:40\n16:00\n16:30\n17:00\n17:10\n17:20\n17:30\n18:00\n18:30\n19:00"),
                  )
                ],
              ),
              Column(
                children: [
                  SizedBox(height: 20,),
                  Container(
                    margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                    child: Text("운전석\n\n1 2          3 4\n5 6          7 8\n9 10        11 12\n13 14      15 16\n17 18      19 20\n21 22      23 24\n25 26      27 28\n29 30      31 32\n33 34      35 36\n37 38      39 40\n\n가끔 오른쪽이\n1일때도 있음"),
                  )
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}

void runningApp() async {

  var loginData = {
    "id" : _id,
    "pass" : _pw,
    "autoLogin" : ""
  };
  var upBusSeq; // 등교 버스번호 값
  var downBusSeq; // 하교 버스번호 값
  var upReserveData; // 등교 예약 데이터
  var downReserveData; // 하교 예약 데이터
  var busDownReserve; // 하교 예약 실행
  var busUpReserve; // 등교 예약 실행
  // 로그인 요청 URL
  var loginUrl = "https://daejin.unibus.kr/api/index.php?ctrl=Main&action=loginProc";
  // 버스예약 요청 URL
  var reserveUrl = "https://daejin.unibus.kr/api/index.php?ctrl=BusReserve&action=reserveAppProc";
  // 버스 리스트 url (노원하교)
  var busListDownUrl = "https://daejin.unibus.kr/api/index.php?ctrl=BusReserve&action=busList&dir=DOWN&lineGroupSeq=27";
  // 버스 리스트 url (노원등교)
  var busListUpUrl = "https://daejin.unibus.kr/api/index.php?ctrl=BusReserve&action=busList&dir=UP&lineGroupSeq=28";

  Dio dio = Dio();

  var response = await dio.post(loginUrl, data: jsonEncode(loginData));

  if (response.data['result'].contains("OK")) {
    // 쿠키 파싱
    var needParse = response.headers['set-cookie'].toString();
    var sessionIdStartIndex = needParse.indexOf("PHPSESSID=") + "PHPSESSID=".length;
    var sessionIdEndIndex = needParse.indexOf(";", sessionIdStartIndex);
    var sessionId = needParse.substring(sessionIdStartIndex, sessionIdEndIndex);

    // cookie
    var cookie = {
      "PHPSESSID" : sessionId,
    };
    // Authorization
    var token = response.data['data'];
    var header = {
      "Authorization": token,
    };

    if (token != null) {
      // 하교(노원) 버스리스트 가져오기
      var busDownResponse = await dio.get(busListDownUrl, options: Options(headers: header, extra: cookie),);
      if (busDownResponse.statusCode == 200) {
        var downData = busDownResponse.data;
        for (var data in downData['data']['busList']) {
          // 하교 버스 시간 설정
          if (data['operateTime'] == _downTime) {
            downBusSeq = data['busSeq'];
          }
        }
      } else {
        print("하교 버스 리스트 가져오기 실패");
      }
      
      // 등교(노원) 버스리스트 가져오기
      var busUpResponse = await dio.get(busListUpUrl, options: Options(headers: header, extra: cookie),);
      if (busUpResponse.statusCode == 200) {
        var upData = busUpResponse.data;
        for (var data in upData['data']['busList']) {
          // 등교 버스 시간 설정
          if (data['operateTime'] == _upTime) {
            upBusSeq = data['busSeq'];
          }
        }
      } else {
        print("등교 버스 리스트 가져오기 실패");
      }
    } else {
      print("토큰 값이 없습니다");
    }

    // 하교 버스 데이터
    // 노원 lineSeq - 27 / stopSeq - 77
    // 마들 line Seq - 27 / stopSeq - 78
    // 수락산역 lineSeq - 27 / stopSeq - 79
    try {
      downReserveData = {
        "busSeq" : downBusSeq, // 버스번호
        "lineseq" : "27", // 버스노선
        "stopSeq" : 77, // 하차위치
        "seatNo" : int.parse(_downSeat) // 좌석번호
      };
    } catch (e){
      print(e);
    }
    // 등교 버스 데이터
    // 태릉 lineSeq - 32 / stopSeq - 112
    // 중화 lineSeq - 31 / stopSeq - 106
    // 노원 lineSeq - 28 / stopSeq - 80
    // 하계 lineSeq - 33 / stopSeq - 113
    // 등교 위치가 변경될 경우 busListUpUrl의 맨 마지막 lineGroupSeq=28의 숫자도 lineSeq값으로 변경해야댐
    try {
      upReserveData = {
        "busSeq" : upBusSeq, // 버스번호
        "lineseq" : "28", // 버스노선
        "stopSeq" : 80, // 하차위치
        "seatNo" : int.parse(_upSeat) // 좌석번호
      };
    } catch (e) {
      print(e);
    }

    // 하교 버스 예약 실행
    try {
      busDownReserve = await dio.post(reserveUrl, data: downReserveData, options: Options(headers: header, extra: cookie));
    } catch (e) {
      print(e);
    }

    // 등교 버스 예약 실행
    try {
      busUpReserve = await dio.post(reserveUrl, data: upReserveData, options: Options(headers: header, extra: cookie));
    } catch (e) {
      print(e);
    }

    print("result값이 OK면 성공");
    try {
      print('등교내역 : ${busUpReserve.toString()}');
    } catch (e) {
      print(e);
    }
    try {
      print('하교내역 : ${busDownReserve.toString()}');
    } catch (e) {
      print(e);
    }
  } else {
    print("로그인 실패");
    print(response.data);
  }
}

void checkAt22() {
  DateTime now = DateTime.now();
  if (now.hour >= 22) {
    runningApp();
  } else {
    // 22시 - 현재 시간을 하여 변수에 담고 sleep을 통해 기다린 뒤 실행
    int remainingSeconds = (22 - now.hour) * 3600 - now.minute * 60 - now.second;
    Future.delayed(Duration(seconds: remainingSeconds + 1), runningApp);
  }
}

void executeThread() {
  Timer.run(checkAt22);
}