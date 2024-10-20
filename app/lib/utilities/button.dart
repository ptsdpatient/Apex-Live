import 'package:flutter/material.dart';



Widget Button(BuildContext context,double w,String label,Future<void> Function() onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
        padding: const EdgeInsets.symmetric(vertical:23),
        child: Container(
          width: w,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(17),
          ),  child:Padding(padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(label,style: const TextStyle(color:Colors.white,fontSize: 17),textAlign: TextAlign.center,),
              ],
            )
        ),
        )
    ),
  );
}