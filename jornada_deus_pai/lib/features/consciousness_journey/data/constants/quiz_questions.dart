import '../../domain/models/quiz_question.dart';

/// The 7 consciousness quiz questions
const List<QuizQuestion> consciousnessQuizQuestions = [
  QuizQuestion(
    id: 1,
    text: 'Você sente que passou mais tempo tentando agradar Deus do que realmente conhecendo Ele?',
    options: ['sim', 'às vezes', 'não'],
  ),
  QuizQuestion(
    id: 2,
    text: 'Mesmo orando por anos, você ainda sente Deus distante emocionalmente?',
    options: ['sim', 'às vezes', 'não'],
  ),
  QuizQuestion(
    id: 3,
    text: 'Você já sentiu culpa por não conseguir manter uma vida espiritual perfeita?',
    options: ['sim', 'às vezes', 'não'],
  ),
  QuizQuestion(
    id: 4,
    text: 'Quando pensa em Deus, a primeira sensação é paz… ou cobrança?',
    options: ['paz', 'às vezes cobrança', 'cobrança'],
  ),
  QuizQuestion(
    id: 5,
    text: 'Você sente que conhece Deus como Criador… mas não como Pai?',
    options: ['sim', 'às vezes', 'não'],
  ),
  QuizQuestion(
    id: 6,
    text: 'Você já teve a sensação de que está fazendo tudo "certo" espiritualmente… mas continua vazio?',
    options: ['sim', 'às vezes', 'não'],
  ),
  QuizQuestion(
    id: 7,
    text: 'Se Jesus chamava Deus de Pai… por que isso ainda parece tão distante para você?',
    options: ['sim', 'às vezes', 'não'],
  ),
];
