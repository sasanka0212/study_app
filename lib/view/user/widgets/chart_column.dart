import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/classes/quiz.dart';
import 'package:study_app/utils/colors.dart';
import 'package:study_app/view/user/pages/quiz_history.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartColumn extends StatefulWidget {
  final int currentScore;
  final int bestScore;
  final List<int> scores;
  final double growth;
  final IconData icon;
  final Quiz quiz;
  const ChartColumn({
    super.key,
    required this.currentScore,
    required this.bestScore,
    required this.scores,
    required this.growth,
    required this.icon,
    required this.quiz,
  });

  @override
  State<ChartColumn> createState() => _ChartColumnState();
}

class _ChartColumnState extends State<ChartColumn> {
  late List<int> scoreCount;
  late int maximumColVal;
  late int maxiScore;
  late List<ChartColumnData> chartData;

  @override
  void initState() {
    super.initState();
    maxiScore = _getMax(widget.scores);
    scoreCount = _count();
    maximumColVal = _getMaximum(scoreCount);
    chartData = _getColumnData(scoreCount, maximumColVal);
  }

  int _getMax(List<int> scores) {
    int maxi = 0;
    for (int i in scores) {
      maxi = maxi > i ? maxi : i;
    }
    return maxi;
  }

  List<ChartColumnData> _getColumnData(List<int> scoreCount, int maxVal) {
    List<ChartColumnData> chartData = <ChartColumnData>[
      ChartColumnData("100", maxVal, scoreCount[5]),
      ChartColumnData("80", maxVal, scoreCount[4]),
      ChartColumnData("60", maxVal, scoreCount[3]),
      ChartColumnData("40", maxVal, scoreCount[2]),
      ChartColumnData("20", maxVal, scoreCount[1]),
      ChartColumnData("0", maxVal, scoreCount[0]),
    ];
    return chartData;
  }

  int _getMaximum(List<int> scoreCount) {
    int maxi = scoreCount.reduce((a, b) => a > b ? a : b);
    return maxi;
  }

  String getIcon(IconData icon) {
    switch (icon) {
      case Icons.thumb_up:
        return 'This is your first attempt';
      case Icons.arrow_upward:
        return '${widget.growth}% increase';
      case Icons.arrow_downward:
        return '${widget.growth}% decrease';
      case Icons.check:
        return 'Similar Performance';
      default:
        return 'Soomething went wrong';
    }
  }

  Color getColor(IconData icon) {
    switch (icon) {
      case Icons.thumb_up:
        return Colors.blueAccent;
      case Icons.arrow_upward:
        return Colors.greenAccent;
      case Icons.arrow_downward:
        return Colors.redAccent;
      case Icons.check:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  List<int> _count() {
    List<int> scoreCount = [0, 0, 0, 0, 0, 0];
    for (int i in widget.scores) {
      if (i >= 0 && i <= 19) {
        scoreCount[0]++;
      } else if (i >= 20 && i <= 39) {
        scoreCount[1]++;
      } else if (i >= 40 && i <= 59) {
        scoreCount[2]++;
      } else if (i >= 60 && i <= 79) {
        scoreCount[3]++;
      } else if (i >= 80 && i <= 99) {
        scoreCount[4]++;
      } else {
        scoreCount[5]++;
      }
    }
    return scoreCount;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.black12,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Score ${widget.currentScore}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(widget.icon, color: getColor(widget.icon)),
                  Text(
                    getIcon(widget.icon),
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: getColor(widget.icon),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  PopupMenuButton(
                    shadowColor: Colors.black38,
                    icon: Icon(Icons.more_vert),
                    onSelected: (value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizHistory(quiz: widget.quiz),
                        ),
                      );
                    },
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'history',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'See Quiz History',
                            style: GoogleFonts.nunito(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text('Personal Best Score: ${widget.bestScore}'),
              Text('Overall Best Score: $maxiScore'),
              SfCartesianChart(
                plotAreaBackgroundColor: Colors.transparent,
                margin: EdgeInsets.symmetric(vertical: 10 * 2),
                borderColor: Colors.transparent,
                borderWidth: 0,
                plotAreaBorderWidth: 0,
                enableSideBySideSeriesPlacement: false,
                primaryXAxis: CategoryAxis(isVisible: false),
                primaryYAxis: NumericAxis(
                  isVisible: true,
                  minimum: 0,
                  maximum: 20,
                  interval: 4,
                ),
                series: <CartesianSeries>[
                  ColumnSeries<ChartColumnData, String>(
                    borderRadius: BorderRadius.circular(20),
                    dataSource: chartData,
                    width: 0.5,
                    color: primaryColor.withAlpha(1),
                    xValueMapper: (ChartColumnData data, _) => data.x,
                    yValueMapper: (ChartColumnData data, _) => data.y,
                  ),
                  ColumnSeries<ChartColumnData, String>(
                    borderRadius: BorderRadius.circular(20),
                    dataSource: chartData,
                    width: 0.5,
                    //color: primaryColor,
                    xValueMapper: (ChartColumnData data, _) => data.x,
                    yValueMapper: (ChartColumnData data, _) => data.y1,
                    pointColorMapper: (ChartColumnData data, _) => widget.currentScore < int.parse(data.x) ? primaryColor : Colors.green,
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      SizedBox(width: 5,),
                      Text("Your Standing"),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      SizedBox(width: 5,),
                      Text("Others Standing"),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Center(
                child: Text(
                  'Vertical bar',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Stay Consistant while competiting to others',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartColumnData {
  ChartColumnData(this.x, this.y, this.y1);
  final String x;
  final int? y;
  final int? y1;
}

/*
final List<ChartColumnData> chartData = <ChartColumnData>[
  ChartColumnData("0", , 5),
  ChartColumnData("20", 20, 15),
  ChartColumnData("40", 20, 10),
  ChartColumnData("60", 20, 8),
  ChartColumnData("80", 20, 19),
  ChartColumnData("100", 20, 6),
];
*/
