
class DateTimeParser {
  String defaultParse(DateTime date) {
    DateTime currentTime = DateTime.now();
    if(date.year == currentTime.year && date.month == currentTime.month && date.day == currentTime.day &&
        date.hour == currentTime.hour && date.minute == currentTime.minute && date.second == currentTime.second) {
      // 같은 초일 때
      return "방금";
    } else if (date.year == currentTime.year && date.month == currentTime.month &&
        date.day == currentTime.day && date.hour == currentTime.hour && date.minute == currentTime.minute) {
      //같은 분일 때
      return "${currentTime.second - date.second}초 전";
    } else if (date.year == currentTime.year && date.month == currentTime.month &&
        date.day == currentTime.day && date.hour == currentTime.hour) {
      //같은 시일 때
      //몇분 전
      return "${currentTime.minute - date.minute}분 전";
    } else if (date.year == currentTime.year && date.month == currentTime.month && date.day == currentTime.day) {
      //같은 날일 때
      //몇 시간 전
      return "${currentTime.hour - date.hour}시간 전";
    } else if(date.year == currentTime.year && date.month == currentTime.month) {
      // 같은 달일 때
      // 몇 일 전
      return "${currentTime.day - date.day}일 전";
    } else if(date.year == currentTime.year) {
      // 같은 년일 때
      // 정확한 일자 표시
      return "${date.month}월 ${date.day}일";
    } else {
      // 1년 전 게시글
      return "${date.year}년 ${date.month}월 ${date.day}일";
    }

  }
}