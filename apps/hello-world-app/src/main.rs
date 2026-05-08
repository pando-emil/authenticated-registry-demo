use hello_world_lib::greet;

#[tokio::main]
async fn main() {
    let message = greet("authenticated registry demo");
    println!("{message}");
}
