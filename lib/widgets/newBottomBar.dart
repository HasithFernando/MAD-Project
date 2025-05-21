import 'package:flutter/material.dart';
import 'package:thriftale/pages/dashboard.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/widgets/custom_text.dart';

class NewBottomBar extends StatefulWidget {
  final Color c1;
  final Color c2;
  final Color c3;
  final Color c4;

  const NewBottomBar({
    Key? key,
    required this.c1,
    required this.c2,
    required this.c3,
    required this.c4,
  }) : super(key: key);

  @override
  State<NewBottomBar> createState() => _NewBottomBarState();
}

class _NewBottomBarState extends State<NewBottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, -3), // Shadow positioned only above the container
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          children: [
            Divider(
              color: AppColors.white.withOpacity(0.5),
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 14.0, right: 14.0, top: 0.0, bottom: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      NavigationUtils.navBarNavigation(context, Dashboard());
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Container(
                            color: Colors.transparent,
                            child: Icon(
                              Icons.home_filled,
                              size: 28,
                              color: widget.c1,
                            ),
                          ),
                          CustomText(
                            text: 'Dashboard',
                            color: widget.c1,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      NavigationUtils.navBarNavigation(context, Dashboard());
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Container(
                            color: Colors.transparent,
                            child: Icon(
                              Icons.category,
                              size: 28,
                              color: widget.c2,
                            ),
                          ),
                          CustomText(
                              text: 'Top Board',
                              color: widget.c2,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      NavigationUtils.navBarNavigation(context, Dashboard());
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Container(
                            color: Colors.transparent,
                            child: Icon(
                              Icons.rocket_launch_outlined,
                              size: 28,
                              color: widget.c3,
                            ),
                          ),
                          CustomText(
                              text: 'Challenge',
                              color: widget.c3,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      NavigationUtils.navBarNavigation(context, Dashboard());
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Container(
                            color: Colors.transparent,
                            child: Icon(
                              Icons.person_outline_outlined,
                              size: 28,
                              color: widget.c4,
                            ),
                          ),
                          CustomText(
                              text: 'Profile',
                              color: widget.c4,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
