import '../models/quiz_model.dart';

/// Тест/Ойын сервисі
class QuizService {
  /// Тест санаттары мен сұрақтар
  List<QuizCategory> getCategories() {
    return const [
      QuizCategory(
        title: 'Қазақстан тарихы',
        description: 'Қазақстан тарихы бойынша білімдеріңізді тексеріңіз',
        questions: [
          QuizQuestion(
            question: 'Қазақ хандығы қай жылы құрылды?',
            options: ['1456 ж.', '1465 ж.', '1470 ж.', '1480 ж.'],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'Абай Құнанбайұлы қай жылы дүниеге келді?',
            options: ['1835 ж.', '1840 ж.', '1845 ж.', '1850 ж.'],
            correctIndex: 2,
          ),
          QuizQuestion(
            question: 'Қазақстан тәуелсіздігін қай жылы жариялады?',
            options: ['1989 ж.', '1990 ж.', '1991 ж.', '1992 ж.'],
            correctIndex: 2,
          ),
          QuizQuestion(
            question: 'Қазақстанның бірінші астанасы қай қала болды?',
            options: ['Алматы', 'Орынбор', 'Қызылорда', 'Астана'],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'Алтын адам қай жерден табылды?',
            options: ['Отырар', 'Есік', 'Тараз', 'Түркістан'],
            correctIndex: 1,
          ),
        ],
      ),
      QuizCategory(
        title: 'Университет туралы',
        description: 'Абай ҚазҰПУ туралы не білесіз?',
        questions: [
          QuizQuestion(
            question: 'Абай ҚазҰПУ қай жылы құрылды?',
            options: ['1928 ж.', '1930 ж.', '1935 ж.', '1940 ж.'],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'Университет қай қалада орналасқан?',
            options: ['Астана', 'Алматы', 'Шымкент', 'Қарағанды'],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'Университет кімнің атымен аталады?',
            options: ['Әл-Фараби', 'Абай', 'Шоқан', 'Ыбырай'],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'ҚазҰПУ қандай университет?',
            options: [
              'Техникалық',
              'Медициналық',
              'Педагогикалық',
              'Заң',
            ],
            correctIndex: 2,
          ),
        ],
      ),
      QuizCategory(
        title: 'Жалпы білім',
        description: 'Жалпы білім тесті — қызықты сұрақтар',
        questions: [
          QuizQuestion(
            question: 'Жердің Күннен орташа қашықтығы шамамен қанша?',
            options: [
              '100 млн км',
              '150 млн км',
              '200 млн км',
              '250 млн км',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'Судың химиялық формуласы қандай?',
            options: ['CO2', 'H2O', 'O2', 'NaCl'],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'Пифагор теоремасы қай фигураға қатысты?',
            options: [
              'Шеңбер',
              'Тік бұрышты үшбұрыш',
              'Квадрат',
              'Параллелограмм',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'Интернетті кім ойлап тапты?',
            options: [
              'Тим Бернерс-Ли',
              'Стив Джобс',
              'Билл Гейтс',
              'Марк Цукерберг',
            ],
            correctIndex: 0,
          ),
          QuizQuestion(
            question: 'Қазақстанның ең үлкен көлі қайсы?',
            options: ['Балқаш', 'Каспий теңізі', 'Арал', 'Алакөл'],
            correctIndex: 1,
          ),
        ],
      ),
    ];
  }
}
