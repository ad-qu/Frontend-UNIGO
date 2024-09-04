// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/components/chat_screen/own_message_card.dart';
import 'package:unigo/components/chat_screen/reply_card.dart';
import 'package:unigo/components/itinerary/itinerary_card.dart';
import 'package:unigo/models/message.dart';

import 'package:unigo/pages/entity/entity_home.dart';

import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String idEntity;

  const ChatScreen({
    super.key,
    required this.idEntity,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isLoading = true;
  ScrollController _scrollController = ScrollController();

  late IO.Socket socket;

  String? _idChat = "";
  List<Messages> listMessage = [];
  final TextEditingController _msgController = TextEditingController();

  String? _idUser = "";
  String? _senderName = "";

  @override
  void initState() {
    _isLoading = true;

    getUserInfo();
    getChat(widget.idEntity);

    super.initState();

    socket = IO.io('http://${dotenv.env['API_URL_SOCKET']}', <String, dynamic>{
      'transports': ['websocket'],
    });
    socket.onConnect((_) {
      print('Conectado al servidor SocketIO');

      //Enviar evento 'join-room' al servidor
      socket.emit('join-room', widget.idEntity);
    });
    socket.on('connected-users', (data) {
      print('Número de usuarios conectados: $data');
    });
    socket.on('message', (data) {
      print('Mensaje recibido: $data');
      if (data['idUser'] != _idUser) {
        if (mounted) {
          setState(() {
            Messages msg = Messages(
                idUser: data['idUser'] ?? '',
                senderName: data['senderName'] ?? '',
                message: data['message'] ?? '');
            listMessage.add(msg);

            // Scroll hasta el final de la lista
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            });
          });
        }
      }
    });
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getString('idUser');
      _senderName = prefs.getString('username');
    });
  }

  Future<void> getChat(String idEntity) async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path = 'http://${dotenv.env['API_URL']}/chat/get/${widget.idEntity}';
    try {
      var response = await Dio().get(
        path,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      final data = response.data;
      String chatId = data['_id'];
      List<dynamic> conversationData = data['conversation'];
      List<Messages> chatMessages = conversationData.map((messageJson) {
        return Messages.fromJson2(messageJson);
      }).toList();

      print('Chat ID: $chatId');
      print('Chat Messages: $chatMessages');

      setState(() {
        listMessage = chatMessages;
        _idChat = chatId;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false; // Cambiamos el estado de carga a falso
      });
    }
  }

  Future<void> sendMessageToDB() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    await Dio().put(
      'http://${dotenv.env['API_URL']}/chat/update/$_idChat',
      data: {
        "idUser": _idUser,
        "senderName": _senderName,
        "message": _msgController.text,
      },
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
    );
  }

  void sendMessageToRoom(String message) {
    Messages myMessage =
        Messages(idUser: _idUser!, senderName: _senderName!, message: message);
    if (socket.connected && mounted) {
      setState(() {
        listMessage.add(myMessage);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
      final data = {
        'room': widget.idEntity,
        'idUser': _idUser,
        'senderName': _senderName,
        'message': message,
      };
      socket.emit('message', data);
    } else {
      // logica de reconexión
      print('socket not connected');
      socket.connect();
      socket.onConnect((_) =>
          // ignore: avoid_print
          {
            print('Reconectado al servidor SocketIO'),
            sendMessageToRoom(message)
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 17.5, 15, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(30)),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                          Text(
                            "Chat",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.transparent,
                              size: 27.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Theme.of(context).hoverColor,
                          strokeCap: StrokeCap.round,
                          strokeWidth: 5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).splashColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              )
            : Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 17.5, 15, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                            ),
                          ),
                          Text(
                            "Chat",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.transparent,
                              size: 27.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: listMessage.isNotEmpty
                          ? ListView.builder(
                              controller: _scrollController,
                              itemCount: listMessage.length,
                              itemBuilder: (context, index) {
                                if (listMessage[index].idUser == _idUser) {
                                  return OwnMessageCard(
                                      msg: listMessage[index].message);
                                } else {
                                  return ReplyCard(
                                      msg: listMessage[index].message,
                                      sender: listMessage[index].senderName);
                                }
                              })
                          : Container(
                              height:
                                  MediaQuery.of(context).size.height / 2 + 160,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'No hay\nmensajes disponibles',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                  color: Theme.of(context)
                                                      .shadowColor),
                                        ),
                                        const SizedBox(height: 16),
                                        Icon(
                                          Icons.message_rounded,
                                          size: 125,
                                          color: Theme.of(context).shadowColor,
                                        ),
                                        const SizedBox(height: 16),
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            style: GoogleFonts.inter(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    'Sé el primero en\nescribir un mensaje',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
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
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _msgController,
                              cursorWidth: 1,
                              maxLength: 12,
                              style: Theme.of(context).textTheme.labelMedium,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                      width: 1),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(25)),
                                ),
                                contentPadding: const EdgeInsets.all(17),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                      width: 1),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(25)),
                                ),
                                labelText: "Escribe un mensaje...",
                                labelStyle: const TextStyle(
                                  color: Color.fromARGB(255, 138, 138, 138),
                                  fontSize: 14,
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                fillColor: Theme.of(context).cardColor,
                                filled: true,
                                counterText: '',
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: () async {
                              if (_msgController.text.isNotEmpty) {
                                try {
                                  await sendMessageToDB();
                                  sendMessageToRoom(_msgController.text);
                                  _msgController.clear();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.red,
                                      content:
                                          Text('Error al enviar el mensaje'),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              width: 52.5,
                              height: 52.5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).splashColor,
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 3.5),
                                  child: Icon(
                                    Icons.send_rounded,
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    size: 24,
                                  ),
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
    );
  }
}
