import gleam/dict
import gleam/int
import gleam/io
import gleam/list.{index_fold, index_map}
import gleam/result
import gleam/string
import utils/parser.{parser}

pub fn part_1() -> Int {
  // [
  //  [X, M, A, S, ..],
  //  [M, M, X, S, ..],
  //  [A, M, A, A, ..],
  //  [S, X, A, S, ..],
  //  ..
  // ]
  let the_matrix =
    parser("./src/day_4/input_part_1.txt")
    |> string.trim()
    |> string.split("\n")
    |> list.map(fn(line) { string.split(line, "") })

  index_fold(over: the_matrix, from: 0, with: fn(line_acc, line, line_index) {
    io.println("Accumulator -> " <> int.to_string(line_acc))
    io.println("Index       -> " <> int.to_string(line_index))
    io.println("---------------")

    index_fold(over: line, from: 0, with: fn(char_acc, char, char_index) {
      case char {
        "X" -> {
          io.debug(
            "Found X at position "
            <> int.to_string(char_index)
            <> " at line "
            <> int.to_string(line_index),
          )

          let grid =
            grid_construct(
              from: the_matrix,
              line_index: line_index,
              char_index: char_index,
            )
          io.debug(grid)

          char_acc
        }
        _ -> char_acc
      }
    })

    line_acc
  })

  1
}

// Construct a 7x7 grid matrix around "X" from the original matrix
fn grid_construct(
  from matrix: List(List(String)),
  line_index line_index: Int,
  char_index char_index: Int,
) -> List(List(String)) {
  matrix
  |> line_window(line_index)
  |> char_window(char_index)
}

fn char_window(
  matrix: List(List(String)),
  char_index: Int,
) -> List(List(String)) {
  // [
  //  [S, X, ]
  // ]
  []
}

fn line_window(
  matrix: List(List(String)),
  line_index: Int,
) -> List(List(String)) {
  // [
  //    ..
  //    -< line_index - n >-
  //    [S, X, M], <-- line_index
  //    [M, A, S],
  //    [., ., .],
  //    [., ., .], <- Append list of point if necessary
  // ]
  let #(first_half, second_half) = list.split(list: matrix, at: line_index)
  let filled_second_half = case list.length(second_half) {
    l if l >= 4 -> second_half
    // include the line where X is matched
    l ->
      list.append(
        second_half,
        list.repeat(item: list.repeat(item: ".", times: 3), times: 4 - l),
      )
  }

  //[
  //    [., ., .], <- prepend list of point if necessary
  //    [., ., .],
  //    [M, A, A],
  //    [S, X, M],
  //    -< line_index + n >-
  //    ..
  // ]
  let filled_first_half = case list.length(first_half) {
    l if l >= 3 -> first_half
    l ->
      list.reverse(list.append(
        list.reverse(first_half),
        list.repeat(item: list.repeat(item: ".", times: 3), times: 3 - l),
      ))
  }

  let grid = list.append(filled_first_half, filled_second_half)
  grid
}
