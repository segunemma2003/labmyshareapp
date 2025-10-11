import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class ChatPage extends NyStatefulWidget {
  static RouteView path = ("/chat", (_) => ChatPage());

  ChatPage({super.key}) : super(child: () => _ChatPageState());
}

class _ChatPageState extends NyPage<ChatPage> with WidgetsBindingObserver {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  // Your Tawk.to credentials
  final String tawkPropertyId = '687e040399e0301918ab8a7d';
  final String tawkWidgetId = '1j0m3vbjn';

  String get _tawkHTML => '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <title>Chat Support</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            body, html {
                width: 100%;
                height: 100%;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                background-color: #fafafa;
                overflow: hidden;
            }
            #chat-container {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
            }
            /* Hide Tawk.to branding for cleaner look */
            .tawk-branding {
                display: none !important;
            }
        </style>
    </head>
    <body>
        <div id="chat-container"></div>
        
        <!-- Tawk.to Script -->
        <script type="text/javascript">
            var Tawk_API = Tawk_API || {};
            var Tawk_LoadStart = new Date();
            
            Tawk_API.onLoad = function() {
                console.log('Tawk chat loaded successfully');
                try {
                    // Maximize the chat window
                    Tawk_API.maximize();
                } catch(e) {
                    console.error('Error maximizing chat:', e);
                }
            };
            
            Tawk_API.onChatMaximized = function() {
                console.log('Chat maximized');
            };
            
            Tawk_API.onChatMinimized = function() {
                console.log('Chat minimized');
            };
            
            (function(){
                try {
                    var s1 = document.createElement("script");
                    var s0 = document.getElementsByTagName("script")[0];
                    s1.async = true;
                    s1.src = 'https://embed.tawk.to/$tawkPropertyId/$tawkWidgetId';
                    s1.charset = 'UTF-8';
                    s1.setAttribute('crossorigin','*');
                    s1.onerror = function() {
                        console.error('Failed to load Tawk.to script');
                    };
                    s0.parentNode.insertBefore(s1, s0);
                } catch(e) {
                    console.error('Error loading Tawk.to:', e);
                }
            })();
        </script>
    </body>
    </html>
  ''';

  @override
  get init => () {
        WidgetsBinding.instance.addObserver(this);
        _initializeWebView();
      };

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle to prevent background errors
    if (state == AppLifecycleState.paused) {
      print('📱 App going to background');
    } else if (state == AppLifecycleState.resumed) {
      print('📱 App resumed');
      // Reload if there was an error
      if (_hasError) {
        _reloadChat();
      }
    }
  }

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      // iOS specific configuration
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      // Android specific configuration
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFAFAFA))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print('📊 Chat loading: $progress%');
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            print('🌐 Page started loading');
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) async {
            print('✅ Page finished loading');
            setState(() {
              _isLoading = false;
            });

            // Wait a bit before running JavaScript
            await Future.delayed(const Duration(milliseconds: 800));

            // Safely inject JavaScript to maximize chat
            _safeRunJavaScript('''
              try {
                if (typeof Tawk_API !== 'undefined' && Tawk_API.maximize) {
                  Tawk_API.maximize();
                  console.log('Chat maximized via Flutter');
                } else {
                  console.log('Tawk_API not ready yet');
                  // Try again after a delay
                  setTimeout(function() {
                    if (typeof Tawk_API !== 'undefined' && Tawk_API.maximize) {
                      Tawk_API.maximize();
                    }
                  }, 1000);
                }
              } catch(e) {
                console.error('Error maximizing chat:', e);
              }
            ''');
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ WebView error: ${error.description}');
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = error.description;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation for Tawk.to
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_tawkHTML);
  }

  void _safeRunJavaScript(String script) {
    _controller.runJavaScript(script).catchError((error) {
      print('⚠️ JavaScript execution error: $error');
      // Don't show error to user, it's not critical
      return null;
    });
  }

  void _reloadChat() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    _controller.reload();
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade300,
                child: Icon(
                  Icons.support_agent,
                  color: Colors.grey.shade600,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Support Chat",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Online",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _reloadChat,
            tooltip: 'Reload chat',
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebView
          if (!_hasError) WebViewWidget(controller: _controller),

          // Loading indicator
          if (_isLoading && !_hasError)
            Container(
              color: Colors.grey.shade50,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Loading chat...",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please wait a moment",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Error state
          if (_hasError && !_isLoading)
            Container(
              color: Colors.grey.shade50,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Could not load chat',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage ??
                            'Please check your internet connection and try again',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _reloadChat,
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text(
                            'Try Again',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
