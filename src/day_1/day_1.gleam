import gleam/dict
import gleam/io
import gleam/list
import gleam/string
import utils/parser.{parser}

pub fn part_1() {
  let right_record =
    parser("./src/day_1/input.txt")
    |> string.trim()
    |> string.split("\n")
    // [["1", "2"], ["3", "4"], ..]
    |> list.map(fn(line) { string.split(line, "   ") })
    |> list.fold(from: dict.new(), with: fn(acc, line) {
      // ["1", "2"]
      case line {
        [_, y] -> {
          case dict.get(acc, y) {
            Ok(y_value) ->
              dict.merge(into: acc, from: dict.from_list([#(y, y_value + 1)]))
            Error(_) -> dict.insert(into: acc, for: y, insert: 1)
          }
        }
        [_, ..] -> panic
        [] -> panic
      }
    })
  // io.debug(right_record)
}
