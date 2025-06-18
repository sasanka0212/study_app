import 'package:flutter/material.dart';

class OptionStyle extends StatefulWidget {
  final String optionNo;
  final String option;
  final Color setColor;
  const OptionStyle({
    super.key,
    required this.optionNo,
    required this.option,
    required this.setColor,
  });

  @override
  State<OptionStyle> createState() => _OptionStyleState();
}

class _OptionStyleState extends State<OptionStyle> {
  Color color = Colors.white;

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
    color = widget.setColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.yellow,
            ),
            child: Text(
              widget.optionNo,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: widget.setColor,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.option,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
