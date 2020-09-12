import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_medical/routes/profile.dart';
import 'package:flutter_medical/routes/category.dart';
import 'package:flutter_medical/routes/search.dart';
import 'package:flutter_medical/database.dart';

DocumentSnapshot snapshot;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: null,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}

class GlobalDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Drawer Header'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Item 1'),
            onTap: () {},
          ),
          ListTile(
            title: Text('Item 2'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

/// App Root
class HomeScreen extends StatelessWidget {
  final appTitle = 'Drawer Demo';
  static const String _title = 'Medical App';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              },
            ),
          ],
          // centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0, 0.0),
                end: Alignment(1.0, 0.0),
                colors: [const Color(0xFF6aa6f8), const Color(0xFF1a60be)],
              ),
            ),
          ),
          // title: Text('Title'),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: MyStatelessWidget(),
        drawer: GlobalDrawer(),
      ),
    );
  }
}

class MyStatelessWidget extends StatefulWidget {
  MyStatelessWidget({Key key}) : super(key: key);

  @override
  _MyStatelessWidgetState createState() => _MyStatelessWidgetState();
}

class _MyStatelessWidgetState extends State<MyStatelessWidget> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot doctorSnapshot;
  QuerySnapshot specialtySnapshot;

  getDoctors() async {
    databaseMethods.getAllDoctors().then((val) {
      print(val.toString());
      setState(() {
        doctorSnapshot = val;
        print(doctorSnapshot);
      });
    });
  }

  getSpecialties() async {
    databaseMethods.getAllSpecialties().then((val) {
      print(val.toString());
      setState(() {
        specialtySnapshot = val;
        print(specialtySnapshot);
      });
    });
  }

  @override
  void initState() {
    getDoctors();
    getSpecialties();
  }

  Widget doctorList() {
    return doctorSnapshot != null
        ? Container(
            child: ListView.builder(
                itemCount: doctorSnapshot.docs.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return doctorCard(
                    name: doctorSnapshot.docs[index].data()["name"],
                    specialty: doctorSnapshot.docs[index].data()["specialty"],
                    imagePath: doctorSnapshot.docs[index].data()["imagePath"],
                  );
                }),
          )
        : Container(
            child: Text("error"),
          );
  }

  Widget specialtyList() {
    return specialtySnapshot != null
        ? ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: specialtySnapshot.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return specialtyCard(
                specialtyName:
                    specialtySnapshot.docs[index].data()["specialtyName"],
                specialtyDoctorCount: specialtySnapshot.docs[index]
                    .data()["specialtyDoctorCount"],
                specialtyImagePath:
                    specialtySnapshot.docs[index].data()["specialtyImagePath"],
              );
            })
        : Text("error");
  }

  Material specialtyCard(
      {String specialtyName,
      String specialtyDoctorCount,
      String specialtyImagePath}) {
    return Material(
      color: const Color(0xFFFFFFFF),
      child: Container(
        margin: const EdgeInsets.only(
          left: 20.0,
          right: 0.0,
        ),
        width: 130,
        height: 100,
        child: Card(
          elevation: 3.0,
          child: new InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryPage()),
              );
            },
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            top: 5.0,
                            bottom: 12.5,
                          ),
                          child: Image.network(
                            specialtyImagePath,
                            height: 60,
                            width: 60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      specialtyName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF6f6f6f),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 3.0,
                      ),
                      child: Text(
                        specialtyDoctorCount + ' Doctors',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF9f9f9f),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget doctorCard({String name, String specialty, String imagePath}) {
    return Material(
      color: const Color(0xFFFFFFFF),
      child: Container(
        margin: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          bottom: 10.0,
        ),
        child: Card(
          elevation: 3.0,
          child: new InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(name),
                  ));
            },
            child: Container(
              child: Align(
                alignment: FractionalOffset.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          right: 20.0,
                        ),
                        width: 70.0,
                        height: 70.0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(imagePath),
                        ),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: FractionalOffset.centerLeft,
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF6f6f6f),
                                ),
                              ),
                            ),
                            Align(
                              alignment: FractionalOffset.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: 5.0,
                                ),
                                child: Text(
                                  specialty,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF9f9f9f),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: FractionalOffset.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: 5.0,
                                ),
                                child: Text(
                                  '⭐  ' + "placeholder",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF6f6f6f),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  viewDoctorProfile({String name}) {
    DatabaseMethods().getDoctorProfile(name);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ProfilePage(name)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width * 1.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1.0, 0.0),
            end: Alignment(1.0, 0.0),
            colors: [
              const Color(0xFF6aa6f8),
              const Color(0xFF1a60be)
            ], // whitish to gray
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 15.0,
                left: 20.0,
                right: 20.0,
                bottom: 20.0,
              ),
              child: Row(
                children: [
                  new Container(
                    margin: EdgeInsets.only(
                      right: 30.0,
                    ),
                    width: 70.0,
                    height: 70.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                        fit: BoxFit.fill,
                        image:
                            new NetworkImage("https://i.imgur.com/iQkzaTO.jpg"),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: FractionalOffset.centerLeft,
                          child: Text(
                            'Welcome back, John!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22.25,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                        Align(
                          alignment: FractionalOffset.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 5.0,
                            ),
                            child: Text(
                              'How can we help you today?',
                              style: TextStyle(
                                fontSize: 17,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 40.0,
              ),
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                color: Color(0xFFFFFFFF),
                boxShadow: [
                  new BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20.0,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      transform: Matrix4.translationValues(0.0, -30.0, 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              MaterialButton(
                                splashColor: Colors.white,
                                onPressed: () {},
                                color: Color(0xFF4894e9),
                                textColor: Colors.white,
                                child: Icon(
                                  Icons.phone,
                                  size: 30,
                                ),
                                padding: EdgeInsets.all(16),
                                shape: CircleBorder(),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 10.0,
                                ),
                                child: Text(
                                  'Consultation',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF6f6f6f),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              MaterialButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SearchPage()),
                                  );
                                },
                                color: Color(0xFF4894e9),
                                highlightColor: Color(0xFFFFFFFF),
                                textColor: Colors.white,
                                child: Icon(
                                  Icons.people,
                                  size: 30,
                                ),
                                padding: EdgeInsets.all(16),
                                shape: CircleBorder(),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 10.0,
                                ),
                                child: Text(
                                  'Doctor Lookup',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF6f6f6f),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              MaterialButton(
                                onPressed: () {},
                                color: Color(0xFF4894e9),
                                highlightColor: Color(0xFFFFFFFF),
                                textColor: Colors.white,
                                child: Icon(
                                  Icons.toc,
                                  size: 30,
                                ),
                                padding: EdgeInsets.all(16),
                                shape: CircleBorder(),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 10.0,
                                ),
                                child: Text(
                                  'Resources',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF6f6f6f),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 10.0,
                      left: 20.0,
                      right: 15.0,
                      bottom: 15.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Specialties',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color(0xFF6f6f6f),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 20.0,
                      right: 15.0,
                      bottom: 15.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.',
                        style: TextStyle(
                          color: Color(0xFF9f9f9f),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: const Color(0xFFFFFFFF),
                    height: 160,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        specialtyList(),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 30.0,
                      left: 20.0,
                      right: 15.0,
                      bottom: 15.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Our Top Doctors',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color(0xFF6f6f6f),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 20.0,
                      right: 15.0,
                      bottom: 15.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.',
                        style: TextStyle(
                          color: Color(0xFF9f9f9f),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: const Color(0xFFFFFFFF),
                    child: Column(
                      children: <Widget>[
                        doctorSnapshot != null
                            ? Container(
                                child: ListView.builder(
                                    itemCount: doctorSnapshot.docs.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return doctorCard(
                                        name: doctorSnapshot.docs[index]
                                            .data()["name"],
                                        specialty: doctorSnapshot.docs[index]
                                            .data()["specialty"],
                                        imagePath: doctorSnapshot.docs[index]
                                            .data()["imagePath"],
                                      );
                                    }),
                              )
                            : Container(
                                child: Text("error"),
                              ),
                        Container(
                          margin: const EdgeInsets.only(
                            left: 20.0,
                            right: 20.0,
                            bottom: 20.0,
                          ),
                          child: new OutlineButton(
                            color: Colors.transparent,
                            splashColor: Color(0xFF4894e9),
                            padding: EdgeInsets.all(10),
                            onPressed: () {
                              getDoctors();
                              print('View All Doctors Clicked');
                            },
                            textColor: Color(0xFF4894e9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'View More',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
