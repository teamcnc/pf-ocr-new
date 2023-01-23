import 'package:flutter/material.dart';
import 'package:ocr/home/purchase/model/purchase.dart';
import 'package:ocr/utils/AppColors.dart';

class SortFilters extends StatefulWidget {
  List<Purchase> purchaseList;
  Function(List<Purchase> sortedList, String sortedBy, String sortOrder)
      onSorted;
  String sortBy, sortOrder;
  SortFilters(
      {Key key, this.purchaseList, this.onSorted, this.sortBy, this.sortOrder})
      : super(key: key);

  @override
  _SortFiltersState createState() => _SortFiltersState();
}

class _SortFiltersState extends State<SortFilters> {
  List<String> sortingoptionsList = [
    'Date',
    'Document',
    'Document Number',
    'Vendor Ref. No.',
    'Vendor Code',
    'Vendor Name',
    'Buyer',
    'Transporter',
    'Packages'
  ];
  List<String> orderList = ['Assending', 'Desending'];

  String _selectedOption = 'Date', _selectedOrder = 'Desending';

  List<Purchase> sortedList = [];

  @override
  void initState() {
    super.initState();
    // if (widget.purchaseList != null) sortedList = widget.purchaseList;
    if (widget.sortBy != null) _selectedOption = widget.sortBy;
    if (widget.sortOrder != null) _selectedOrder = widget.sortOrder;
    Future.delayed(Duration(milliseconds: 30), () {
      // sortListItems(_selectedOption);
      if (this.mounted)
        setState(() {
          // widget.onSorted(sortedList, _selectedOption, _selectedOrder);
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "SORT BY",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appTheame,
                    ),
                    // color: AppColors.appTheame,
                    onPressed: () {
                      setState(() {
                        _selectedOption = 'Date';
                        _selectedOrder = 'Desending';
                        // sortedList = widget.purchaseList;
                        // sortListItems(_selectedOption);
                        if (this.mounted)
                          widget.onSorted(
                              sortedList, _selectedOption, _selectedOrder);
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      "CLEAR",
                      style: TextStyle(color: Colors.white),
                    )),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appTheame,
                    ),
                    // color: AppColors.appTheame,
                    onPressed: () {
                      if (this.mounted)
                        setState(() {
                          widget.onSorted(
                              sortedList, _selectedOption, _selectedOrder);
                        });
                      Navigator.pop(context);
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      // mainAxisAlignment:
                      //     MainAxisAlignment.spaceBetween,
                      children: [
                        Text(orderList[0]),
                        Radio(
                          value: orderList[0],
                          groupValue: _selectedOrder,
                          onChanged: (value) {
                            setState(() {
                              _selectedOrder = value;
                              // sortListItems(_selectedOption);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      // mainAxisAlignment:
                      //     MainAxisAlignment.spaceBetween,
                      children: [
                        Text(orderList[1]),
                        Radio(
                          value: orderList[1],
                          groupValue: _selectedOrder,
                          onChanged: (value) {
                            setState(() {
                              _selectedOrder = value;
                              // sortListItems(_selectedOption);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sortingoptionsList.length,
                  itemBuilder: (listContext, index) {
                    return Container(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(sortingoptionsList[index]),
                              Radio(
                                value: sortingoptionsList[index],
                                groupValue: _selectedOption,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOption = value;
                                    // sortListItems(_selectedOption);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ));
  }

  sortListItems(String selected) {
    if (selected == 'Date') {
      for (int i = 0; i < sortedList.length; i++) {
        int i, j;
        for (i = 0; i < sortedList.length - 1; i++)

          // Last i elements are already in place
          for (j = 0; j < sortedList.length - i - 1; j++)
            if (_selectedOrder == 'Assending') {
              if (sortedList[j].dateTime.isAfter(sortedList[j + 1].dateTime))
                swapItems(j, j + 1);
            } else if (sortedList[j]
                .dateTime
                .isBefore(sortedList[j + 1].dateTime)) swapItems(j, j + 1);
      }
    } else if (selected == 'Document') {
      if (_selectedOrder == 'Assending')
        sortedList.sort((first, second) {
          return first.document.compareTo(second.document);
        });
      else {
        List<Purchase> temp = sortedList;
        sortedList = [];
        temp.sort((first, second) {
          return first.document.compareTo(second.document);
        });
        temp.reversed.forEach((element) {
          sortedList.add(element);
        });
      }
    } else if (selected == 'Document Number') {
      if (_selectedOrder == 'Assending')
        sortedList.sort((first, second) {
          return first.docNum.compareTo(second.docNum);
        });
      else {
        List<Purchase> temp = sortedList;
        sortedList = [];
        temp.sort((first, second) {
          return first.docNum.compareTo(second.docNum);
        });
        temp.reversed.forEach((element) {
          sortedList.add(element);
        });
      }
    } else if (selected == 'Vendor Ref. No.') {
      if (_selectedOrder == 'Assending')
        sortedList.sort((first, second) {
          return first.vendorRefNo.compareTo(second.vendorRefNo);
        });
      else {
        List<Purchase> temp = sortedList;
        sortedList = [];
        temp.sort((first, second) {
          return first.vendorRefNo.compareTo(second.vendorRefNo);
        });
        temp.reversed.forEach((element) {
          sortedList.add(element);
        });
      }
    } else if (selected == 'Vendor Code') {
      if (_selectedOrder == 'Assending')
        sortedList.sort((first, second) {
          return first.vendorCode.compareTo(second.vendorCode);
        });
      else {
        List<Purchase> temp = sortedList;
        sortedList = [];
        temp.sort((first, second) {
          return first.vendorCode.compareTo(second.vendorCode);
        });
        temp.reversed.forEach((element) {
          sortedList.add(element);
        });
      }
    } else if (selected == 'Vendor Name') {
      if (_selectedOrder == 'Assending')
        sortedList.sort((first, second) {
          return first.vendorName.compareTo(second.vendorName);
        });
      else {
        List<Purchase> temp = sortedList;
        sortedList = [];
        temp.sort((first, second) {
          return first.vendorName.compareTo(second.vendorName);
        });
        temp.reversed.forEach((element) {
          sortedList.add(element);
        });
      }
    } else if (selected == 'Buyer') {
      if (_selectedOrder == 'Assending')
        sortedList.sort((first, second) {
          return first.buyer.compareTo(second.buyer);
        });
      else {
        List<Purchase> temp = sortedList;
        sortedList = [];
        temp.sort((first, second) {
          return first.buyer.compareTo(second.buyer);
        });
        temp.reversed.forEach((element) {
          sortedList.add(element);
        });
      }
    } else if (selected == 'Transporter') {
      if (_selectedOrder == 'Assending')
        sortedList.sort((first, second) {
          return first.transporter.compareTo(second.transporter);
        });
      else {
        List<Purchase> temp = sortedList;
        sortedList = [];
        temp.sort((first, second) {
          return first.transporter.compareTo(second.transporter);
        });
        temp.reversed.forEach((element) {
          sortedList.add(element);
        });
      }
    } else if (selected == 'Packages') {
      if (_selectedOrder == 'Assending')
        sortedList.sort((first, second) {
          return first.packages.compareTo(second.packages);
        });
      else {
        List<Purchase> temp = sortedList;
        sortedList = [];
        temp.sort((first, second) {
          return first.packages.compareTo(second.packages);
        });
        temp.reversed.forEach((element) {
          sortedList.add(element);
        });
      }
    }
  }

  swapItems(int first, int second) {
    var temp = widget.purchaseList[first];
    sortedList[first] = sortedList[second];
    sortedList[second] = temp;
  }
}
