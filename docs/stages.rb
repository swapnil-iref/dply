stage :production do
  user "dev"
  ask :user # exported to env as DPLY_USER
  deploy_dir "/home/dev/project"
  parallel_runs 1
  host "10.1.1.1", deploy_dir: "/home/dev/project1", id: "project1", user: "dev1"
  host "10.1.1.2", deploy_dir: "/home/dev/project2", id: "project2"
end
