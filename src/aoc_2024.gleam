// import day_two/part_one
import day_1/day_1
import day_2/day_2
import day_3/day_3
import gleam/int
import gleam/io
import utils/greet

pub fn main() {
  greet.greet()
  io.println("---")
  day_1.part_1()
  io.println("D2-1 -> " <> int.to_string(day_2.part_1()))
  io.println("---")
  io.println("D3-1 -> " <> int.to_string(day_3.part_1()))
  io.println("D3-2 -> " <> int.to_string(day_3.part_2()))
  io.println("---")
}
