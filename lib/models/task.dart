/* 
file yang berada di dalam folder model
biasa disebut dengan Data Class

biasanya data class dipresentasikan dengan bundling
dengan mengimport library Parcelize (ada di Android Native)
klo flutter udah langsung ada
*/
class Task {
  final String name;
  final int duration;
  final DateTime deadline;

  Task(
      {required this.name,
      required this.duration,
      required this.deadline});

//override untuk membuat suatu turunan dari objek
//salah satu contohnya function dalam function
  @override
  String toString() {
    return 'Task{name: $name, duration: $duration, deadline: $deadline}';
  }
}
