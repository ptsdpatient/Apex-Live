import 'dart:convert';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import '../token.dart';
import '../utilities/button.dart';
import '../utilities/methods.dart';
import 'package:http/http.dart' as http;



class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}


class _UserPageState extends State<UserPage> {
  var bottomNavIndex = 0;
  bool isProcessing = false;
  XFile? capturedImage;
  String? decodedQRCode;
  bool isAdmin=false;
  final serialNumberController = TextEditingController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? selectedPollingStationId;
  String? pollingStationId;
  bool isDropdownOpen = false;
  List<String> pollingStationIdList=['Select polling station',''];





  // final apiKey=dotenv.env['API_KEY']!;
  // final apiKey="";

  String apiKey="http://localhost:2000/";

  void fetchInfo(){
    fetchPollingStation();
  }

  Future<void> fetchPollingStation() async{
    String? token = await storage.read(key: 'authToken');

    final url = Uri.parse('${apiKey}getPollingStation');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Fetched info successfully: ${response.body}');
        final List<dynamic> responseData = jsonDecode(response.body);

        setState(() {
          pollingStationIdList = responseData.map((data) {
            return data['polling_station'] as String;
          }).toList();
        });

      } else {
        print('Fetch failed: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  Future<void> authenticateToken() async {
    String? token = await storage.read(key: 'authToken');

    final url = Uri.parse('${apiKey}getPollingStation');

    try {
      if (token==null){
        Navigator.pushNamed(context, '/login');
      }
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Login successful: ${response.body}');
        final responseData = jsonDecode(response.body);
        print('admin thing is this value : '+responseData['isAdmin']);

        setState(() {
          isAdmin = responseData['isAdmin'] == true || responseData['isAdmin'] == 'true';
        });



        print('admin is $isAdmin');

      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
        removeToken();
        Navigator.pushNamed(context, '/login');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }







  Future<void> registerCamera(modelNumber,pollingStation) async{
    String? token = await storage.read(key: 'authToken');

    final url = Uri.parse('${apiKey}registerCamera');
    final body = jsonEncode({
      'number': modelNumber,
      'poll_station': pollingStation,
    });

    try {
      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },body:body
      );

      if (response.statusCode == 200) {
        print('Registered camera successfully: ${response.body}');


      } else {
        print('Fetch failed: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authenticateToken();
    fetchInfo();
    _requestCameraPermission();

  }

  Future<void> _requestCameraPermission() async {
    if (await Permission.camera.request().isGranted) {
      // Camera permission granted
    } else {
      // Handle the case where the permission is denied
      print('Camera permission denied');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: CustomScrollView(

          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 20,
              automaticallyImplyLeading: false,
              floating: true,
              pinned:false,
              centerTitle: true,
              title: Text("Apex-Live : $isAdmin"),
            ),

          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton:
            isAdmin?
            FloatingActionButton.large(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled:true,
                    enableDrag: true, // Set to true if you want drag functionality
                    builder: (BuildContext context){
                      return
                        ClipRRect(
                          child: SizedBox(
                            height:getHeight(context)*0.8,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Scaffold(
                                backgroundColor: Colors.grey.shade100,
                                body: CustomScrollView(
                                  shrinkWrap: false,
                                  physics:  const BouncingScrollPhysics(),
                                  scrollBehavior: const ScrollBehavior(),
                                  slivers: [
                                    const SliverAppBar(
                                      pinned:false,
                                      floating: true,
                                      title: Text("Register Camera"),
                                      automaticallyImplyLeading: false,
                                      centerTitle: true,
                                    ),
                                    SliverToBoxAdapter(
                                        child: SizedBox(
                                          height: getHeight(context)*1.5,
                                          child: Column(
                                            children: [

                                              const Row(
                                                children: [
                                                  Padding(
                                                    padding:EdgeInsets.only(left: 35,top: 30),
                                                    child: Text("Polling Station : "),
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding:const EdgeInsets.only(left: 25,right:25,bottom: 20,top:15),
                                                child:
                                                CustomDropdown<String>.search(
                                                  overlayHeight: 400,
                                                  hintText: 'Select Polling Staiton',
                                                  items: pollingStationIdList,
                                                  excludeSelected: false,
                                                  onChanged: (value) {
                                                      setState(() {
                                                        pollingStationId=value;
                                                      });
                                                  },
                                                )
                                              ),

                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: SizedBox(
                                                  height: getHeight(context)*0.4,
                                                  width: getWidth(context)*0.8,
                                                  child: Flex(
                                                    direction: Axis.vertical,
                                                    children: [
                                                      Expanded(
                                                        child: MobileScanner(
                                                          onDetect: (BarcodeCapture barcodeCapture) {
                                                            final String? code = barcodeCapture.barcodes.first.rawValue;
                                                            if (code != null) {
                                                              setState(() {
                                                                serialNumberController.text=code;
                                                              });
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 24, right: 24, top: 30,bottom:30),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: TextField(
                                                    controller: serialNumberController,
                                                    decoration: const InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      prefixIcon: Icon(Icons.numbers_rounded),
                                                      hintText: "Model Number",
                                                      border: InputBorder.none,
                                                    ),
                                                    style: const TextStyle(color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                    )
                                  ],
                                ),
                                floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                                floatingActionButton: FloatingActionButton.large(
                                  onPressed: (){
                                    registerCamera(serialNumberController.text,pollingStationId);
                                  },
                                  backgroundColor: Colors.blue,
                                  child: const Icon(Icons.send_rounded, size: 45, color: Colors.white),
                                ),

                              ),
                            ),
                          ),
                        );
                    });
              },
              child:const Icon(Icons.add_a_photo,size:45),
            ):Container(),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 20,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          currentIndex: bottomNavIndex,
          selectedFontSize: 15,
          unselectedIconTheme: const IconThemeData(
            color:Colors.black45
          ),
          // backgroundColor: Colors.white,
          selectedIconTheme: const IconThemeData(
            color:Colors.blue,
          ),
          fixedColor: Colors.blue,
          items: const [
            BottomNavigationBarItem(
              // backgroundColor: Colors.green,
              icon: Icon(
                  Icons.video_camera_back_rounded,
                  size:35
              ),
              label: "Camera",
              activeIcon: Icon(
                  Icons.video_camera_back_rounded,
                  size:40

              ),
            ),

            BottomNavigationBarItem(
              // backgroundColor: Colors.yellow,
              icon: Icon(
                  Icons.how_to_vote_rounded,
                  size:35
              ),
              label: "Polling Station",
              activeIcon: Icon(
                  Icons.how_to_vote_rounded,
                  size:40

              ),
            ),
            BottomNavigationBarItem(
              // backgroundColor: Colors.purpleAccent,
              icon: Icon(
                  Icons.person,
                  size:35
              ),
              label: "Employees",
              activeIcon: Icon(
                  Icons.person,
                  size:40
              ),
            ),

            BottomNavigationBarItem(
              // backgroundColor: Colors.red,
              icon: Icon(
                  Icons.location_on_rounded,
                  size:35
              ),
              label: "Taluka",
              activeIcon: Icon(
                  Icons.location_on_rounded,
                  size:40

              ),
            ),
          ],
          onTap: (int pos){
            setState(() {
              bottomNavIndex=pos;
            });
          },
        )
    );
  }
}
