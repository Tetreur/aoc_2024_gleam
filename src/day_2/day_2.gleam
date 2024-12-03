import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import utils/parser.{parser}

pub type Direction {
  Increasing
  Deacreasing
}

pub fn part_1() -> Int {
  // "n9 7 6 2 1\n1 3 2 4 5\n ..."
  let input = parser("./src/day_2/input_part_1.txt")

  let report_list =
    // ["8 6 4 4 1", "1 3 6 7 9", ... ]
    string.split(string.trim(input), "\n")
    // [["8", "6", "4", "4", "1"], ["1", "3", "6", "7", "9"], ... ]
    |> list.map(fn(line) { string.split(line, " ") })
    // [[8, 6, 4, 4, 1], [1, 3, 6, 7, 9], ... ]
    |> list.map(fn(sub_list) {
      list.map(sub_list, fn(char) {
        case int.parse(char) {
          Ok(value) -> value
          Error(_) -> panic as "Error while parsing character to number"
        }
      })
    })

  let x =
    list.fold(
      over: report_list,
      from: dict.from_list([#("a", 0), #("u", 0)]),
      with: fn(acc, report) {
        let increment = fn(x) {
          case x {
            Some(i) -> i + 1
            None -> 1
          }
        }

        case is_report_safe(with: report, direction: None) {
          True -> dict.merge(acc, dict.upsert(acc, "a", increment))
          False -> dict.merge(acc, dict.upsert(acc, "u", increment))
        }
      },
    )
  let assert Ok(value) = dict.get(x, "a")
  value
}

fn is_report_safe(
  with report: List(Int),
  direction direction: Option(Direction),
) -> Bool {
  let rest: List(Int) = case list.rest(report) {
    Ok(rest) -> rest
    Error(_) -> panic as "Couldn't rest the report"
  }

  case report {
    [x, y, ..] -> {
      let difference = int.absolute_value(int.subtract(x, y))

      case difference {
        difference if difference > 3 -> False
        difference if difference < 1 -> False
        _ -> {
          let current_direction: Direction = case x, y {
            x, y if x < y -> Deacreasing
            x, y if x > y -> Increasing
            _, _ -> panic as "x == y shouldn't be possible at this point"
          }

          let safe: Bool = case current_direction, direction {
            c, Some(d) if c != d -> False
            _, Some(_) -> True
            _, None -> True
          }

          case safe {
            False -> False
            True ->
              is_report_safe(direction: Some(current_direction), with: rest)
          }
        }
      }
    }

    // Base case (emptied array)
    [_] -> True
    [] -> True
  }
}
// pub fn part_2() {
//   // "n9 7 6 2 1\n1 3 2 4 5\n ..."
//   let input = parser("./src/day_2/input_part_2.txt")

//   let report_list =
//     // ["8 6 4 4 1", "1 3 6 7 9", ... ]
//     string.split(string.trim(input), "\n")
//     // [["8", "6", "4", "4", "1"], ["1", "3", "6", "7", "9"], ... ]
//     |> list.map(fn(line) { string.split(line, " ") })
//     // [[8, 6, 4, 4, 1], [1, 3, 6, 7, 9], ... ]
//     |> list.map(fn(sub_list) {
//       list.map(sub_list, fn(char) {
//         case int.parse(char) {
//           Ok(value) -> value
//           Error(_) -> panic as "Error while parsing character to number"
//         }
//       })
//     })

//   let x =
//     list.fold(
//       over: report_list,
//       from: dict.from_list([#("a", 0), #("u", 0)]),
//       with: fn(acc, report) {
//         let increment = fn(x) {
//           case x {
//             Some(i) -> i + 1
//             None -> 1
//           }
//         }

//         case is_report_safe(with: report, direction: None, throw_count: 0) {
//           True -> dict.merge(acc, dict.upsert(acc, "a", increment))
//           False -> dict.merge(acc, dict.upsert(acc, "u", increment))
//         }
//       },
//     )
//   io.debug(x)
//   // let y = report_list |> list.partition(is_report_safe)
//   // io.debug(y)
// }

// fn is_report_safe(
//   direction direction: Option(Direction),
//   throw_count throw_count: Int,
//   with report: List(Int),
// ) -> Bool {
//   case throw_count {
//     x if x > 1 -> False
//     _ -> {
//       let rest: List(Int) = case list.rest(report) {
//         Ok(rest) -> rest
//         Error(_) -> panic as "Couldn't rest the report"
//       }

//       case report {
//         [x, y, ..report_rest] -> {
//           let difference = int.absolute_value(int.subtract(x, y))

//           case difference {
//             difference if difference > 3 || difference < 1 ->
//               is_report_safe(
//                 with: [x, ..report_rest],
//                 throw_count: throw_count + 1,
//                 direction: direction,
//               )
//             _ -> {
//               let current_direction: Direction = case x, y {
//                 x, y if x < y -> Deacreasing
//                 x, y if x > y -> Increasing
//                 _, _ -> panic as "x == y shouldn't be possible at this point"
//               }

//               let safe: Bool = case current_direction, direction {
//                 c, Some(d) if c != d ->
//                   is_report_safe(
//                     throw_count: throw_count + 1,
//                     with: [x, ..report_rest],
//                     direction: direction,
//                   )
//                 _, Some(_) -> True
//                 _, None -> True
//               }

//               case safe {
//                 False ->
//                   is_report_safe(
//                     direction: Some(current_direction),
//                     throw_count: throw_count + 1,
//                     with: [x, ..report_rest],
//                   )
//                 True ->
//                   is_report_safe(
//                     direction: Some(current_direction),
//                     throw_count: throw_count,
//                     with: rest,
//                   )
//               }
//             }
//           }
//         }

//         // Base case (emptied array)
//         [_] -> True
//         [] -> True
//       }
//     }
//   }
// }
