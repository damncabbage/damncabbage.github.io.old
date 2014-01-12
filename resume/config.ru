use Rack::Static,
  :urls => ["/images", "/fonts", "/js", "/screen.css"],
  :root => "."

map "/" do
  run lambda { |env|
    [
      200,
      {
        'Content-Type'  => 'text/html',
        'Cache-Control' => 'public, max-age=86400'
      },
      File.open('./index.html', File::RDONLY)
    ]
  }
end
