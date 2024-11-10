import 'package:apex_app/utilities/methods.dart';
import 'package:flutter/material.dart';


class Input extends StatefulWidget{
  final String label;
  final TextEditingController controller;
  final IconData icon;
  const Input ({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
  }) : super(key: key);
  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  bool obscure = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 14,bottom:14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(widget.icon),
            hintText: widget.label,
            hintStyle: TextStyle(
              color:Colors.grey.shade700
            ),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}