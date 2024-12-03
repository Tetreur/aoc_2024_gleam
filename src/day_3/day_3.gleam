import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/string
import utils/parser.{parser}

pub fn part_2() {
  // Regex ->
  // don't\(\)(mul\(\d{1,3},\d{1,3}\)|(.+?mul\(\d{1,3},\d{1,3}\))+?)

  parser("./src/day_3/input_part_2.txt")
  |> string.trim()
  |> sanitize()
  |> string.split("\n")
  |> list.map(parse_mul)
  |> list.map(sum_line)
  |> list.fold(0, fn(acc, x) { acc + x })
}

pub fn part_1() {
  // mul(271,938)^]'!why()mul(511,239)$+when()^@>>mul(97,300) ...

  parser("./src/day_3/input_part_1.txt")
  |> string.trim()
  |> string.split("\n")
  |> list.map(parse_mul)
  |> list.map(sum_line)
  |> list.fold(0, fn(acc, x) { acc + x })
}

fn parse_mul(line: String) -> List(List(Int)) {
  let assert Ok(regex) = regexp.from_string("mul\\(\\d{1,3},\\d{1,3}\\)")

  regexp.scan(with: regex, content: line)
  |> list.map(fn(match) {
    string.replace(match.content, each: "mul(", with: "")
    |> string.replace(each: ")", with: "")
    |> string.split(",")
    |> list.map(fn(character) {
      let result = int.parse(character)
      case result {
        Ok(number) -> number
        Error(e) -> {
          io.debug(e)
          io.debug(character)
          panic as "Couldn't parse character into a number"
        }
      }
    })
  })
}

fn sanitize(text: String) -> String {
  let assert Ok(regex) = regexp.from_string("don't\\(\\)(.|\n)*?do\\(\\)")
  regexp.replace(each: regex, in: text, with: "")
}

// [[1,2], [34, 1], ..]
fn sum_line(line: List(List(Int))) -> Int {
  list.fold(over: line, from: 0, with: fn(acc, sub_line) {
    case sub_line {
      [x, y] -> acc + x * y
      [_, ..] -> panic
      [] -> panic
    }
  })
}
