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
  bool isAdmin=true;
  final serialNumberController = TextEditingController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? selectedPollingStationId;
  String? pollingStationId;
  bool isDropdownOpen = false;


  late Future<List<String>>? cameraList;
  late Future<List<String>>? pollsList;

  List<String> pollingStationIdList=['Select polling station',''];


  // final apiKey=dotenv.env['API_KEY']!;
  // final apiKey="";

  String apiKey="http://apex-computers.live:2000/";

  // String apiKey="http://192.168.1.15:2000/";

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


  void fetchInfo(){
    fetchPollingStation();
    cameraList=fetchCameras();
    pollsList=fetchPolls();
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
        print('Fetched info successfully: ${response.body}');
        final List<dynamic> responseData = jsonDecode(response.body);



        return responseData.map<String>((data) {
          return ' CID : ${data['serial_number']}, \n \t PS : ${data['polling_station']}';
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
        print('Fetched info successfully: ${response.body}');
        final List<dynamic> responseData = jsonDecode(response.body);



        return responseData.map<String>((data) {
          return ' PS : ${data['polling_station']}, \n \t Taluka : ${data['taluka_name']}  \n \t Address : ${data['polling_address']}';
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
    String? token = await storage.read(key: 'token');

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
        // print('Login successful: ${response.body}');
        final responseData = jsonDecode(response.body);
        // print('admin thing is this value : '+responseData['isAdmin']);

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
    String? token = await storage.read(key: 'token');
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
        showNotification("Camera Registered successfully! ${serialNumberController.text}");
        fetchInfo();
        serialNumberController.clear();
        serialNumberController.text='';
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
    // cameraList=fetchCameras();
    // pollsList=fetchPolls();
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

              centerTitle: true,
              title: Text(bottomNavIndex==0?"Cameras":"Polling Stations"),
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
                    FutureBuilder(
                        future:bottomNavIndex==0? cameraList:pollsList,
                        builder: (context,snapshot){
                          if(snapshot.connectionState==ConnectionState.done){
                            return ListView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context,index){
                                String item = snapshot.data![index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 7),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10,vertical:10),
                                      child: Text('\t$index. $item'),
                                    ),
                                  ),
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
            isAdmin?
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
