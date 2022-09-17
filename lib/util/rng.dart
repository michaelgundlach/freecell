/// Clone of Tynker Freecell RNG implementation so race codes give the same game.
/// https://www.tynker.com/ide/v3?p=61a7fcce188d036257157884
class RNG {
  RNG(this.seed) {
    x = seed;
    _randomNumberStream = [x];
  }
  final int seed;
  late int x;
  late final List<int> _randomNumberStream;

  pickRandomBetweenOneAnd(topNumber) {
    x = (x ^ (x << 13).toSigned(32)).toSigned(32);
    x = (x ^ (x >> 17).toSigned(32)).toSigned(32);
    x = (x ^ (x << 5).toSigned(32)).toSigned(32);
    _randomNumberStream.add(x);
    return (x.abs() % topNumber) + 1;
  }
}
