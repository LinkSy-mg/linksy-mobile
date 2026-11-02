//! The bridge between the Flutter app and `linksy_core`. Everything the app
//! calls is in [`api`]; flutter_rust_bridge generates the Dart side from it.

pub mod api;
mod frb_generated;
mod cable;
mod files;
mod gallery;
mod heartbeats;
mod sessions;
