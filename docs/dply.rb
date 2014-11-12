repo "git@github.com:user/repo.git"
strategy :git
target :production
#create directories in shared/ dir
shared_dirs [
 "public/assets" 
]

# target(relative to repo root) => source(relative to shared/ dir)
dir_map ({
  "log" => "log",
  "tmp" => "tmp",
  "public/assets" => "public/assets"
})

# target(relative to repo root) => source(relative to config/ dir)
config_map ({
  "config/database.yml" => "database.yml",
  "config/some_config" => "some_config"
})

config_download_url "http://127.0.0.1/prefix"
config_skip_download ["some_config"]
