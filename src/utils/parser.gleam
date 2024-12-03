import simplifile.{read}

pub fn parser(path: String) -> String {
  let assert Ok(file) = read(from: path)
  file
}
