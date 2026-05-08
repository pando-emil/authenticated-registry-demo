pub fn greet(name: &str) -> String {
    format!("Hello, {name} from private registry lib!")
}

#[cfg(test)]
mod tests {
    use super::greet;

    #[test]
    fn greets_by_name() {
        assert_eq!(greet("Cargo"), "Hello, Cargo from private registry lib!");
    }
}
