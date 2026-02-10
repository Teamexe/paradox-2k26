import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;


  final List<Map<String, String>> festGames = [
    {
      "title": "Retro Space Invaders",
      "subtitle": "High Score Challenge",
      "status": "LIVE NOW",
      "image": "https://img.freepik.com/free-vector/pixel-art-alien-background_23-2148965947.jpg?w=1380&t=st=1707558000~exp=1707558600~hmac=a4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4",
      "isFeatured": "true", // This makes it look special
    },
    {
      "title": "Mystery Game 2",
      "subtitle": "Coming Soon",
      "status": "Registration Open",
      "image": "https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=2670&auto=format&fit=crop", // Default Gaming Image
      "isFeatured": "false",
    },
  ];


  @override
  Widget build(BuildContext context) {
    // Get colors from your AppTheme
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [


            //HEADER SECTION
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Paradox",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Event Games",
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      ),

                    ],
                  ),
                  // Notification Icon
                  Container(
                    height: 45, width: 45,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(Icons.notifications_none, color: Colors.white),
                  ),
                ],
              ),
            ),


            // GAME CARDS LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: festGames.length,
                itemBuilder: (context, index) {
                  final game = festGames[index];

                  final isFeatured = game["isFeatured"] == "true";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 25),
                    // Featured card is slightly taller
                    height: isFeatured ? 240 : 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                      image: DecorationImage(
                        image: NetworkImage(game["image"]!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          // Dim the image so text is readable
                            Colors.black.withOpacity(isFeatured ? 0.3 : 0.6),
                            BlendMode.darken
                        ),
                      ),

                      border: isFeatured
                          ? Border.all(color: colorScheme.primary, width: 2)
                          : Border.all(color: Colors.white10),
                    ),
                    child: Stack(
                      children: [

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black87],
                            ),
                          ),
                        ),


                        // Text Content
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isFeatured ? colorScheme.primary : Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  game["status"]!,
                                  style: TextStyle(
                                    color: isFeatured ? Colors.black : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Game Title
                              Text(
                                game["title"]!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isFeatured ? 28 : 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),

                              // Subtitle
                              Text(
                                game["subtitle"]!,
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Play Button Icon
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: Container(
                            height: 50, width: 50,
                            decoration: BoxDecoration(
                              color: isFeatured ? Colors.white : colorScheme.surface.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: isFeatured ? Colors.black : Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),







      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: 'Games'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'LeaderBoard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}