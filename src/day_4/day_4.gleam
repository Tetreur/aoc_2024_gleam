import gleam/io
import gleam/list.{index_fold}
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
    // io.println("Accumulator -> " <> int.to_string(line_acc))
    // io.println("Index       -> " <> int.to_string(line_index))
    // io.println("---------------")

    index_fold(over: line, from: 0, with: fn(xmas, char, char_index) {
      case char {
        "X" -> {
          //io.debug(
          //"Found X at position "
          // <> int.to_string(char_index)
          //<> " at line "
          // <> int.to_string(line_index),
          //)

          let sub_grid =
            grid_construct(
              from: the_matrix,
              line_index: line_index,
              char_index: char_index,
            )

          let xmas_count = {
            list.fold(
              [
                #(0, 1),
                #(0, -1),
                #(1, 0),
                #(-1, 0),
                #(1, 1),
                #(1, -1),
                #(-1, 1),
                #(-1, -1),
              ],
              xmas,
              fn(xmas, direction) { check_sub_grid(direction, sub_grid) },
            )
          }

          xmas
        }
        _ -> xmas
      }
    })

    line_acc
  })

  1
}

fn check_sub_grid(direction: #(Int, Int), sub_matrix: List(List(String))) {
  // [
  //       0  1  2  3  4  5  6
  //    0 [*, ., ., *, ., ., *]
  //    1 [., *, ., *, ., *, .]
  //    2 [., ., *, *, *, ., .]
  //    3 [*, *, *, X, *, *, *] <- Check from here
  //    4 [., ., *, *, *, ., .]
  //    5 [., *, ., *, ., *, .]
  //    6 [*, ., ., *, ., ., *]
  // ]
  list.range(1, 3) |> list.map(fn(step) { todo })
  //  list.index_fold(matrix, 0, fn(acc, line, line_index) { todo })
}

// Construct a 7x7 grid matrix around "X" from the original matrix
fn grid_construct(
  from matrix: List(List(String)),
  line_index line_index: Int,
  char_index char_index: Int,
) -> List(List(String)) {
  matrix
  |> line_window(line_index)
  |> column_window(char_index)
}

fn column_window(
  matrix: List(List(String)),
  char_index: Int,
) -> List(List(String)) {
  // [
  //  ["S", "S", "M" ] -< char_index, append with point if necessary >- [".", ".", "."]
  //  ["A", "A", "X" ] -< char_index, append with point if necessary >- [".", ".", "."]
  //  ["M", "M", "S" ] -< char_index, append with point if necessary >- [".", ".", "."]
  // ]

  list.map(matrix, fn(line) {
    let #(first_half, second_half) = list.split(list: line, at: char_index)
    let filled_first_half = {
      case list.length(first_half) {
        3 -> first_half
        l if l < 3 ->
          list.reverse(list.append(
            list.reverse(first_half),
            list.repeat(item: ".", times: 3 - l),
          ))
        l if l > 3 -> {
          let #(_, slice) = list.split(first_half, char_index - 3)
          slice
        }
        _ -> panic
      }
    }

    let filled_second_half = {
      case list.length(second_half) {
        4 -> second_half
        l if l < 4 ->
          list.append(second_half, list.repeat(item: ".", times: 4 - l))
        l if l > 4 -> {
          let #(slice, _) = list.split(second_half, 4)
          slice
        }
        _ -> panic
      }
    }
    list.append(filled_first_half, filled_second_half)
  })
}

fn line_window(
  matrix: List(List(String)),
  line_index: Int,
) -> List(List(String)) {
  // [
  //    ..
  //    -< line_index >-
  //    [S, X, M], <-- line_index
  //    [M, A, S],
  //    [., ., .],
  //    [., ., .], <- Append list of point if necessary
  // ]
  let #(first_half, second_half) = list.split(list: matrix, at: line_index)
  let #(_, sliced_second_half) = list.split(list: second_half, at: 3)
  let filled_second_half = case list.length(sliced_second_half) {
    l if l >= 4 -> second_half
    // include the line where X is matched
    l ->
      list.append(
        second_half,
        list.repeat(item: list.repeat(item: ".", times: 141), times: 3 - l),
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
  let #(_, sliced_first_half) = list.split(list: first_half, at: line_index - 3)
  let filled_first_half = case list.length(sliced_first_half) {
    l if l > 3 -> panic
    l if l == 3 -> sliced_first_half
    l ->
      list.reverse(list.append(
        list.reverse(first_half),
        list.repeat(item: list.repeat(item: ".", times: 141), times: 3 - l),
      ))
  }

  list.append(filled_first_half, filled_second_half)
}
