import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:ea_frontend/models/challenge.dart';
import 'package:ea_frontend/widget/card_widget.dart';

class PanelWidget extends StatefulWidget {
  const PanelWidget({
    Key? key,
    required this.controller,
    required this.panelController,
  }) : super(key: key);

  final ScrollController controller;
  final PanelController panelController;

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  Challenge? challenge;
  List<Challenge> challengeList = <Challenge>[];
  dynamic controller;
  dynamic panelController;

  @override
  void initState() {
    super.initState();
    getSubjects();
  }

  Future getSubjects() async {
    //http://IP_PC:3000/subject/all
    String path = 'http://127.0.0.1:3002/challenge/get/all';
    var response = await Dio().get(path);
    var registros = response.data as List;
    for (var sub in registros) {
      challengeList.add(Challenge.fromJson(sub));
    }
    setState(() {
      challengeList = challengeList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 12),
          buildDragHandle(),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Challenges',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
          const SizedBox(height: 36),
          buildAboutText(),
          const SizedBox(height: 24),
          buildChallenges11(context, challengeList),
        ],
      ),
    );
  }
}

@override
Widget buildChallenges11(BuildContext context, List<Challenge> challengeList) {
  return SizedBox(
    height:
        MediaQuery.of(context).size.height - 100, // ajustar según sea necesario
    child: Viewport(
      axisDirection: AxisDirection.down,
      offset: ViewportOffset.zero(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return MyCard(
                  name: challengeList[index].name,
                  descr: challengeList[index].descr,
                  exp: challengeList[index].exp.toString(),
                );
              },
              childCount: challengeList.length,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildAboutText() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
            'Available challenges',
            style: TextStyle(fontWeight: FontWeight.w600),
          )
        ],
      ),
    );

Widget buildDragHandle() => GestureDetector(
      onTap: togglePanel,
      child: Center(
        child: Container(
          width: 30,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );

void togglePanel() => PanelController().isPanelOpen
    ? PanelController().close()
    : PanelController().open();