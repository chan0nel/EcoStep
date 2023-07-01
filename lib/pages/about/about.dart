import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('О приложении'),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios)),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: _list.length,
          itemBuilder: (context, index) {
            if (_list[index].contains('http')) {
              int i = _list[index].indexOf('h');
              String temp = _list[index].substring(i, _list[index].length - 2);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: RichText(
                    text: TextSpan(
                  children: [
                    TextSpan(
                      text: _list[index].substring(0, i),
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    TextSpan(
                      text: temp,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : const Color(0xfff4a900),
                        decorationThickness: 1.5,
                        decorationColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.black
                                : const Color(0xfff4a900),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(Uri.parse(temp),
                              mode: LaunchMode.externalApplication);
                        },
                    ),
                    TextSpan(
                        text: ');',
                        style: TextStyle(
                            fontSize: 18,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color))
                  ],
                )),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(_list[index],
                  textAlign:
                      _list[index].contains('– ') ? null : TextAlign.justify,
                  style: const TextStyle(
                    fontSize: 18,
                  )),
            );
          },
        ));
  }

  final List<String> _list = [
    'Данное приложение является результатом работы над дипломным проектов в УО МГКЦТ. Автор проекта - Швакова Марина.',
    'Данное мобильное приложение позволяет составлять маршруты прогулки на велосипеде, пешком и на инвалидной коляске'
        ' с возможностью выбора дополнительных параметров и сохранение построенного маршрута в базу данных, просмотр'
        ' собственных сохраненных маршрутов и маршрутов других пользователей, комментирование маршрутов и'
        ' модерирование (со стороны пользователей) данных.',
    'В ходе разработки были применены следующие модули:',
    '– FlutterMap (https://docs.fleaflet.dev/);',
    '– Jawg.io (https://www.jawg.io/en/);',
    '– OpenRouteService (https://openrouteservice.org/);',
    '– OpenRouteService (https://openrouteservice.org/);',
    '– Firebase (https://firebase.google.com/);',
    '– Аватары от upklyak (https://www.freepik.com/free-vector/avatars-different-people-social-media_26177956.htm);',
    '– и другие.',
    'Минимальные технические требования для приложения «EcoStep»:',
    '– операционная система: Android 11;',
    '– размер ОЗУ: от 2 ГБ;',
    '– поддержка 3G, 4G;',
    '– поддержка GPS, Глонасс, A-GPS;',
    '– поддержка WiFi;',
    '– размер встроенной памяти: от 8 ГБ;',
    '– разрешение экрана: от 1920×1080;',
    '– дополнительные возможности: портретная ориентация экрана.',
    'Рекомендуемые технические требования к мобильным устройствам для работы приложения:',
    '– операционная система: Android 12 и выше;',
    '– размер ОЗУ: от 4 ГБ;',
    '– поддержка 3G, 4G;',
    '– поддержка GPS, Глонасс, A-GPS;',
    '– поддержка WiFi;',
    '– размер встроенной памяти: от 8 ГБ;',
    '– разрешение экрана: от 1920×1080;',
    '– емкость аккумуляторной батареи: от 3000 мАч;',
    '– дополнительные возможности: портретная ориентация экрана.',
  ];
}
