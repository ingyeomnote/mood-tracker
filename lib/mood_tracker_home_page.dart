import 'package:flutter/material.dart';
import 'mood_count.dart';
import 'mood_manager.dart';
import 'mood_dialog.dart';
import 'mood_calendar.dart';
import 'mood.dart';
import 'statistics_page.dart';

// 상태 관리가 필요한 홈 페이지 위젯을 정의한다.
class MoodTrackerHomePage extends StatefulWidget {
  MoodTrackerHomePage({Key? key}) : super(key : key);

  /*
    StatefulWidget을 사용할 때, 위젯의 상태를 관리하는 별도의 State 클래스를 정의하는 이유는,
    StatefulWidget과 State 클래스가 분리되어 있기 때문이다. 이는 코드의 재사용성과 생명주기 관리에 용이하다.
    개발자는 UI 구조를 변경하고자 할 때 StatefulWidget을 수정하고,
    상태 관리 로직을 변경하고자 할 때 State 클래스를 수정함으로써, 두 영역을 명확하게 구분할 수 있다.
   */

  // createState() 함수는 위젯의 상태를 관리할 State 객체를 생성한다.
  // 이 패턴은 flutter에서 상태가 동적으로 변경될 수 있는 모든 위젯에 적용된다.
  @override
  _MoodTrackerHomePageState createState() => _MoodTrackerHomePageState();
}

// MoodTrackerHomePage 위젯의 상태를 관리하는 클래스이다.
/*
  State 객체는 앱이 실행되는 동안 사용자의 인터랙션 또는 데이터 변경에 의해 발생하는 모든 상태변경을 보관한다.
  또한, 상태가 변결될 때 마다 setState() 함수를 사용하여 위젯의 build() 함수를 호출하고, 변경된 상태에 따라 UI를 갱신한다.
*/
class _MoodTrackerHomePageState extends State<MoodTrackerHomePage> {
  String _mood = 'Good'; // 현재 사용자의 기분을 저장하는 변수이다.
  String _memo = ''; // 사용자가 입력한 메모를 저장하는 변수이다.
  DateTime _selectedDay = DateTime.now(); // 선택된 날짜를 저장한다.
  Map<DateTime, List<dynamic>> _moods = {}; // 날짜별 기분과 메모를 저장하는 맵이다.
  TextEditingController _memoController = TextEditingController(); // 메모 입력을 위한 컨트롤러이다.
  MoodManager moodManager = MoodManager(); // MoodManager 인스턴스를 생성한다.
  Map<DateTime, String> moodEvents = {};

  // State 객체가 생성된 후 처음으로 호출되는 함수
  // 초기화(변수의 초기 설정, 데이터 로딩, 네트워크 요청 등) 작업을 초기에 한 번만 수행한다.
  // 위젯이 화면에 표시되기 전에 데이터를 미리 불러올 때 사용한다.
  @override
  void initState() {
    super.initState(); // 부모 클래스의 initState() 함수 호출(필수)
    _loadMoods(); // 초기화 시 기분 데이터를 불러온다.
  }

  /*
    Future 클래스는 dart의 비동기 프로그래밍을 위한 클래스, 미래에 어떤 값이나 이벤트를 반환한다.
    Future<void>의 경우, 작업이 완료된 후 반환할 값이 없을 때 사용한다.

    async 키워드는 함수가 비동기 함수임을 나타내며, 이 함수 내에서 await 키워드를 사용할 수 있게 한다.
    async 키워드를 사용한 함수는 자동으로 Future를 반환한다.
    ㄴ 비동기 작업을 수행할 때, 네트워크 요청·파일I/O 등을 비동기적으로 처리하고 싶을 때 사용한다.
   */
  // 기분 데이터를 불러오는 비동기 함수이다.
  Future<void> _loadMoods() async {
    // moodManager.loadMoods()는 비동기적으로 기분 데이터를 불러오는 함수이다.
    // 해당 함수는 Future<Map<DateTime, List<dynamic>>를 반환하므로,
    // 데이터 로딩이 완료될 때 까지 기다리기 위해 await를 사용함
    _moods = await moodManager.loadMoods();

    // 새로운 Map<DateTime, String>으로 변환(기분 상태 이미지 연결)
    Map<DateTime, String> moodEvents = Map.fromEntries(
      _moods.entries
        .where((entry){
          // 기분 상태가 유효한 지 확인(key 존재 여부)
          String mood = entry.value.isNotEmpty ? entry.value[0] as String : '';
          return moodImages.containsKey(mood);
        })
        .map((entry){
          // 기분 상태에 맞는 이미지 경로 추출
          String mood = entry.value[0] as String;
         String imgPath = moodImages[mood]!;


          // MapEntry를 반환하여 날짜-이미지 쌍 생성
          return MapEntry(entry.key, imgPath);
        }),
    );

    setState(() {
      this.moodEvents = moodEvents;
    });
    /*
      setState() 함수는 주어진 함수를 실행하고, 함수 실행이 완료된 후에 위젯의 build() 메서드를 호출하여,
      화면을 갱신한다. 이는 데이터 변경 후 UI를 업데이트해야 할 때 필수적으로 사용된다.
      setState() 함수 호출이 없다면, 데이터는 업데이트 되어도 UI에 반영되지 않는다.
      setState((){
        이 블록 안에 UI를 업데이트 하기 위한 상태 변경 코드를 넣을 수 있다.
        지금 예시에선 특별한 상태 변경 없이 UI를 갱신하고 있다.
      });
     */
  }

  // 기분과 메모를 저장하는 비동기 함수이다.
  Future<void> _saveMood() async {
    await moodManager.saveMoods(_moods);
    _memoController.clear(); // 메모 입력 필드를 초기화한다.
    _loadMoods(); // save 눌렀을 때 바로 이모티콘 나오게..?
  }

  // 기분 입력을 위한 다이얼로그를 보여주는 함수이다.
  Future<void> _showMoodDialog() async {
    // 저장된 데이터 불러오기
    if(_moods.containsKey(_selectedDay)){
      List? savedData = _moods[_selectedDay];
      if(savedData != null){
        _mood = savedData[0];
        _memoController.text = savedData[1];
      }
    } else{ // 한 번 event가 있는 날을 선택하면 그 날의 감정이 _mood에 들어간다.
            // 이 _mood에 들어간 감정이, 다른 날을 선택해도 계속 남아있어서 event가 있으면 덮어씌어짐, 없으면 전에께 남아있으니 초기화
      _mood = " ";
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // 다이얼로그 바깥을 터치하면 닫힘
      builder: (BuildContext context) {
        return MoodDialog(
          initialMood: _mood,
          memoController: _memoController,
          onMoodSelected: (mood) {
            _mood = mood; // 선택된 기분을 상태에 저장
          },
          onSavePressed: (){
            _moods[_selectedDay] = [_mood, _memoController.text];
            _saveMood();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("home_page $context");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'), // 앱 바의 타이틀을 설정한다.
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => StatisticsPage(moodEvents: moodEvents)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.access_alarm),
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MoodCount(moodEvents: moodEvents)),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          MoodCalendar(
            selectedDay: _selectedDay, // 선택된 날짜
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay; // 사용자가 새로운 날짜를 선택하면 상태를 업데이트
              });
              print("selectedDay : $_selectedDay and foucsedDay : $focusedDay");
              if(moodEvents.containsKey(_selectedDay)){ // 감정이 기록된 날에는 다이얼로그를 표시하지 않는다.
                print("all : $_moods");
              }else{
                _memoController.clear();
              }
              _showMoodDialog(); // 새로운 기분을 입력받기 위한 다이얼로그를 보여준다.
            },
            //eventLoader: (day) => _moods[day] ?? [], // 해당 날짜의 기분 데이터를 불러온다.
            eventLoader: (DateTime day){
              // print("Querying events for: $day");
              return _moods[day] ?? []; // ?? [] : dart의 null-coalescing 연산자, _moods[day]에서 조회한 값이,
                                        // null일 경우(해당 날짜에 데이터가 없는 경우) []를 반환한다.
              // save 버튼을 눌러야 저장이 되야하고, 선택했을 때는 이벤트로더가 돌면 안되는데 돌아버림.. -> 해결했지만 이벤트  -> 수정
            },
            moodEvents: moodEvents,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _memoController.dispose(); // 위젯이 제거될 때 메모 컨트롤러를 해제한다.
    super.dispose();
  }
}
