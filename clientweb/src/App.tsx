import { useEffect, useState } from "react";

interface Message {
  content: string;
  name: string;
  isSent: boolean;
  timestamp: Date;
}

const App = () => {
  const [socket, setSocket] = useState<WebSocket | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [userMessage, setUserMessage] = useState<string>("");
  const [userName, setUserName] = useState<string>("");
  const [isNameSet, setIsNameSet] = useState<boolean>(false);
  const [isConnected, setIsConnected] = useState<boolean>(false);

  const parseMessage = (message: string): { name: string; content: string } => {
    if (message.includes(': ')) {
      const parts = message.split(': ');
      return {
        name: parts[0],
        content: parts.slice(1).join(': ')
      };
    }
    return {
      name: 'Anonymous',
      content: message
    };
  };

  useEffect(() => {
    const ws = new WebSocket("ws://localhost:4000");

    ws.onopen = () => {
      console.log("Connected to the server");
      setSocket(ws);
      setIsConnected(true);
    };

    ws.onmessage = (event) => {
      console.log("Received a message from the server");

      const handleMessage = (text: string) => {
        const parsed = parseMessage(text);
        setMessages((prevMessages) => [...prevMessages, {
          content: parsed.content,
          name: parsed.name,
          isSent: false,
          timestamp: new Date()
        }]);
      };

      if (event.data instanceof Blob) {
        const reader = new FileReader();
        reader.onload = () => {
          const text = reader.result as string;
          handleMessage(text);
        };
        reader.readAsText(event.data);
      } else if (typeof event.data === "string") {
        handleMessage(event.data);
      }
    };

    ws.onclose = () => {
      console.log("Disconnected from the server");
      setSocket(null);
      setIsConnected(false);
    };

    ws.onerror = (err) => {
      console.error(err);
      ws.close();
    };

    return () => {
      ws.close();
    };
  }, []);

  const handleSetName = () => {
    if (userName.trim()) {
      setIsNameSet(true);
    }
  };

  const handleSendMessage = () => {
    if (userMessage.trim() && socket && userName) {
      const formattedMessage = `${userName}: ${userMessage}`;

      // Add to local messages as sent
      setMessages(prev => [...prev, {
        content: userMessage,
        name: userName,
        isSent: true,
        timestamp: new Date()
      }]);

      socket.send(formattedMessage);
      setUserMessage("");
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent, action: () => void) => {
    if (e.key === 'Enter') {
      action();
    }
  };

  if (!isConnected) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
        <div className="text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <h1 className="text-2xl font-bold text-gray-800">Connecting to server...</h1>
          <p className="text-gray-600 mt-2">Please wait while we establish connection</p>
        </div>
      </div>
    );
  }

  if (!isNameSet) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
        <div className="bg-white rounded-2xl shadow-2xl p-8 w-full max-w-md mx-4">
          <div className="text-center mb-8">
            <div className="w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg className="w-12 h-12 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
              </svg>
            </div>
            <h1 className="text-3xl font-bold text-gray-800 mb-2">Welcome to Chat</h1>
            <p className="text-gray-600">Enter your name to start chatting with others</p>
          </div>

          <div className="space-y-4">
            <div>
              <input
                type="text"
                value={userName}
                onChange={(e) => setUserName(e.target.value)}
                onKeyPress={(e) => handleKeyPress(e, handleSetName)}
                className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
                placeholder="Enter your name..."
                maxLength={20}
              />
            </div>
            <button
              onClick={handleSetName}
              disabled={!userName.trim()}
              className="w-full bg-gradient-to-r from-blue-600 to-blue-700 text-white py-3 px-6 rounded-xl font-semibold hover:from-blue-700 hover:to-blue-800 transform hover:scale-105 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
            >
              Start Chatting
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {/* Header */}
      <div className="bg-white shadow-lg border-b border-gray-200">
        <div className="max-w-4xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-gray-800">Chat Room</h1>
              <p className="text-sm text-gray-600">Hello, {userName}</p>
            </div>
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
              <span className="text-sm text-gray-600">Connected</span>
              <button
                onClick={() => {
                  setIsNameSet(false);
                  setUserName("");
                  setMessages([]);
                }}
                className="ml-4 p-2 text-gray-600 hover:text-gray-800 hover:bg-gray-100 rounded-lg transition-colors"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Chat Messages */}
      <div className="flex-1 overflow-hidden">
        <div className="max-w-4xl mx-auto h-full">
          <div className="h-full overflow-y-auto px-4 py-6">
            {messages.length === 0 ? (
              <div className="flex flex-col items-center justify-center h-full text-center">
                <div className="w-24 h-24 bg-gray-200 rounded-full flex items-center justify-center mb-4">
                  <svg className="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                  </svg>
                </div>
                <h3 className="text-xl font-semibold text-gray-600 mb-2">No messages yet</h3>
                <p className="text-gray-500">Start a conversation!</p>
              </div>
            ) : (
              <div className="space-y-4">
                {messages.map((message, index) => (
                  <div
                    key={index}
                    className={`flex ${message.isSent ? 'justify-end' : 'justify-start'}`}
                  >
                    <div className={`max-w-xs lg:max-w-md ${message.isSent ? 'order-2' : 'order-1'}`}>
                      {!message.isSent && (
                        <div className="text-sm text-gray-600 mb-1 px-3">
                          {message.name}
                        </div>
                      )}
                      <div
                        className={`px-4 py-3 rounded-2xl shadow-md ${message.isSent
                            ? 'bg-gradient-to-r from-blue-600 to-blue-700 text-white rounded-br-md'
                            : 'bg-white text-gray-800 rounded-bl-md border border-gray-200'
                          }`}
                      >
                        <p className="text-sm leading-relaxed">{message.content}</p>
                      </div>
                      {message.isSent && (
                        <div className="text-sm text-gray-600 mt-1 px-3 text-right">
                          You
                        </div>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Message Input */}
      <div className="bg-white border-t border-gray-200 shadow-lg">
        <div className="max-w-4xl mx-auto px-4 py-4">
          <div className="flex space-x-4">
            <div className="flex-1">
              <input
                type="text"
                value={userMessage}
                onChange={(e) => setUserMessage(e.target.value)}
                onKeyPress={(e) => handleKeyPress(e, handleSendMessage)}
                className="w-full px-4 py-3 border border-gray-300 rounded-2xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
                placeholder="Type your message..."
                maxLength={500}
              />
            </div>
            <button
              onClick={handleSendMessage}
              disabled={!userMessage.trim()}
              className="bg-gradient-to-r from-blue-600 to-blue-700 text-white p-3 rounded-2xl hover:from-blue-700 hover:to-blue-800 transform hover:scale-105 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default App;