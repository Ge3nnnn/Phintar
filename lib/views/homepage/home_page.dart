import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/constants/appbar.dart';
import 'package:blabla/models/user_model_colour_palatte.dart';
import 'package:flutter/material.dart';

class HomePagePhintar extends StatelessWidget {
  const HomePagePhintar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar(title: "Selamat datang,"),
      body: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Column(
          children: [
            Text(
              'Modul',
              style: AppTextStyle.subjudul,
              // textAlign: TextAlign.end,
            ),
            // pembatas
            Divider(color: AppColors.textColor, thickness: 1),
            enterCource(),
          ],
        ),
      ),
    );
  }
}

class enterCource extends StatelessWidget {
  const enterCource({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.backgroundSecondary,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColors.backgroundPrimary,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(Icons.electric_bike, color: AppColors.textColor),
              ),
              Column(
                children: [
                  Text("Judul", style: AppTextStyle.botttonText),
                  Text("SubJudul", style: AppTextStyle.bottomText),
                ],
              ),

              Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}
