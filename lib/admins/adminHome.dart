import 'package:flutter/material.dart';


class adminhome extends StatefulWidget {
  const adminhome({super.key});

  @override
  State<adminhome> createState() => _adminhomeState();
}

class _adminhomeState extends State<adminhome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/pictures/Catbckgrnd.webp',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SizedBox(height: 9.0),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/adminCalendar');
            },
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'Calendar?',
                style: TextStyle(
                  color: Color(0xFF7A4C10),
                  fontSize: 21.0,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
