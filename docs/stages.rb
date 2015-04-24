#  Sample stages.rb
# __________________________________________________________
#

stage :production do
  user "dev"
  dir "/home/dev/project"
  parallel_runs 1
  host "10.1.1.1", dir: "/home/dev/project1", id: "project1", user: "dev1" ## default roles: ["first"]
  host "10.1.1.2", dir: "/home/dev/project2", id: "project2"
  host "10.1.1.3", roles: ["db"]
  host "10.1.1.4"  ## default roles: ["last"]
end
