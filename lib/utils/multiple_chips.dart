import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'AppColors.dart';

class MultipleChips extends StatefulWidget {
  List<MultiSelectItem<dynamic>> items;
  Function(dynamic) onRemove;
  MultipleChips({Key key, this.items, this.onRemove}) : super(key: key);

  @override
  _MultipleChipsState createState() => _MultipleChipsState();
}

class _MultipleChipsState extends State<MultipleChips> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        children: widget.items != null
            ? widget.items.map((item) => _buildItem(item, context)).toList()
            : <Widget>[
                Container(),
              ],
      ),
    );
  }

  Widget _buildItem(MultiSelectItem<dynamic> item, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          Container(
            child: ChoiceChip(
              // shape: shape as OutlinedBorder?,
              // avatar: icon != null
              //     ? Icon(
              //         icon!.icon,
              //         color: colorator != null && colorator!(item.value) != null
              //             ? colorator!(item.value)!.withOpacity(1)
              //             : icon!.color ?? Theme.of(context).primaryColor,
              //       )
              //     : null,
              label: Container(
            margin: EdgeInsets.only(right: 12),
                // width: chipWidth,
                child: Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              selected: widget.items.contains(item),
              selectedColor: AppColors.appTheame,
              onSelected: (_) {
                // if (onTap != null) onTap!(item.value);
              },
            ),
          ),
          Positioned(
            top: 17,
            right: 7,
            child: GestureDetector(
              onTap: () {
                widget.onRemove(item.value);
              },
              child: Image.asset(
                'assets/images/closed.png',
                height: 13,
                width: 13,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
