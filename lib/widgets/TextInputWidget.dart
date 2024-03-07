import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {

   TextFieldWidget({super.key,this.textController,this.errorMsg,this.labeltext});

   TextEditingController? textController;
   String? errorMsg;
   String? labeltext;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: widget.textController,
        keyboardType: TextInputType.emailAddress,
        validator: (val) =>
        val!.isNotEmpty ? null : widget.errorMsg,
        decoration:  InputDecoration(labelText: widget.labeltext),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium!.color,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ));
  }
}
