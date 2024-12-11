client <- paws.compute::ec2()

groups <- client$describe_security_groups(GroupIds = "sg-077084ca6561f19ce")

definition <- crew.aws.batch::crew_definition_aws_batch(
  job_definition = "targets_pol_geo_ds",
  job_queue = "targets_ec2_queue"
)

definition$deregister()

definition$register(
  image = "r-base",
  platform_capabilities = "EC2",
  memory_units = "gigabytes",
  memory = 24,
  cpus = 2
)

definition$describe(active = TRUE)

definition$submit()

monitor <- crew.aws.batch::crew_monitor_aws_batch(
  job_definition = definition$job_definition,
  job_queue = "targets_ec2_queue"
)

monitor$running()
job1 <- monitor$submit(name = "job1", command = c("echo", "hello\nworld"))
job2 <- monitor$submit(name = "job2", command = c("echo", "job\nsubmitted"))
job2
