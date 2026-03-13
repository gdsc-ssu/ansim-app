import 'package:ansim_app/common/widgets/atom/texts/texts.dart';
import 'package:ansim_app/constansts/constants.dart';
import 'package:flutter/material.dart';

class AnsimButton extends StatelessWidget {
  final String text;          // 버튼 문구
  final Color backgroundColor; // 버튼 배경색
  final Color textColor;       // 글자 색상
  final VoidCallback onPressed; // 클릭 이벤트

  const AnsimButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AnsimColor.primary, // 기본값 설정
    this.textColor = Colors.white,      // 기본값 설정
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: AnsimTextStyle.buttonB3.copyWith(color: textColor),
        ),
      ),
    );
  }
}