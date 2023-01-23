import 'package:flutter/material.dart';

class MultiCheckBox extends StatefulWidget {
  bool isChecked;
  String item;
  Function(bool) onChanged;
  MultiCheckBox({Key key, this.isChecked, this.item, this.onChanged})
      : super(key: key);

  @override
  _MultiCheckBoxState createState() => _MultiCheckBoxState();
}

class _MultiCheckBoxState extends State<MultiCheckBox> {
  bool checked = false;
  @override
  void initState() {
    super.initState();
    if (widget.isChecked != null) {
      checked = widget.isChecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.0),
      child: CheckboxListTile(
        value: checked,
        title: Text(widget.item),
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (value) {
          setState(() {
            checked = value;
          });
          widget.onChanged(checked);
        },
      ),
    );
  }
}
