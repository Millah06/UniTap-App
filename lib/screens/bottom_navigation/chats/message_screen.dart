import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everywhere/screens/bottom_navigation/chats/shortcut_actions.dart';
import 'package:everywhere/services/message_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../components/confirmation_page.dart';
import '../../../components/dash_line.dart';
import '../../../components/formatters.dart';
import '../../../components/notice_banner.dart';
import '../../../components/service_fraame.dart';
import '../../../components/textInput_formater.dart';
import '../../../constraints/constants.dart';
import '../../../constraints/formatters.dart';
import '../../../services/brain.dart';
import '../../../services/purchase_service.dart';
import '../../../services/transaction_service.dart';


class Peer2PeerChat extends StatefulWidget {


  final String roomId;
  final String otherUid;
  final String otherUserName;
  final String currentUserUid;

  const Peer2PeerChat({super.key, required this.otherUid, required this.roomId, required this.otherUserName, required this.currentUserUid});


  @override
  State<Peer2PeerChat> createState() => _Peer2PeerChatState();
}

class _Peer2PeerChatState extends State<Peer2PeerChat> {
  final messageTextController = TextEditingController();


  String messageText = '';
  bool hasTouched = false;

  final FocusNode _focusNode =  FocusNode();

  final MessageService _messageService = MessageService();

  @override
  Widget build(BuildContext context) {
    final pov = Provider.of<Brain>(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Color(0xFF177E85),
            child: ListTile(
              leading:  Padding(
                  padding: EdgeInsets.all(0),
                  child: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white, size: 25,),
                        SizedBox(width: 7,),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color:  Color(0xFFE3E3E3),
                                  width: 1
                              )
                          ),
                          child: ClipOval(
                              child:   pov.isLoading ? CircularProgressIndicator() :
                              Image.file(File(pov.image), fit: BoxFit.cover,)
                          ),
                        ),
                      ],
                    ),
                  )
              ),
              title: Text(widget.otherUserName,
                style: GoogleFonts.raleway(color: Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 18),),
              subtitle: Text('Almost Impossible', style: TextStyle(color: Colors.white),),
              trailing: Transform.scale(
                scale: 0.8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      hasTouched = !hasTouched;
                    });
                  },
                  child: Icon(
                    FontAwesomeIcons.plusCircle,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
              contentPadding: EdgeInsets.only(top: 25, left: 15, right: 15),
            ),
          ),
          MessagesStream(otherUserId: widget.otherUid, roomId: widget.roomId, currentUserId: pov.currentUser,),
          Container(
            decoration: BoxDecoration(
              color:  Color(0xFF1E293B),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(32),
                topLeft: Radius.circular(32)
              ),
            ),
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
            child: Column(
              children: [
                Container(
                  decoration: kMessageContainerDecoration,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      GestureDetector(
                          onTap: ()  {
                          // showModalBottomSheet(context: context, builder: (context) => EmojiPicker( ))
                        setState(() {
                          hasTouched = !hasTouched;
                        });
                      },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                            child: Icon(FontAwesomeIcons.faceSmileBeam, color: Colors.white, size: 25,
                                                  ),
                          )),
                      Expanded(
                        child: TextFormField(
                          controller: messageTextController,
                          focusNode: _focusNode,
                          onChanged: (value) {
                            setState(() {
                              messageText = value;
                            });
                          },
                          decoration: kMessageTextFieldDecoration,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          cursorColor: Colors.white,
                          onTap: () {
                            if (hasTouched == false) {
                              setState(() {
                                hasTouched = true;
                              });
                            }
                          },
                          maxLines: 5,
                          minLines: 1,
                        ),
                      ),
                      hasTouched ? GestureDetector(
                          onTap: ()  {
                        setState(() {
                          hasTouched = !hasTouched;
                        });
                      }, child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                        child: Icon(
                          FontAwesomeIcons.plusCircle,
                          color: Colors.white,
                          size: 28,
                        ),
                      )) : GestureDetector(
                        onTap: () {
                        FocusScope.of(context).requestFocus(_focusNode);
                       setState(() {
                         hasTouched = !hasTouched;
                       });
                      }, child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                        child: Icon(FontAwesomeIcons.keyboard, size: 28,),
                      ),),
                      Visibility(
                          visible: messageText.isNotEmpty,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10,  bottom: 10, right: 3, left: 10),
                            child: GestureDetector(
                                onTap: () async {
                                  messageTextController.clear();
                                  await _messageService.sendTextMessage(
                                      roomId: widget.roomId,
                                      senderId:  pov.currentUser,
                                      text: messageText, receiverId: widget.otherUid
                                  );
                                  if (mounted) {
                                    setState(() {
                                      messageText = '';
                                    });
                                  }

                                },
                                child: Icon(Icons.send, size: 30,)),
                          )
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: !hasTouched,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ...List.generate(4, (index) {
                            Map<String, IconData> cardDetails = {
                              'Send Airtime' : FontAwesomeIcons.simCard,
                              'Send AirtimeGift' : FontAwesomeIcons.gift,
                              'Transfer Money' : FontAwesomeIcons.moneyBillTransfer,
                              'Emoji' : FontAwesomeIcons.faceSmileBeam
                            };
                            return ServiceFrame(
                              title: cardDetails.keys.elementAt(index),
                              icon: cardDetails.values.elementAt(index),
                              onTap: () {
                                // Ensure the chat TextField does not gain focus or move up
                                FocusScope.of(context).unfocus();
                                  showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder:  (context)  {
                                    return ShortCutAction(roomId: widget.roomId, shortcutName: cardDetails.keys.elementAt(index), otherUserId: widget.otherUid,);
                                  });
                              },
                              isNew: false,
                            );
                          })
                        ],
                      ),
                    ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({
    super.key,
    required this.otherUserId,
    required this.roomId,
    required this.currentUserId,
  });

  final String otherUserId;
  final String roomId;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: MessageService().messageStream(roomId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Expanded(
            child: Center(
              child: Text(
                'Say hi and start the conversation 👋',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
          );
        }

        final List<Widget> items = [];

        // We are using a descending query (newest -> oldest) and ListView(reverse: true)
        // to keep the latest message near the keyboard (WhatsApp-style).
        // For date separators: add the separator AFTER the last message of that day
        // (so it doesn't get stuck at the very bottom).
        for (int i = 0; i < docs.length; i++) {
          final  doc = docs[i];

          final Timestamp ts =
              (doc['createdAt'] ?? doc['localCreatedAt'] ?? Timestamp.now())
                  as Timestamp;
          final date = ts.toDate();
          final dayKey = DateTime(date.year, date.month, date.day);

          items.add(
            MessageBubble(
             doc['type'] == 'moneyTransfer' ? doc['amount'] : "",
              messageId: doc.id,
              text: doc['text'],
              isMe: doc['senderId'] == currentUserId,
              time: Formatters()
                  .formatTimeInMessages(doc['createdAt'] ?? Timestamp.now()),
              status: doc['status'],
              roomId: roomId,
              type: doc['type'],

            ),
          );

          DateTime? nextDayKey;
          if (i + 1 < docs.length) {
            final nextDoc = docs[i + 1];
            final Timestamp nextTs =
                (nextDoc['createdAt'] ?? nextDoc['localCreatedAt'] ?? Timestamp.now())
                    as Timestamp;
            final nextDate = nextTs.toDate();
            nextDayKey = DateTime(nextDate.year, nextDate.month, nextDate.day);
          }

          final isEndOfThisDay = nextDayKey == null || nextDayKey != dayKey;
          if (isEndOfThisDay) {
            items.add(
              _DateSeparator(
                label: Formatters().formatDateSeparator(ts),
              ),
            );
          }
          if (otherUserId == doc['senderId'] && doc['status'] == 'sent') {
            MessageService().markMessagesAsDelivered(roomId: roomId, currentUserId: currentUserId);
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (otherUserId == doc['senderId'] && doc['status'] == 'sent') {
              MessageService().markMessagesAsRead(roomId: roomId, currentUserId: currentUserId);
            }
          });
        }

        return Expanded(
          child: ListView(
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            children: items,
          ),
        );
      },
    );
  }
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Expanded(
            child: Divider(
              color: dateSeparatorBgColor,
              thickness: 0.8,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: dateSeparatorBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: dateSeparatorTextStyle,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Divider(
              color: dateSeparatorBgColor,
              thickness: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble( this.amount, {
    super.key,
    required this.text,
    required this.messageId,
    required this.type,
    required this.isMe,
    required this.time,
    required this.status,
    required this.roomId,
  });

  final String messageId;
  final String ? text;
  final bool isMe;
  final String time;
  final String status;
  final String roomId;
  final String ? type;
  final String ? amount;

  @override
  Widget build(BuildContext context) {
    if (type == 'moneyTransfer') {

      return GestureDetector(
        onLongPress: () => _showOptions(context),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 6),
            width: MediaQuery.of(context).size.width * 0.75,
            height: 100,
            decoration: BoxDecoration(
              color: isMe ? myMessageBubbleColor : otherMessageBubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                )
              ],
            ),
            child: IntrinsicWidth(
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 40,),
                        SizedBox(width: 20,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$kNaira${kFormatter.format(double.parse(amount!))}',
                              style: isMe ? messageTextStyle.copyWith( fontSize: 20,
                                fontWeight: FontWeight.w900,) : otherMessageTextStyle.copyWith( fontSize: 20,
                                fontWeight: FontWeight.w900,),
                              textAlign: TextAlign.left,
                              softWrap: true,
                            ),
                            Text(status,  style: isMe ? messageTextStyle : otherMessageTextStyle,)
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Divider(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('NexPay Transfer', style: timeTextStyle,),
                      Row(
                        children: [
                          Text(
                            time,
                            style:  timeTextStyle,
                            textAlign: TextAlign.right,
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            _buildStatusIcon(),
                          ]
                        ],
                      ),

                    ],
                  ),
                  Visibility(
                    visible: status != 'Accepted',
                      child: ElevatedButton(style: ElevatedButton.styleFrom(
                        // Use fixedSize to set exact dimensions
                        fixedSize: Size(3, 5),

                        // Alternatively, use minimumSize to set a minimum threshold
                        // minimumSize: Size(50, 30),

                        // Reduce padding
                        padding: EdgeInsets.zero,
                      ),
                          onPressed: isMe ? ( ) {} : () {} , child: Text(isMe ? 'Cancel' : 'Accept'))
                  )
                ],
              ),
            ),
          ),
        ),
      );

    }
    return GestureDetector(
      onLongPress: () => _showOptions(context),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 6),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
            minWidth: 100
          ),
          decoration: BoxDecoration(
            color: isMe ? myMessageBubbleColor : otherMessageBubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
              )
            ],
          ),
          child: IntrinsicWidth(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              // mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text!,
                    style: isMe ? messageTextStyle : otherMessageTextStyle,
                    textAlign: TextAlign.left,
                    softWrap: true,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style:  timeTextStyle,
                        textAlign: TextAlign.right,
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        _buildStatusIcon(),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {

    IconData icon;
    Color color;
    double size;

    switch (status) {
      case 'read':
        icon = Icons.done_all;
        color = messageStatusReadBlue;
        size = readIconSize;
        break;
      case 'delivered':
        icon = Icons.done_all;
        color = Colors.grey;
        size = deliveredIconSize;
        break;
      case 'sent':
        icon = Icons.check;
        color = messageStatusGrey;
        size = sentIconSize;
        break;
      case 'sending':
        icon = Icons.access_time;
        color = messageStatusGrey;
        size = sendingIconSize;
        break;
      default:
        icon = Icons.error;
        color = Colors.grey;
        size = 12;
    }

    return Icon(icon, size: size, color: color, );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete', style: TextStyle(color: Colors.white),),
              onTap: () {
                MessageService().deleteMessage(roomId, messageId);
                Navigator.pop(context);
              },
            ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit (future)', style: TextStyle(color: Colors.white),),
                onTap: () {},
              ),
          ],
        ),
      ),
    );
  }
}


// class MessagesStream extends StatelessWidget {
//
//   const MessagesStream({super.key, required this.otherUserId, required this.roomId});
//
//   final String otherUserId;
//   final String roomId;
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: MessageService().messageStream(roomId),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Center(
//             child: CircularProgressIndicator(
//               backgroundColor: Colors.lightBlueAccent,
//             ),
//           );
//         }
//         final messages = snapshot.data;
//
//         final docs = snapshot.data!.docs;
//         List<MessageBubble> messageBubbles = [];
//
//         for (final doc in docs) {
//           final messageText = doc.get('text');
//           final currentUser = doc.get('senderId');
//
//           final messageBubble = MessageBubble(
//             text: messageText,
//             isMe: otherUserId != currentUser,
//           );
//
//           messageBubbles.add(messageBubble);
//
//         }
//         return Expanded(
//           child: ListView(
//             reverse: true,
//             padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
//             children: messageBubbles,
//           ),
//         );
//       },
//     );
//   }
// }
//
// class MessageBubble extends StatelessWidget {
//   const MessageBubble({super.key, required this.text, required this.isMe});
//
//   final String text;
//   final bool isMe;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(10.0),
//       child: Column(
//         crossAxisAlignment:
//         isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: <Widget>[
//           Material(
//             borderRadius: isMe
//                 ? BorderRadius.only(
//                 topLeft: Radius.circular(30.0),
//                 bottomLeft: Radius.circular(30.0),
//                 bottomRight: Radius.circular(30.0))
//                 : BorderRadius.only(
//               bottomLeft: Radius.circular(30.0),
//               bottomRight: Radius.circular(30.0),
//               topRight: Radius.circular(30.0),
//             ),
//             elevation: 5.0,
//             color: isMe ? Colors.lightBlueAccent : Colors.white,
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//               child: Text(
//                 text,
//                 style: TextStyle(
//                   color: isMe ? Colors.white : Colors.black54,
//                   fontSize: 15.0,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
