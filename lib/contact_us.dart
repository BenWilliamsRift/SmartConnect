import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

import 'app_bar.dart';
import 'color_manager.dart';
import 'nav_drawer.dart';
import 'string_consts.dart';

// Change email system for inline system
// Send to website form?
// Queue for when disconnected from the internet

class Reports {
  static String bugType = "";
  static String actuatorType = "";
}

class EmailDev {
  static List<String> recipients = ["ben@rifttechnology.com"];

  static void send(String type, String summary, String report) {}
}

class ReportABugPage extends StatefulWidget {
  const ReportABugPage(
      {Key? key, required this.summaryController, required this.bodyController})
      : super(key: key);

  final TextEditingController summaryController;
  final TextEditingController bodyController;

  @override
  State<ReportABugPage> createState() => _ReportABugPageState();
}

class _ReportABugPageState extends State<ReportABugPage> {
  SizedBox sizedBox = const SizedBox(height: 30);
  String bugType = StringConsts.contact.bugApp;
  String actuatorType = StringConsts.actuators.small;

  String getHintText(bool summary) {
    if (bugType == StringConsts.contact.bugActuator) {
      return summary
          ? StringConsts.contact.bugActuatorSummaryHint
          : StringConsts.contact.bugActuatorHint;
    } else if (bugType == StringConsts.contact.bugRiftDevWebsite) {
      return StringConsts.contact.bugRiftDevWebsiteHint;
    }
    return summary
        ? StringConsts.contact.bugAppSummaryHint
        : StringConsts.contact.bugAppHint;
  }

  String getLabelText(bool summary) {
    if (bugType == StringConsts.contact.bugActuator) {
      return summary
          ? StringConsts.contact.bugActuatorSummaryLabel
          : StringConsts.contact.bugActuatorLabel;
    } else if (bugType == StringConsts.contact.bugRiftDevWebsite) {
      return StringConsts.contact.bugRiftDevWebsiteLabel;
    }
    return summary
        ? StringConsts.contact.bugAppSummaryLabel
        : StringConsts.contact.bugAppLabel;
  }

  String getHelpText(bool summary) {
    if (bugType == StringConsts.contact.bugActuator) {
      return summary
          ? StringConsts.contact.bugActuatorSummaryHelp
          : StringConsts.contact.bugActuatorHelp;
    } else if (bugType == StringConsts.contact.bugRiftDevWebsite) {
      return StringConsts.contact.bugRiftDevWebsiteHelp;
    }
    return summary
        ? StringConsts.contact.bugAppSummaryHelp
        : StringConsts.contact.bugAppHelp;
  }

  late TextEditingController summaryController;
  late TextEditingController bodyController;

  @override
  void initState() {
    super.initState();
    summaryController = widget.summaryController;
    bodyController = widget.bodyController;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Scrollbar(
            child: SingleChildScrollView(
                child: Column(children: [
      DropdownButton<String>(
          value: bugType,
          items: StringConsts.contact.bugTypes
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              bugType = value ?? bugType;
              Reports.bugType = bugType;
            });
          }),
      bugType == StringConsts.contact.bugActuator
          ? DropdownButton<String>(
              value: actuatorType,
              items: StringConsts.actuators.actuatorTypes
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  actuatorType = value ?? actuatorType;
                  Reports.actuatorType = actuatorType;
                });
              })
          : Container(),
      TextFormField(
        controller: summaryController,
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            filled: true,
            alignLabelWithHint: true,
            hintText: getHintText(true),
            label: Text(getLabelText(true)),
            helperText: getHelpText(true),
            helperMaxLines: 3),
        maxLines: null,
        enableInteractiveSelection: true,
        textCapitalization: TextCapitalization.sentences,
        autocorrect: true,
      ),
      sizedBox,
      TextFormField(
        controller: bodyController,
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            filled: true,
            alignLabelWithHint: true,
            hintText: getHintText(false),
            label: Text(getLabelText(false)),
            helperText: getHelpText(false),
            helperMaxLines: 3),
        maxLines: null,
        enableInteractiveSelection: true,
        textCapitalization: TextCapitalization.sentences,
        autocorrect: true,
      ),
    ]))));
  }
}

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  String enquiryType = StringConsts.contact.bugReport;

  TextEditingController summaryController = TextEditingController();
  TextEditingController bodyController = TextEditingController();

  void sendEnquiry() async {
    String body = bodyController.text;

    // "enquiryType : bugType if bugType isn't empty : actuatorType if bugType == Actuators : summery"
    String summary =
        "$enquiryType : ${StringConsts.contact.bugTypes.contains(Reports.bugType) ? "${Reports.bugType} : " : ""}${Reports.bugType == StringConsts.contact.bugActuator ? "${Reports.actuatorType} : " : ""}${summaryController.text}";

    final Email email = Email(
      body: body,
      subject: summary,
      recipients: EmailDev.recipients,
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  @override
  Widget build(BuildContext context) {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;

    return Scaffold(
        appBar: appBar(title: StringConsts.contactUs),
        drawer: const NavDrawer(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ReportABugPage(
              summaryController: summaryController,
              bodyController: bodyController),
        ),
        floatingActionButton: Visibility(
          visible: showFab,
          child: Row(
            children: [
              const Expanded(flex: 1, child: SizedBox(width: 50)),
              Expanded(
                flex: 2,
                child: ListTile(
                    onTap: () {
                      setState(() {
                        sendEnquiry();
                      });
                    },
                    leading: const Icon(Icons.send),
                    title: Text(StringConsts.contact.send),
                    tileColor: ColorManager.tileColor,
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 2, color: Colors.transparent),
                        borderRadius: BorderRadius.circular(50))
                    // tileColor: Colors.lightBlue,
                    ),
              ),
              const Expanded(flex: 1, child: SizedBox(width: 50)),
            ],
          ),
        ));
  }
}
