import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  final String apiKey =
      'AIzaSyDc4UaC6lB8rI12ip2jfF_-nWaQVeAJ7GA'; // Replace with your API key
  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;

    setState(() {
      _messages.add({"user": userMessage});
    });

    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$apiKey';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": userMessage}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if the response structure is valid
        final aiResponse = data['candidates']?[0]['content']['parts']?[0]
                ['text'] ??
            "Sorry, no response received.";

        setState(() {
          _messages.add({"bot": aiResponse});
        });
      } else {
        setState(() {
          _messages.add({"bot": "Sorry, I couldn't process that."});
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _messages.add({"bot": "Something went wrong. Please try again."});
      });
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.white),
            SizedBox(width: 10),
            Text('Dr. AI Chatbot',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Color(0xFF1A73E8),
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.keys.first == "user";
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isUser)
                        CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child:
                              Icon(Icons.medical_services, color: Colors.white),
                        ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isUser ? Color(0xFF1A73E8) : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: isUser
                              ? Text(
                                  message.values.first,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                )
                              : MarkdownBody(
                                  data: message.values.first,
                                  styleSheet: MarkdownStyleSheet(
                                    p: TextStyle(
                                        color: Colors.black87, fontSize: 16),
                                  ),
                                ),
                        ),
                      ),
                      if (isUser) SizedBox(width: 10),
                      if (isUser)
                        CircleAvatar(
                          backgroundColor: Colors.grey[400],
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF1A73E8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
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
