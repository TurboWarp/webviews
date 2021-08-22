struct Config {
  title: String,
  index: String,
  width: i32,
  height: i32,
  icon_pixels: Vec<u8>,
  icon_width: u32,
  icon_height: u32
}

fn load_config() -> Config {
  let config_data = std::fs::read("application_config.json").unwrap();
  let json: serde_json::Value = serde_json::from_slice(&config_data).unwrap();

  let icon_data: Vec<u8>;
  let icon_width: u32;
  let icon_height: u32;
  match std::fs::read("application_icon.dat") {
    Ok(data) => {
      icon_data = data;
      icon_width = json["iconWidth"].as_u64().unwrap() as u32;
      icon_height = json["iconHeight"].as_u64().unwrap() as u32;
    },
    Err(..) => {
      icon_data = vec![255, 0, 0, 255];
      icon_width = 1;
      icon_height = 1;
    }
  }

  Config {
    title: json["title"].as_str().unwrap().to_string(),
    index: json["index"].as_str().unwrap().to_string(),
    width: json["width"].as_i64().unwrap() as i32,
    height: json["height"].as_i64().unwrap() as i32,
    icon_pixels: icon_data,
    icon_width,
    icon_height
  }
}

fn run_config(config: Config) -> wry::Result<()> {
  use wry::{
    application::{
      event::{Event, WindowEvent},
      event_loop::{ControlFlow, EventLoop},
      window::{Icon, WindowBuilder},
      dpi::LogicalSize
    },
    webview::WebViewBuilder,
  };

  let event_loop = EventLoop::new();
  let window = WindowBuilder::new()
    .with_title(config.title)
    .with_inner_size(LogicalSize {
      width: config.width,
      height: config.height
    })
    .with_window_icon(Some(Icon::from_rgba(config.icon_pixels, config.icon_width, config.icon_height)?))
    .build(&event_loop)?;

  let _webview = WebViewBuilder::new(window)?
    .with_custom_protocol("webview".to_string(), move |requested_path| {
      let path = requested_path.replace("webview://", "");
      let content = std::fs::read(&path)?;
      if path.ends_with(".html") {
        Ok((content, "text/html".to_string()))
      } else if path.ends_with(".js") {
        Ok((content, "application/javascript".to_string()))
      } else {
        Ok((content, "application/octet-stream".to_string()))
      }
    })
    .with_url(format!("webview://{}", config.index).as_str())?
    .build()?;

  event_loop.run(move |event, _, control_flow| {
    *control_flow = ControlFlow::Wait;
    match event {
      Event::WindowEvent {
        event: WindowEvent::CloseRequested,
        ..
      } => *control_flow = ControlFlow::Exit,
      _ => (),
    }
  });
}

fn main() {
  run_config(load_config()).unwrap()
}
