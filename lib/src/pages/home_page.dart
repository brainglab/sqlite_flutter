import 'dart:developer';

import 'package:sqlite_flutter/src/custom/constants.dart';
import 'package:sqlite_flutter/src/custom/library.dart';
import 'package:sqlite_flutter/src/handlers/sqlite_handler.dart';
import 'package:sqlite_flutter/src/models/country_model.dart';
import 'package:sqlite_flutter/src/providers/global_provider.dart';
import 'package:sqlite_flutter/src/widgets/custom_button.dart';
import 'package:sqlite_flutter/src/widgets/navbar_back.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  String mOnBoarding = "...";
  Countries mContries = Countries();
  SqliteHandler mSqliteHandler = SqliteHandler();

  @override
  void initState() {
    super.initState();

    getOnePreference(Preference.onboarding).then((dynamic result) {
      log("==> result: $result");
      mOnBoarding = result;
      setState(() {});

      if (result == "") {
        setOnePreference(Preference.onboarding, "true");
        log("==> mOnBoarding: $mOnBoarding");
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(FocusNode());
      getCountries();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    mRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    // Llamado cuando la ruta ha sido empujada y es visible.
    log('==> HomePage fue empujada');
  }

  @override
  void didPopNext() {
    // Llamado cuando la ruta superior ha sido extraída
    // y esta ruta es ahora visible.
    log('==> HomePage es ahora visible');
    getCountries();
  }

  getCountries() async {
    progressDialogShow(globalContext!);
    var db = await mSqliteHandler.getDb();
    var mResult = await db.query('countries');
    dialogDismiss();

    log("==> mResult: $mResult");

    mContries = Countries.fromJsonList(mResult);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavbarBack(
        backgroundColor: Constants.colorDark,
        backgroundButtonColor: Constants.colorDark,
        tinte: Tinte.dark,
        title: "Países",
        showBack: false,
        mListActions: [
          CustomButton(
            color: Colors.transparent,
            width: 50,
            callback: () async {
              globalContext = context;
              Provider.of<GlobalProvider>(context, listen: false).mCountry = Country();
              navigate(globalContext!, CustomPage.formCountry);
            },
            child: Icon(
              TablerIcons.plus,
              color: Constants.colorAccent,
              size: 25,
            ),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: RefreshIndicator(
          backgroundColor: Constants.colorAccent,
          color: Constants.colorLight,
          strokeWidth: 3,
          displacement: 80,
          onRefresh: () async {
            if (mounted) {
              globalContext = context;
              getCountries();
            }
          },
          child: SizedBox(
            height: double.infinity,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    mContries.items.isEmpty
                        ? Container(
                            margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                            width: double.infinity,
                            child: Text(
                              "No hay registros para mostrar",
                              style: Constants.textStyleGrayBold,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: mContries.items.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                color: Colors.white,
                                surfaceTintColor: Colors.white,
                                child: InkWell(
                                  onTap: () {
                                    globalContext = context;
                                    Provider.of<GlobalProvider>(context, listen: false).mCountry = mContries.items[index];
                                    navigate(globalContext!, CustomPage.formCountry);
                                  },
                                  borderRadius: BorderRadius.circular(15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: Container(
                                          width: 40,
                                          height: double.infinity,
                                          alignment: Alignment.center,
                                          child: Icon(
                                            TablerIcons.map_pin,
                                            color: Constants.colorDark,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 70,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                mContries.items[index].mCountryName!,
                                                style: Constants.textStyleBlackBold,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                "Código ${mContries.items[index].mCountryCode}",
                                                style: Constants.textStyleGraySmall,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 50,
                                        height: 70,
                                        child: Container(
                                          width: 40,
                                          height: double.infinity,
                                          alignment: Alignment.center,
                                          child: Icon(
                                            TablerIcons.chevron_right,
                                            color: Constants.colorDark,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
