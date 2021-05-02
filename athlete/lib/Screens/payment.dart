import 'dart:io';
import 'package:athlete/widgets/custom_input.dart';
import 'package:athlete/utils/hexToColor.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:athlete/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class CheckoutMethodCard extends StatefulWidget {
  final int totalPrice;
  CheckoutMethodCard(this.totalPrice);

  @override
  _CheckoutMethodCardState createState() => _CheckoutMethodCardState();
}

// Pay public key
class _CheckoutMethodCardState extends State<CheckoutMethodCard> {
  final paystack = PaystackPlugin();
  String _email;
  // double tPrice = widget.totalPrice;

  @override
  void initState() {
    paystack.initialize(
        publicKey: "pk_test_7fbf8885731905381ac4408185395deb3be452b4");
    super.initState();
  }

  sendMail() async {
    String username = 'myathleteapp123@gmail.com';
    String password = 'Athlete12345';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Athlete!')
      ..recipients.add(_email)
      ..subject = 'Location Request ${DateTime.now()}'
      ..text =
          'Dear Athlete! \n \nPlease reply this mail with your address for immediate delivery'
      ..html =
          "<h1>Dear Athlete!</h1>\n<p>Your payment has been confirmed.</p>\n<p>Please reply this mail with your address for immediate delivery</p>";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  Dialog successDialog(context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0)), //this right here
      child: Container(
        height: 350.0,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check_box,
                color: hexToColor("#41aa5e"),
                size: 90,
              ),
              SizedBox(height: 15),
              Text(
                'Payment made',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Please check your email',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                "Your payment has been successfully",
                style: TextStyle(fontSize: 13),
              ),
              Text("processed.", style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return successDialog(context);
      },
    );
  }

  Dialog errorDialog(context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0)), //this right here
      child: Container(
        height: 350.0,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.cancel,
                color: Colors.red,
                size: 90,
              ),
              SizedBox(height: 15),
              Text(
                'Failed to process payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                "Error in processing payment, please try again",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return errorDialog(context);
      },
    );
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  chargeCard() async {
    Charge charge = Charge()
      ..amount = widget.totalPrice * 100
      ..currency = 'GHS'
      ..reference = _getReference()
      // or ..accessCode = _getAccessCodeFrmInitialization()
      ..email = _email;
    CheckoutResponse response = await paystack.checkout(
      context,
      method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
      charge: charge,
    );
    if (response.status == true) {
      _showDialog();
      sendMail();
    } else {
      _showErrorDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Payment Menu",
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: new Column(
        children: <Widget>[
          CustomInput(
            hintText: "Please enter your email...",
            onChanged: (value) {
              _email = value;
            },
            textInputAction: TextInputAction.next,
          ),
          Container(
              padding: EdgeInsets.all(10),
              child: Center(
                child: Button(
                  child: Text(
                    "Pay",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onClick: () => chargeCard(),
                ),
              )),
        ],
      ),
    );
  }
}
