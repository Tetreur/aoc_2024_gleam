import gleam/dict
import gleam/int
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
    index_fold(over: line, from: line_acc, with: fn(xmas, char, char_index) {
      case char {
        "X" -> {
          //io.debug(
          //"Found X at position "
          // <> int.to_string(char_index)
          //<> " at line "
          // <> int.to_string(line_index),
          //)

          let coordinates =
            grid_construct(
              from: the_matrix,
              line_index: line_index,
              char_index: char_index,
              size: 7,
            )
            |> to_coordinates()

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
            fn(xmas, direction) {
              xmas + check_coordinates(direction, coordinates)
            },
          )
        }
        _ -> xmas
      }
    })
  })
}

fn check_coordinates(
  direction: #(Int, Int),
  coordinates: dict.Dict(Int, dict.Dict(Int, String)),
) {
  // [
  //            0        1        2        3         4        5       6
  //    #(0, [#(0: *), #(1: .), #(2: .), #(3: * ), #(4: .), #(5 .), #(6: *)] ),
  //    #(1, [#(0: .), #(1: *), #(2: .), #(3: * ), #(4: .), #(5 *), #(6: .)] ),
  //    #(2, [#(0: .), #(1: .), #(2: *), #(3: * ), #(4: *), #(5 .), #(6: .)] ),
  //    #(3, [#(0: *), #(1: *), #(2: *), #(3: ⭐), #(4: *), #(5 *), #(6: *)] ),
  //    #(4, [#(0: .), #(1: .), #(2: *), #(3: * ), #(4: *), #(5 .), #(6: .)] ),
  //    #(5, [#(0: .), #(1: *), #(2: .), #(3: * ), #(4: .), #(5 *), #(6: .)] ),
  //    #(6, [#(0: *), #(1: .), #(2: .), #(3: * ), #(4: .), #(5 .), #(6: *)] ),
  // ]

  let #(x, y) = direction
  let result =
    list.range(1, 3)
    |> list.fold("", fn(string, step) {
      case dict.get(coordinates, step * x) {
        Ok(line_coordinate) -> {
          case dict.get(line_coordinate, step * y) {
            Ok(character) -> {
              string <> character
            }
            Error(_) -> panic
          }
        }
        Error(_) -> panic
      }
    })
  case result {
    "MAS" -> 1
    _ -> 0
  }
}

fn to_coordinates(
  matrix: List(List(String)),
) -> dict.Dict(Int, dict.Dict(Int, String)) {
  list.index_fold(
    over: matrix,
    from: dict.new(),
    with: fn(coordinates, line, line_index) {
      let size = list.length(line) / 2
      list.index_fold(
        over: line,
        from: coordinates,
        with: fn(coordinates, character, column_index) {
          case dict.get(coordinates, line_index - size) {
            Ok(sub_coordinate) -> {
              case dict.get(sub_coordinate, column_index - size) {
                Ok(_) -> panic as "We shouldn't get the same coordinate twice"
                Error(_) ->
                  dict.upsert(
                    in: coordinates,
                    update: line_index - size,
                    with: fn(_) {
                      dict.insert(
                        into: sub_coordinate,
                        for: column_index - size,
                        insert: character,
                      )
                    },
                  )
              }
            }
            Error(_) ->
              dict.insert(
                into: coordinates,
                for: line_index - size,
                insert: dict.new()
                  |> dict.insert(column_index - size, character),
              )
          }
        },
      )
    },
  )
}

// Construct a 7x7 grid matrix around "X" from the original matrix
fn grid_construct(
  from matrix: List(List(String)),
  line_index line_index: Int,
  char_index char_index: Int,
  size size: Int,
) -> List(List(String)) {
  matrix
  |> line_window(line_index, size)
  |> column_window(char_index, size)
}

fn column_window(
  matrix: List(List(String)),
  char_index: Int,
  size: Int,
) -> List(List(String)) {
  // [
  //  ["S", "S", "M", .. -< column index >- .. ".", ".", "."]
  //  ["A", "A", "X", .. -< column index >- .. ".", ".", "."]
  //  ["M", "M", "S", .. -< column index >- .. ".", ".", "."]
  // ]

  let big_size = { size / 2 } + 1
  let small_size = size / 2

  list.map(matrix, fn(line) {
    let #(first_half, second_half) = list.split(list: line, at: char_index)
    let filled_first_half = {
      case list.length(first_half) {
        l if l == small_size -> first_half
        l if l < small_size ->
          list.reverse(list.append(
            list.reverse(first_half),
            list.repeat(item: ".", times: small_size - l),
          ))
        l if l > small_size -> {
          let #(_, slice) = list.split(first_half, char_index - small_size)
          slice
        }
        _ -> panic
      }
    }

    let filled_second_half = {
      case list.length(second_half) {
        l if l == big_size -> second_half
        l if l < big_size ->
          list.append(second_half, list.repeat(item: ".", times: big_size - l))
        l if l > big_size -> {
          let #(slice, _) = list.split(second_half, big_size)
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
  size: Int,
) -> List(List(String)) {
  // [
  //    ..
  //    -< line_index >-
  //    [S, X, M], <-- line_index
  //    [M, A, S],
  //    [., ., .],
  //    [., ., .], <- Append list of point if necessary
  // ]
  let big_size = { size / 2 } + 1
  let small_size = size / 2
  let #(first_half, second_half) = list.split(list: matrix, at: line_index)
  let #(_, sliced_second_half) = list.split(list: second_half, at: small_size)
  let filled_second_half = case list.length(sliced_second_half) {
    l if l >= big_size -> second_half
    // include the line where X is matched
    l ->
      list.append(
        second_half,
        list.repeat(
          item: list.repeat(item: ".", times: 141),
          times: small_size - l,
        ),
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
  let #(_, sliced_first_half) =
    list.split(list: first_half, at: line_index - small_size)
  let filled_first_half = case list.length(sliced_first_half) {
    l if l > small_size -> panic
    l if l == small_size -> sliced_first_half
    l ->
      list.reverse(list.append(
        list.reverse(first_half),
        list.repeat(
          item: list.repeat(item: ".", times: 141),
          times: small_size - l,
        ),
      ))
  }

  list.append(filled_first_half, filled_second_half)
}
