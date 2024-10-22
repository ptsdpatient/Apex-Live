import 'dart:convert';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import '../token.dart';
import '../utilities/button.dart';
import '../utilities/input.dart';
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
  var serialNumberController = TextEditingController();
  var searchController = TextEditingController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? selectedPollingStationId,selectedOperator;
  String? pollingStationId;
  String? username= 'Null';

  late Future<List<String>>? cameraList;
  late Future<List<String>>? pollsList;
  late Future<List<String>>? assignmentList;

  late List<String> cameraData=[],pollsData=[],assignmentData=[];
  late List<String> filteredCameraList=[],filteredPollsList=[];

  List<String> pollingStationIdList=['Select polling station',''],operatorList=['Select Operator'];


  // final apiKey=dotenv.env['API_KEY']!;
  // final apiKey="";

  // String apiKey="http://117.248.105.198:2000/api/";

  String apiKey="https://apex-computers.live/api/";

  void showNotification(String message){
    CherryToast.success(
        iconWidget: Icon(Icons.done_outlined,color:Colors.green,size:45),
        // displayIcon: false,
        backgroundColor: Colors.white,
        displayCloseButton: false,
        animationType: AnimationType.fromTop,
        animationCurve: Curves.easeInOutCirc,
        toastDuration: Duration(milliseconds: 1750),

        toastPosition: Position.top,
        description: Text(message,style: TextStyle(color:Colors.black),),

        title:  Text("Success!",
            style: TextStyle(color: Colors.black))

    ).show(context);
  }


  void fetchInfo () {
    fetchPollingStation();
    fetchOperators();
    setState(() {
      cameraList= fetchCameras();
      pollsList=fetchPolls();
      assignmentList=fetchAssignments();
      bottomNavIndex=bottomNavIndex;
    });
  }


  Future<List<String>> fetchAssignments() async{
    String? token = await storage.read(key: 'token');
    String? name = await storage.read(key: 'username');
    setState(() {
      username=name;
    });
    final body = jsonEncode({
      'operator':name
    });

    final url = Uri.parse('${apiKey}myCameraList');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body:body
      );

      if (response.statusCode == 200) {
        // print('Fetched info successfully: ${response.body}');
        final List<dynamic> responseData = jsonDecode(response.body);

        return responseData.map<String>((data) {
          return ' CID : ${data['serial_number']}, \n \t PS : ${data['polling_station_name']}, \n \t AC : ${data['ac_name']}, \n \t  Supervisor : ${data['supervisor_name']}, \n \t Operator : ${data['operator_name']}';
        }).toList();


      } else {
        print('Fetch failed: ${response.statusCode} - ${response.body}');

        return [];
      }
    } catch (error) {
      print('Error occurred: $error');

      return [];

    }
  }


  Future<List<String>> fetchCameras() async{
    String? token = await storage.read(key: 'token');

    final url = Uri.parse('${apiKey}getCameras');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // print('Fetched info successfully: ${response.body}');
        final List<dynamic> responseData = jsonDecode(response.body);

        return responseData.map<String>((data) {
          return ' CID : ${data['serial_number']}, \n \t PS : ${data['polling_station_name']}, \n \t AC : ${data['ac_name']}, \n \t OP : ${data['operator_name']}';
        }).toList();


      } else {
        print('Fetch failed: ${response.statusCode} - ${response.body}');

        return [];
      }
    } catch (error) {
      print('Error occurred: $error');

      return [];

    }
  }


  Future<List<String>> fetchPolls() async{
    String? token = await storage.read(key: 'token');

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
        // print('Fetched info successfully: ${response.body}');
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map<String>((data) {
          return ' PS : ${data['polling_station_name']}, \n \t Supervisor : ${data['supervisor_name']}, \n \t Phone : ${data['supervisor_phone']},  \n \t Address : ${data['polling_address']}';
        }).toList();


      } else {
        print('Fetch failed: ${response.statusCode} - ${response.body}');

        return [];
      }
    } catch (error) {
      print('Error occurred: $error');

      return [];

    }
  }


  Future<void> fetchOperators() async{
    String? token = await storage.read(key: 'token');

    final url = Uri.parse('${apiKey}getEmployees');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // print('Fetched info successfully: ${response.body}');
        final List<dynamic> responseData = jsonDecode(response.body);

        setState(() {
          operatorList = responseData.map((data) {
            return '${data['id']}. ${data['full_name']}';
          }).toList();
        });


      } else {
        print('Fetch failed: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  Future<void> fetchPollingStation() async{
    String? token = await storage.read(key: 'token');

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
        // print('Fetched info successfully: ${response.body}');
        final List<dynamic> responseData = jsonDecode(response.body);

        setState(() {
          pollingStationIdList = responseData.map((data) {
            return 'PS : ${data['polling_station_id']} ${data['polling_station_name']}';
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
    String? token = await storage.read(key: 'token');

    final url = Uri.parse('${apiKey}authenticateToken');

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
        // print('Login successful: ${response.body}');
        // final responseData = jsonDecode(response.body);
        // setState(() {
        //   username= responseData['name'];
        // });

      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
        removeToken();
        Navigator.pushNamed(context, '/login');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }



  Future<void> registerCamera(modelNumber,pollingStation,operator) async{

    // print('$modelNumber,$pollingStation,$operator');

    String? token = await storage.read(key: 'token');
    final url = Uri.parse('${apiKey}registerCamera');


    final body = jsonEncode({
      'number': modelNumber,
      'poll_station': pollingStation,
      'operator':operator
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
        showNotification("Camera Registered successfully! ${serialNumberController.text}");

        fetchInfo();

        setState(() {
          serialNumberController.clear();
          serialNumberController.text='';
        });

      } else {
        print('Fetch failed: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }


  void filterCamera(String query) {
    List<String> tempList = [];
    if (query.isNotEmpty) {
      tempList = cameraData
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      tempList = List.from(cameraData);
    }
    setState(() {
      filteredCameraList = tempList;
    });
  }

  void filterPollingStation(String query) {
    List<String> tempList = [];
    if (query.isNotEmpty) {
      tempList = pollsData
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      tempList = List.from(pollsData);
    }
    setState(() {
      filteredPollsList = tempList;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authenticateToken();
    // cameraList=fetchCameras();
    // pollsList=fetchPolls();
    _requestCameraPermission();
    fetchInfo();
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
              leading: IconButton(
                  onPressed: (){
                    Navigator.pushNamed(context, '/login');
                    removeToken();
                    },
                  icon: Padding(
                    padding: EdgeInsets.only(left:15),
                    child: Icon(Icons.logout_rounded,size:35,color:Colors.blue),
                  )
              ),
              floating: true,
              pinned:false,

              centerTitle: false,
              title: Text('$username'),
              actions: [
                IconButton(
                    onPressed: (){
                      fetchInfo();
                      showNotification("Information Fetched");
                    },
                    icon: Padding(
                      padding: EdgeInsets.only(right:15),
                      child: Icon(Icons.refresh_rounded,size:35,color:Colors.blue),
                    )
                )
              ],
            ),
            SliverToBoxAdapter(
              child:Column(
                children: [
                    bottomNavIndex==0?Container():
                  Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 14),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: TextField(
                          onChanged: (value){
                            bottomNavIndex==1?filterCamera(value):filterPollingStation(value);
                          },
                          controller: searchController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.search_rounded,size:35,color:Colors.blue),
                            hintText: "Search ${bottomNavIndex==1?"Cameras":"Polls"}",
                            hintStyle: TextStyle(
                                color:Colors.grey.shade700
                            ),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    FutureBuilder(
                        future:bottomNavIndex==1? cameraList:bottomNavIndex==2?pollsList:assignmentList,
                        builder: (context,snapshot){
                          if(snapshot.connectionState==ConnectionState.done){

                            if (bottomNavIndex == 1 ) {
                              cameraData = snapshot.data!;
                              filteredCameraList = List.from(cameraData);
                            } else if (bottomNavIndex == 2) {
                              pollsData = snapshot.data!;
                              filteredPollsList = List.from(pollsData);
                            } else{
                              assignmentData = snapshot.data!;
                            }
                            List<String> data = (bottomNavIndex == 1) ? filteredCameraList : bottomNavIndex==2? filteredPollsList:assignmentData;
                            return ListView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: data.length,
                                itemBuilder: (context,index){
                                String item = data[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                                  child: GestureDetector(
                                    onTap: (){
                                        if(bottomNavIndex==2) return;
                                        RegExp regExp = RegExp(r'CID : (.+?),');
                                        Match? match = regExp.firstMatch(item);

                                        if (match != null) {
                                          String serialNumber = match.group(1)!.trim();
                                          String hlsUrl = 'https://apex-computers.live/hls/$serialNumber.m3u8';
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                            return ClipRRect(
                                              borderRadius: BorderRadius.circular(25),
                                              child: Scaffold(
                                                backgroundColor: Colors.white,
                                                appBar: AppBar(
                                                  backgroundColor: Colors.blue,
                                                  foregroundColor: Colors.white,
                                                  title: Text('CID : $serialNumber'),
                                                  automaticallyImplyLeading: false,
                                                ),
                                                body: HlsStreamPlayer(url: hlsUrl),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10,vertical:10),
                                        child: Text('\t${index+1}. $item',style: TextStyle(color:Colors.black),),

                                      ),
                                    ),
                                  )
                                );
                            });
                          }else{
                            return Padding(padding: EdgeInsets.symmetric(vertical: 40),
                              child: CircularProgressIndicator(

                              ),
                            );
                          }

                        }
                    )
                ],
              )
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton:
            FloatingActionButton.large(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              onPressed: () {
                serialNumberController.clear();
                serialNumberController.text='';
                showModalBottomSheet(
                    context: context,
                    isScrollControlled:true,
                    enableDrag: true, // Set to true if you want drag functionality
                    builder: (BuildContext context){
                      return
                        ClipRRect(
                          child: SizedBox(
                            height:getHeight(context)*0.9,
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
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
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
                                                    padding:EdgeInsets.only(left: 35,top: 25),
                                                    child: Text("Polling Station : "),
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding:const EdgeInsets.only(left: 25,right:25,bottom: 30,top:5),
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
                                    
                                    registerCamera(serialNumberController.text,pollingStationId?.replaceFirst(RegExp(r'PS : \d+ '), '').trim(),username);
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
            ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 20,
          backgroundColor: Colors.white,
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
                  Icons.assignment_rounded,
                  size:35
              ),
              label: "Alloted",
              activeIcon: Icon(
                  Icons.assignment_rounded,
                  size:40

              ),
            ),
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
              // backgroundColor: Colors.red,
              icon: Icon(
                  Icons.how_to_vote_rounded,
                  size:35
              ),
              label: "Polling",
              activeIcon: Icon(
                  Icons.how_to_vote_rounded,
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


class HlsStreamPlayer extends StatefulWidget {
  final String url;

  HlsStreamPlayer({required this.url});

  @override
  _HlsStreamPlayerState createState() => _HlsStreamPlayerState();
}

class _HlsStreamPlayerState extends State<HlsStreamPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: _controller.value.isInitialized
          ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}