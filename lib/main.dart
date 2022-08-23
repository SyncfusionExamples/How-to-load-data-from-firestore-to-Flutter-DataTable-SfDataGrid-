import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'employee.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: defaultFirebaseOptions);
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SfDataGridDemo()));
}

const defaultFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyBWRAAgMpfnnjmqOSXmtU3y0VfTqFcH2ZY',
  authDomain: 'employeedatagrid.firebaseapp.com',
  projectId: 'employeedatagrid',
  storageBucket: 'employeedatagrid.appspot.com',
  messagingSenderId: '485159817284',
  appId: '1:485159817284:web:850510557f1164getDataFromFireStoref52c11',
);

class SfDataGridDemo extends StatefulWidget {
  const SfDataGridDemo({Key? key}) : super(key: key);

  @override
  SfDataGridDemoState createState() => SfDataGridDemoState();
}

class SfDataGridDemoState extends State<SfDataGridDemo> {
  late EmployeeDataSource employeeDataSource;
  List<Employee> employeeData = [];

  final getDataFromFireStore =
      FirebaseFirestore.instance.collection('Employee').snapshots();

  Widget _buildDataGrid() {
    return StreamBuilder(
      stream: getDataFromFireStore,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          if (employeeData.isNotEmpty) {
            // to update the value changed at runtime
            getDataGridRowFromDataBase(DocumentChange<Object?> data) {
              return DataGridRow(cells: [
                DataGridCell<String>(columnName: 'id', value: data.doc['id']),
                DataGridCell<String>(
                    columnName: 'name', value: data.doc['name']),
                DataGridCell<String>(
                    columnName: 'designation', value: data.doc['designation']),
                DataGridCell<String>(
                    columnName: 'salary', value: data.doc['salary'].toString()),
              ]);
            }

            for (var data in snapshot.data!.docChanges) {
              if (data.type == DocumentChangeType.modified) {
                if (data.oldIndex == data.newIndex) {
                  employeeDataSource.dataGridRows[data.oldIndex] =
                      getDataGridRowFromDataBase(data);
                }
                employeeDataSource.updateDataGridSource();
              } else if (data.type == DocumentChangeType.added) {
                employeeDataSource.dataGridRows
                    .add(getDataGridRowFromDataBase(data));
                employeeDataSource.updateDataGridSource();
              } else if (data.type == DocumentChangeType.removed) {
                employeeDataSource.dataGridRows.removeAt(data.oldIndex);
                employeeDataSource.updateDataGridSource();
              }
            }
          } else {
            for (var data in snapshot.data!.docs) {
              employeeData.add(Employee(
                  id: data['id'],
                  name: data['name'],
                  designation: data['designation'],
                  salary: data['salary'].toString()));
            }
            employeeDataSource = EmployeeDataSource(employeeData);
          }

          return SfDataGrid(
            source: employeeDataSource,
            columns: getColumns,
            columnWidthMode: ColumnWidthMode.fill,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syncfusion Flutter Datagrid FireStore Demo'),
      ),
      body: _buildDataGrid(),
    );
  }
}

class EmployeeDataSource extends DataGridSource {
  EmployeeDataSource(this.employeeData) {
    _buildDataRow();
  }

  List<DataGridRow> dataGridRows = [];
  List<Employee> employeeData;

  void _buildDataRow() {
    dataGridRows = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'name', value: e.name),
              DataGridCell<String>(
                  columnName: 'designation', value: e.designation),
              DataGridCell<String>(columnName: 'salary', value: e.salary),
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(
    DataGridRow row,
  ) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }

  void updateDataGridSource() {
    notifyListeners();
  }
}

List<GridColumn> get getColumns {
  return <GridColumn>[
    GridColumn(
        columnName: 'id',
        label: Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.center,
            child: const Text(
              'ID',
            ))),
    GridColumn(
        columnName: 'name',
        label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: const Text('Name'))),
    GridColumn(
        columnName: 'designation',
        label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: const Text(
              'Designation',
              overflow: TextOverflow.ellipsis,
            ))),
    GridColumn(
        columnName: 'salary',
        label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: const Text('Salary'))),
  ];
}
