import 'package:flutter/material.dart';
import 'package:clientmobile/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  String _userName = '';
  bool _isNameSet = false;

  @override
  void initState() {
    super.initState();

    // Listen to the stream and update the UI outside of the build method
    _chatService.channel.stream.listen((data) {
      print('Received: $data');
      String message =
          data is List<int> ? String.fromCharCodes(data) : data.toString();

      // Parse message to extract name and content
      Map<String, String> parsedMessage = _parseMessage(message);

      setState(() {
        _messages.add({
          'message': parsedMessage['content'],
          'name': parsedMessage['name'],
          'isSent': false
        });
      });
    });
  }

  Map<String, String> _parseMessage(String message) {
    // Try to parse message in format "Name: Message"
    if (message.contains(': ')) {
      List<String> parts = message.split(': ');
      return {'name': parts[0], 'content': parts.sublist(1).join(': ')};
    }
    return {'name': 'Anonymous', 'content': message};
  }

  @override
  void dispose() {
    _chatService.dispose();
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _setName() {
    if (_nameController.text.trim().isNotEmpty) {
      setState(() {
        _userName = _nameController.text.trim();
        _isNameSet = true;
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty && _userName.isNotEmpty) {
      String formattedMessage = '$_userName: ${_controller.text}';

      setState(() {
        _messages.add(
            {'message': _controller.text, 'name': _userName, 'isSent': true});
      });

      _chatService.sendMessage(formattedMessage);
      _controller.clear();
    }
  }

  Widget _buildNameInput() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_outline,
            size: 80,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 24),
          const Text(
            'Welcome to Chat',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Please enter your name to start chatting',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter your name...',
                prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onSubmitted: (_) => _setName(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _setName,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 3,
            ),
            child: const Text(
              'Start Chatting',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> messageData, int index) {
    bool isSentByUser = messageData['isSent'] ?? false;
    String message = messageData['message'] ?? '';
    String name = messageData['name'] ?? 'Anonymous';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment:
            isSentByUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isSentByUser)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Align(
            alignment:
                isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                gradient: isSentByUser
                    ? const LinearGradient(
                        colors: [Colors.blueAccent, Colors.blue],
                      )
                    : LinearGradient(
                        colors: [Colors.grey[100]!, Colors.grey[50]!],
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20.0),
                  topRight: const Radius.circular(20.0),
                  bottomLeft: Radius.circular(isSentByUser ? 20.0 : 4.0),
                  bottomRight: Radius.circular(isSentByUser ? 4.0 : 20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: isSentByUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isSentByUser)
            Padding(
              padding: const EdgeInsets.only(right: 12.0, top: 4.0),
              child: Text(
                'You',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isNameSet) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: _buildNameInput(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chat Room',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Hello, $_userName',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              setState(() {
                _isNameSet = false;
                _userName = '';
                _nameController.clear();
                _messages.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a conversation!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index], index);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        prefixIcon:
                            Icon(Icons.message, color: Colors.blueAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.blue],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                    iconSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:clientmobile/services/chat_service.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final ChatService _chatService = ChatService();
//   final TextEditingController _controller = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final List<Map<String, dynamic>> _messages = [];
//   String _userName = '';
//   bool _isNameSet = false;

//   @override
//   void initState() {
//     super.initState();

//     // Listen to the stream and update the UI outside of the build method
//     _chatService.channel.stream.listen((data) {
//       print('Received: $data');
//       String message =
//           data is List<int> ? String.fromCharCodes(data) : data.toString();

//       // Parse message to extract name and content
//       Map<String, String> parsedMessage = _parseMessage(message);
      
//       setState(() {
//         _messages.add({
//           'message': parsedMessage['content'],
//           'name': parsedMessage['name'],
//           'isSent': false
//         });
//       });
//     });
//   }

//   Map<String, String> _parseMessage(String message) {
//     // Try to parse message in format "Name: Message"
//     if (message.contains(': ')) {
//       List<String> parts = message.split(': ');
//       return {
//         'name': parts[0],
//         'content': parts.sublist(1).join(': ')
//       };
//     }
//     return {
//       'name': 'Anonymous',
//       'content': message
//     };
//   }

//   @override
//   void dispose() {
//     _chatService.dispose();
//     _controller.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   void _setName() {
//     if (_nameController.text.trim().isNotEmpty) {
//       setState(() {
//         _userName = _nameController.text.trim();
//         _isNameSet = true;
//       });
//     }
//   }

//   void _sendMessage() {
//     if (_controller.text.isNotEmpty && _userName.isNotEmpty) {
//       String formattedMessage = '$_userName: ${_controller.text}';
      
//       setState(() {
//         _messages.add({
//           'message': _controller.text,
//           'name': _userName,
//           'isSent': true
//         });
//       });
      
//       _chatService.sendMessage(formattedMessage);
//       _controller.clear();
//     }
//   }

//   Widget _buildNameInput() {
//     return Container(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.person_outline,
//             size: 80,
//             color: Colors.blueAccent,
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Welcome to Chat',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueAccent,
//             ),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'Please enter your name to start chatting',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 32),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 hintText: 'Enter your name...',
//                 prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(16.0)),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               ),
//               onSubmitted: (_) => _setName(),
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _setName,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blueAccent,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.0),
//               ),
//               elevation: 3,
//             ),
//             child: const Text(
//               'Start Chatting',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(Map<String, dynamic> messageData, int index) {
//     bool isSentByUser = messageData['isSent'] ?? false;
//     String message = messageData['message'] ?? '';
//     String name = messageData['name'] ?? 'Anonymous';
    
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
//       child: Column(
//         crossAxisAlignment: isSentByUser 
//             ? CrossAxisAlignment.end 
//             : CrossAxisAlignment.start,
//         children: [
//           if (!isSentByUser)
//             Padding(
//               padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
//               child: Text(
//                 name,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           Align(
//             alignment: isSentByUser
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.75,
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//               decoration: BoxDecoration(
//                 gradient: isSentByUser
//                     ? const LinearGradient(
//                         colors: [Colors.blueAccent, Colors.blue],
//                       )
//                     : LinearGradient(
//                         colors: [Colors.grey[100]!, Colors.grey[50]!],
//                       ),
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(20.0),
//                   topRight: const Radius.circular(20.0),
//                   bottomLeft: Radius.circular(isSentByUser ? 20.0 : 4.0),
//                   bottomRight: Radius.circular(isSentByUser ? 4.0 : 20.0),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 5,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   color: isSentByUser ? Colors.white : Colors.black87,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//           if (isSentByUser)
//             Padding(
//               padding: const EdgeInsets.only(right: 12.0, top: 4.0),
//               child: Text(
//                 'You',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isNameSet) {
//       return Scaffold(
//         backgroundColor: Colors.grey[50],
//         body: SafeArea(
//           child: _buildNameInput(),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Chat Room',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'Hello, $_userName',
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.blueAccent,
//         elevation: 2,
//         shadowColor: Colors.black.withOpacity(0.1),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person_outline),
//             onPressed: () {
//               setState(() {
//                 _isNameSet = false;
//                 _userName = '';
//                 _nameController.clear();
//                 _messages.clear();
//               });
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _messages.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.chat_bubble_outline,
//                           size: 80,
//                           color: Colors.grey[400],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No messages yet',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Start a conversation!',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[500],
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     itemCount: _messages.length,
//                     itemBuilder: (context, index) {
//                       return _buildMessageBubble(_messages[index], index);
//                     },
//                   ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(25.0),
//                     ),
//                     child: TextField(
//                       controller: _controller,
//                       decoration: const InputDecoration(
//                         hintText: 'Type a message...',
//                         prefixIcon: Icon(Icons.message, color: Colors.blueAccent),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(25.0)),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Colors.transparent,
//                         contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                       ),
//                       onSubmitted: (_) => _sendMessage(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Container(
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.blueAccent, Colors.blue],
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     onPressed: _sendMessage,
//                     icon: const Icon(Icons.send),
//                     color: Colors.white,
//                     iconSize: 24,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:clientmobile/services/chat_service.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final ChatService _chatService = ChatService();
//   final TextEditingController _controller = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final List<Map<String, dynamic>> _messages = [];
//   String _userName = '';
//   bool _isNameSet = false;

//   @override
//   void initState() {
//     super.initState();

//     // Listen to the stream and update the UI outside of the build method
//     _chatService.channel.stream.listen((data) {
//       print('Received: $data');
//       String message =
//           data is List<int> ? String.fromCharCodes(data) : data.toString();

//       // Parse message to extract name and content
//       Map<String, String> parsedMessage = _parseMessage(message);
      
//       setState(() {
//         _messages.add({
//           'message': parsedMessage['content'],
//           'name': parsedMessage['name'],
//           'isSent': false
//         });
//       });
//     });
//   }

//   Map<String, String> _parseMessage(String message) {
//     // Try to parse message in format "Name: Message"
//     if (message.contains(': ')) {
//       List<String> parts = message.split(': ');
//       return {
//         'name': parts[0],
//         'content': parts.sublist(1).join(': ')
//       };
//     }
//     return {
//       'name': 'Anonymous',
//       'content': message
//     };
//   }

//   @override
//   void dispose() {
//     _chatService.dispose();
//     _controller.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   void _setName() {
//     if (_nameController.text.trim().isNotEmpty) {
//       setState(() {
//         _userName = _nameController.text.trim();
//         _isNameSet = true;
//       });
//     }
//   }

//   void _sendMessage() {
//     if (_controller.text.isNotEmpty && _userName.isNotEmpty) {
//       String formattedMessage = '$_userName: ${_controller.text}';
      
//       setState(() {
//         _messages.add({
//           'message': _controller.text,
//           'name': _userName,
//           'isSent': true
//         });
//       });
      
//       _chatService.sendMessage(formattedMessage);
//       _controller.clear();
//     }
//   }

//   Widget _buildNameInput() {
//     return Container(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.person_outline,
//             size: 80,
//             color: Colors.blueAccent,
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Welcome to Chat',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueAccent,
//             ),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'Please enter your name to start chatting',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 32),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 hintText: 'Enter your name...',
//                 prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(16.0)),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               ),
//               onSubmitted: (_) => _setName(),
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _setName,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blueAccent,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.0),
//               ),
//               elevation: 3,
//             ),
//             child: const Text(
//               'Start Chatting',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(Map<String, dynamic> messageData, int index) {
//     bool isSentByUser = messageData['isSent'] ?? false;
//     String message = messageData['message'] ?? '';
//     String name = messageData['name'] ?? 'Anonymous';
    
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
//       child: Column(
//         crossAxisAlignment: isSentByUser 
//             ? CrossAxisAlignment.end 
//             : CrossAxisAlignment.start,
//         children: [
//           if (!isSentByUser)
//             Padding(
//               padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
//               child: Text(
//                 name,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           Align(
//             alignment: isSentByUser
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.75,
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//               decoration: BoxDecoration(
//                 gradient: isSentByUser
//                     ? const LinearGradient(
//                         colors: [Colors.blueAccent, Colors.blue],
//                       )
//                     : LinearGradient(
//                         colors: [Colors.grey[100]!, Colors.grey[50]!],
//                       ),
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(20.0),
//                   topRight: const Radius.circular(20.0),
//                   bottomLeft: Radius.circular(isSentByUser ? 20.0 : 4.0),
//                   bottomRight: Radius.circular(isSentByUser ? 4.0 : 20.0),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 5,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   color: isSentByUser ? Colors.white : Colors.black87,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//           if (isSentByUser)
//             Padding(
//               padding: const EdgeInsets.only(right: 12.0, top: 4.0),
//               child: Text(
//                 'You',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isNameSet) {
//       return Scaffold(
//         backgroundColor: Colors.grey[50],
//         body: SafeArea(
//           child: _buildNameInput(),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Chat Room',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'Hello, $_userName',
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.blueAccent,
//         elevation: 2,
//         shadowColor: Colors.black.withOpacity(0.1),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person_outline),
//             onPressed: () {
//               setState(() {
//                 _isNameSet = false;
//                 _userName = '';
//                 _nameController.clear();
//                 _messages.clear();
//               });
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _messages.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.chat_bubble_outline,
//                           size: 80,
//                           color: Colors.grey[400],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No messages yet',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Start a conversation!',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[500],
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     itemCount: _messages.length,
//                     itemBuilder: (context, index) {
//                       return _buildMessageBubble(_messages[index], index);
//                     },
//                   ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(25.0),
//                     ),
//                     child: TextField(
//                       controller: _controller,
//                       decoration: const InputDecoration(
//                         hintText: 'Type a message...',
//                         prefixIcon: Icon(Icons.message, color: Colors.blueAccent),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(25.0)),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Colors.transparent,
//                         contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                       ),
//                       onSubmitted: (_) => _sendMessage(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Container(
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.blueAccent, Colors.blue],
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     onPressed: _sendMessage,
//                     icon: const Icon(Icons.send),
//                     color: Colors.white,
//                     iconSize: 24,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:clientmobile/services/chat_service.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final ChatService _chatService = ChatService();
//   final TextEditingController _controller = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final List<Map<String, dynamic>> _messages = [];
//   String _userName = '';
//   bool _isNameSet = false;

//   @override
//   void initState() {
//     super.initState();

//     // Listen to the stream and update the UI outside of the build method
//     _chatService.channel.stream.listen((data) {
//       print('Received: $data');
//       String message =
//           data is List<int> ? String.fromCharCodes(data) : data.toString();

//       // Parse message to extract name and content
//       Map<String, String> parsedMessage = _parseMessage(message);
      
//       setState(() {
//         _messages.add({
//           'message': parsedMessage['content'],
//           'name': parsedMessage['name'],
//           'isSent': false
//         });
//       });
//     });
//   }

//   Map<String, String> _parseMessage(String message) {
//     // Try to parse message in format "Name: Message"
//     if (message.contains(': ')) {
//       List<String> parts = message.split(': ');
//       return {
//         'name': parts[0],
//         'content': parts.sublist(1).join(': ')
//       };
//     }
//     return {
//       'name': 'Anonymous',
//       'content': message
//     };
//   }

//   @override
//   void dispose() {
//     _chatService.dispose();
//     _controller.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   void _setName() {
//     if (_nameController.text.trim().isNotEmpty) {
//       setState(() {
//         _userName = _nameController.text.trim();
//         _isNameSet = true;
//       });
//     }
//   }

//   void _sendMessage() {
//     if (_controller.text.isNotEmpty && _userName.isNotEmpty) {
//       String formattedMessage = '$_userName: ${_controller.text}';
      
//       setState(() {
//         _messages.add({
//           'message': _controller.text,
//           'name': _userName,
//           'isSent': true
//         });
//       });
      
//       _chatService.sendMessage(formattedMessage);
//       _controller.clear();
//     }
//   }

//   Widget _buildNameInput() {
//     return Container(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.person_outline,
//             size: 80,
//             color: Colors.blueAccent,
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Welcome to Chat',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueAccent,
//             ),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'Please enter your name to start chatting',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 32),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 hintText: 'Enter your name...',
//                 prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(16.0)),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               ),
//               onSubmitted: (_) => _setName(),
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _setName,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blueAccent,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.0),
//               ),
//               elevation: 3,
//             ),
//             child: const Text(
//               'Start Chatting',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(Map<String, dynamic> messageData, int index) {
//     bool isSentByUser = messageData['isSent'] ?? false;
//     String message = messageData['message'] ?? '';
//     String name = messageData['name'] ?? 'Anonymous';
    
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
//       child: Column(
//         crossAxisAlignment: isSentByUser 
//             ? CrossAxisAlignment.end 
//             : CrossAxisAlignment.start,
//         children: [
//           if (!isSentByUser)
//             Padding(
//               padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
//               child: Text(
//                 name,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           Align(
//             alignment: isSentByUser
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.75,
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//               decoration: BoxDecoration(
//                 gradient: isSentByUser
//                     ? const LinearGradient(
//                         colors: [Colors.blueAccent, Colors.blue],
//                       )
//                     : LinearGradient(
//                         colors: [Colors.grey[100]!, Colors.grey[50]!],
//                       ),
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(20.0),
//                   topRight: const Radius.circular(20.0),
//                   bottomLeft: Radius.circular(isSentByUser ? 20.0 : 4.0),
//                   bottomRight: Radius.circular(isSentByUser ? 4.0 : 20.0),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 5,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   color: isSentByUser ? Colors.white : Colors.black87,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//           if (isSentByUser)
//             Padding(
//               padding: const EdgeInsets.only(right: 12.0, top: 4.0),
//               child: Text(
//                 'You',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isNameSet) {
//       return Scaffold(
//         backgroundColor: Colors.grey[50],
//         body: SafeArea(
//           child: _buildNameInput(),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Chat Room',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'Hello, $_userName',
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.blueAccent,
//         elevation: 2,
//         shadowColor: Colors.black.withOpacity(0.1),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person_outline),
//             onPressed: () {
//               setState(() {
//                 _isNameSet = false;
//                 _userName = '';
//                 _nameController.clear();
//                 _messages.clear();
//               });
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _messages.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.chat_bubble_outline,
//                           size: 80,
//                           color: Colors.grey[400],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No messages yet',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Start a conversation!',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[500],
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     itemCount: _messages.length,
//                     itemBuilder: (context, index) {
//                       return _buildMessageBubble(_messages[index], index);
//                     },
//                   ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(25.0),
//                     ),
//                     child: TextField(
//                       controller: _controller,
//                       decoration: const InputDecoration(
//                         hintText: 'Type a message...',
//                         prefixIcon: Icon(Icons.message, color: Colors.blueAccent),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(25.0)),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Colors.transparent,
//                         contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                       ),
//                       onSubmitted: (_) => _sendMessage(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Container(
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.blueAccent, Colors.blue],
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     onPressed: _sendMessage,
//                     icon: const Icon(Icons.send),
//                     color: Colors.white,
//                     iconSize: 24,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:clientmobile/services/chat_service.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final ChatService _chatService = ChatService();
//   final TextEditingController _controller = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final List<Map<String, dynamic>> _messages = [];
//   String _userName = '';
//   bool _isNameSet = false;

//   @override
//   void initState() {
//     super.initState();

//     // Listen to the stream and update the UI outside of the build method
//     _chatService.channel.stream.listen((data) {
//       print('Received: $data');
//       String message =
//           data is List<int> ? String.fromCharCodes(data) : data.toString();

//       // Parse message to extract name and content
//       Map<String, String> parsedMessage = _parseMessage(message);
      
//       setState(() {
//         _messages.add({
//           'message': parsedMessage['content'],
//           'name': parsedMessage['name'],
//           'isSent': false
//         });
//       });
//     });
//   }

//   Map<String, String> _parseMessage(String message) {
//     // Try to parse message in format "Name: Message"
//     if (message.contains(': ')) {
//       List<String> parts = message.split(': ');
//       return {
//         'name': parts[0],
//         'content': parts.sublist(1).join(': ')
//       };
//     }
//     return {
//       'name': 'Anonymous',
//       'content': message
//     };
//   }

//   @override
//   void dispose() {
//     _chatService.dispose();
//     _controller.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   void _setName() {
//     if (_nameController.text.trim().isNotEmpty) {
//       setState(() {
//         _userName = _nameController.text.trim();
//         _isNameSet = true;
//       });
//     }
//   }

//   void _sendMessage() {
//     if (_controller.text.isNotEmpty && _userName.isNotEmpty) {
//       String formattedMessage = '$_userName: ${_controller.text}';
      
//       setState(() {
//         _messages.add({
//           'message': _controller.text,
//           'name': _userName,
//           'isSent': true
//         });
//       });
      
//       _chatService.sendMessage(formattedMessage);
//       _controller.clear();
//     }
//   }

//   Widget _buildNameInput() {
//     return Container(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.person_outline,
//             size: 80,
//             color: Colors.blueAccent,
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Welcome to Chat',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueAccent,
//             ),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'Please enter your name to start chatting',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 32),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 hintText: 'Enter your name...',
//                 prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(16.0)),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               ),
//               onSubmitted: (_) => _setName(),
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _setName,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blueAccent,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.0),
//               ),
//               elevation: 3,
//             ),
//             child: const Text(
//               'Start Chatting',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(Map<String, dynamic> messageData, int index) {
//     bool isSentByUser = messageData['isSent'] ?? false;
//     String message = messageData['message'] ?? '';
//     String name = messageData['name'] ?? 'Anonymous';
    
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
//       child: Column(
//         crossAxisAlignment: isSentByUser 
//             ? CrossAxisAlignment.end 
//             : CrossAxisAlignment.start,
//         children: [
//           if (!isSentByUser)
//             Padding(
//               padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
//               child: Text(
//                 name,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           Align(
//             alignment: isSentByUser
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.75,
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//               decoration: BoxDecoration(
//                 gradient: isSentByUser
//                     ? const LinearGradient(
//                         colors: [Colors.blueAccent, Colors.blue],
//                       )
//                     : LinearGradient(
//                         colors: [Colors.grey[100]!, Colors.grey[50]!],
//                       ),
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(20.0),
//                   topRight: const Radius.circular(20.0),
//                   bottomLeft: Radius.circular(isSentByUser ? 20.0 : 4.0),
//                   bottomRight: Radius.circular(isSentByUser ? 4.0 : 20.0),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 5,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   color: isSentByUser ? Colors.white : Colors.black87,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//           if (isSentByUser)
//             Padding(
//               padding: const EdgeInsets.only(right: 12.0, top: 4.0),
//               child: Text(
//                 'You',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isNameSet) {
//       return Scaffold(
//         backgroundColor: Colors.grey[50],
//         body: SafeArea(
//           child: _buildNameInput(),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Chat Room',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'Hello, $_userName',
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.blueAccent,
//         elevation: 2,
//         shadowColor: Colors.black.withOpacity(0.1),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person_outline),
//             onPressed: () {
//               setState(() {
//                 _isNameSet = false;
//                 _userName = '';
//                 _nameController.clear();
//                 _messages.clear();
//               });
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _messages.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.chat_bubble_outline,
//                           size: 80,
//                           color: Colors.grey[400],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No messages yet',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Start a conversation!',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[500],
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     itemCount: _messages.length,
//                     itemBuilder: (context, index) {
//                       return _buildMessageBubble(_messages[index], index);
//                     },
//                   ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(25.0),
//                     ),
//                     child: TextField(
//                       controller: _controller,
//                       decoration: const InputDecoration(
//                         hintText: 'Type a message...',
//                         prefixIcon: Icon(Icons.message, color: Colors.blueAccent),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(25.0)),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Colors.transparent,
//                         contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                       ),
//                       onSubmitted: (_) => _sendMessage(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Container(
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.blueAccent, Colors.blue],
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     onPressed: _sendMessage,
//                     icon: const Icon(Icons.send),
//                     color: Colors.white,
//                     iconSize: 24,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:clientmobile/services/chat_service.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final ChatService _chatService = ChatService();
//   final TextEditingController _controller = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final List<Map<String, dynamic>> _messages = [];
//   String _userName = '';
//   bool _isNameSet = false;

//   @override
//   void initState() {
//     super.initState();

//     // Listen to the stream and update the UI outside of the build method
//     _chatService.channel.stream.listen((data) {
//       print('Received: $data');
//       String message =
//           data is List<int> ? String.fromCharCodes(data) : data.toString();

//       // Parse message to extract name and content
//       Map<String, String> parsedMessage = _parseMessage(message);
      
//       setState(() {
//         _messages.add({
//           'message': parsedMessage['content'],
//           'name': parsedMessage['name'],
//           'isSent': false
//         });
//       });
//     });
//   }

//   Map<String, String> _parseMessage(String message) {
//     // Try to parse message in format "Name: Message"
//     if (message.contains(': ')) {
//       List<String> parts = message.split(': ');
//       return {
//         'name': parts[0],
//         'content': parts.sublist(1).join(': ')
//       };
//     }
//     return {
//       'name': 'Anonymous',
//       'content': message
//     };
//   }

//   @override
//   void dispose() {
//     _chatService.dispose();
//     _controller.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   void _setName() {
//     if (_nameController.text.trim().isNotEmpty) {
//       setState(() {
//         _userName = _nameController.text.trim();
//         _isNameSet = true;
//       });
//     }
//   }

//   void _sendMessage() {
//     if (_controller.text.isNotEmpty && _userName.isNotEmpty) {
//       String formattedMessage = '$_userName: ${_controller.text}';
      
//       setState(() {
//         _messages.add({
//           'message': _controller.text,
//           'name': _userName,
//           'isSent': true
//         });
//       });
      
//       _chatService.sendMessage(formattedMessage);
//       _controller.clear();
//     }
//   }

//   Widget _buildNameInput() {
//     return Container(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.person_outline,
//             size: 80,
//             color: Colors.blueAccent,
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Welcome to Chat',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueAccent,
//             ),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'Please enter your name to start chatting',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 32),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 hintText: 'Enter your name...',
//                 prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(16.0)),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               ),
//               onSubmitted: (_) => _setName(),
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _setName,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blueAccent,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.0),
//               ),
//               elevation: 3,
//             ),
//             child: const Text(
//               'Start Chatting',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(Map<String, dynamic> messageData, int index) {
//     bool isSentByUser = messageData['isSent'] ?? false;
//     String message = messageData['message'] ?? '';
//     String name = messageData['name'] ?? 'Anonymous';
    
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
//       child: Column(
//         crossAxisAlignment: isSentByUser 
//             ? CrossAxisAlignment.end 
//             : CrossAxisAlignment.start,
//         children: [
//           if (!isSentByUser)
//             Padding(
//               padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
//               child: Text(
//                 name,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           Align(
//             alignment: isSentByUser
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.75,
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//               decoration: BoxDecoration(
//                 gradient: isSentByUser
//                     ? const LinearGradient(
//                         colors: [Colors.blueAccent, Colors.blue],
//                       )
//                     : LinearGradient(
//                         colors: [Colors.grey[100]!, Colors.grey[50]!],
//                       ),
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(20.0),
//                   topRight: const Radius.circular(20.0),
//                   bottomLeft: Radius.circular(isSentByUser ? 20.0 : 4.0),
//                   bottomRight: Radius.circular(isSentByUser ? 4.0 : 20.0),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 5,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   color: isSentByUser ? Colors.white : Colors.black87,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//           if (isSentByUser)
//             Padding(
//               padding: const EdgeInsets.only(right: 12.0, top: 4.0),
//               child: Text(
//                 'You',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isNameSet) {
//       return Scaffold(
//         backgroundColor: Colors.grey[50],
//         body: SafeArea(
//           child: _buildNameInput(),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Chat Room',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'Hello, $_userName',
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.blueAccent,
//         elevation: 2,
//         shadowColor: Colors.black.withOpacity(0.1),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person_outline),
//             onPressed: () {
//               setState(() {
//                 _isNameSet = false;
//                 _userName = '';
//                 _nameController.clear();
//                 _messages.clear();
//               });
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _messages.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.chat_bubble_outline,
//                           size: 80,
//                           color: Colors.grey[400],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No messages yet',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Start a conversation!',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[500],
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     itemCount: _messages.length,
//                     itemBuilder: (context, index) {
//                       return _buildMessageBubble(_messages[index], index);
//                     },
//                   ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(25.0),
//                     ),
//                     child: TextField(
//                       controller: _controller,
//                       decoration: const InputDecoration(
//                         hintText: 'Type a message...',
//                         prefixIcon: Icon(Icons.message, color: Colors.blueAccent),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(25.0)),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Colors.transparent,
//                         contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                       ),
//                       onSubmitted: (_) => _sendMessage(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Container(
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.blueAccent, Colors.blue],
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     onPressed: _sendMessage,
//                     icon: const Icon(Icons.send),
//                     color: Colors.white,
//                     iconSize: 24,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:clientmobile/services/chat_service.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final ChatService _chatService = ChatService();
//   final TextEditingController _controller = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final List<Map<String, dynamic>> _messages = [];
//   String _userName = '';
//   bool _isNameSet = false;

//   @override
//   void initState() {
//     super.initState();

//     // Listen to the stream and update the UI outside of the build method
//     _chatService.channel.stream.listen((data) {
//       print('Received: $data');
//       String message =
//           data is List<int> ? String.fromCharCodes(data) : data.toString();

//       // Parse message to extract name and content
//       Map<String, String> parsedMessage = _parseMessage(message);
      
//       setState(() {
//         _messages.add({
//           'message': parsedMessage['content'],
//           'name': parsedMessage['name'],
//           'isSent': false
//         });
//       });
//     });
//   }

//   Map<String, String> _parseMessage(String message) {
//     // Try to parse message in format "Name: Message"
//     if (message.contains(': ')) {
//       List<String> parts = message.split(': ');
//       return {
//         'name': parts[0],
//         'content': parts.sublist(1).join(': ')
//       };
//     }
//     return {
//       'name': 'Anonymous',
//       'content': message
//     };
//   }

//   @override
//   void dispose() {
//     _chatService.dispose();
//     _controller.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   void _setName() {
//     if (_nameController.text.trim().isNotEmpty) {
//       setState(() {
//         _userName = _nameController.text.trim();
//         _isNameSet = true;
//       });
//     }
//   }

//   void _sendMessage() {
//     if (_controller.text.isNotEmpty && _userName.isNotEmpty) {
//       String formattedMessage = '$_userName: ${_controller.text}';
      
//       setState(() {
//         _messages.add({
//           'message': _controller.text,
//           'name': _userName,
//           'isSent': true
//         });
//       });
      
//       _chatService.sendMessage(formattedMessage);
//       _controller.clear();
//     }
//   }

//   Widget _buildNameInput() {
//     return Container(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.person_outline,
//             size: 80,
//             color: Colors.blueAccent,
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Welcome to Chat',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueAccent,
//             ),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'Please enter your name to start chatting',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 32),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 hintText: 'Enter your name...',
//                 prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(16.0)),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               ),
//               onSubmitted: (_) => _setName(),
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _setName,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blueAccent,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.0),
//               ),
//               elevation: 3,
//             ),
//             child: const Text(
//               'Start Chatting',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(Map<String, dynamic> messageData, int index) {
//     bool isSentByUser = messageData['isSent'] ?? false;
//     String message = messageData['message'] ?? '';
//     String name = messageData['name'] ?? 'Anonymous';
    
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
//       child: Column(
//         crossAxisAlignment: isSentByUser 
//             ? CrossAxisAlignment.end 
//             : CrossAxisAlignment.start,
//         children: [
//           if (!isSentByUser)
//             Padding(
//               padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
//               child: Text(
//                 name,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           Align(
//             alignment: isSentByUser
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.75,
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//               decoration: BoxDecoration(
//                 gradient: isSentByUser
//                     ? const LinearGradient(
//                         colors: [Colors.blueAccent, Colors.blue],
//                       )
//                     : LinearGradient(
//                         colors: [Colors.grey[100]!, Colors.grey[50]!],
//                       ),
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(20.0),
//                   topRight: const Radius.circular(20.0),
//                   bottomLeft: Radius.circular(isSentByUser ? 20.0 : 4.0),
//                   bottomRight: Radius.circular(isSentByUser ? 4.0 : 20.0),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 5,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   color: isSentByUser ? Colors.white : Colors.black87,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//           if (isSentByUser)
//             Padding(
//               padding: const EdgeInsets.only(right: 12.0, top: 4.0),
//               child: Text(
//                 'You',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isNameSet) {
//       return Scaffold(
//         backgroundColor: Colors.grey[50],
//         body: SafeArea(
//           child: _buildNameInput(),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Chat Room',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'Hello, $_userName',
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.blueAccent,
//         elevation: 2,
//         shadowColor: Colors.black.withOpacity(0.1),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person_outline),
//             onPressed: () {
//               setState(() {
//                 _isNameSet = false;
//                 _userName = '';
//                 _nameController.clear();
//                 _messages.clear();
//               });
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _messages.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.chat_bubble_outline,
//                           size: 80,
//                           color: Colors.grey[400],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No messages yet',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Start a conversation!',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[500],
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     itemCount: _messages.length,
//                     itemBuilder: (context, index) {
//                       return _buildMessageBubble(_messages[index], index);
//                     },
//                   ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(25.0),
//                     ),
//                     child: TextField(
//                       controller: _controller,
//                       decoration: const InputDecoration(
//                         hintText: 'Type a message...',
//                         prefixIcon: Icon(Icons.message, color: Colors.blueAccent),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(25.0)),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Colors.transparent,
//                         contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                       ),
//                       onSubmitted: (_) => _sendMessage(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Container(
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.blueAccent, Colors.blue],
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     onPressed: _sendMessage,
//                     icon: const Icon(Icons.send),
//                     color: Colors.white,
//                     iconSize: 24,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }