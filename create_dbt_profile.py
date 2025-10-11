import argparse
import os

parser = argparse.ArgumentParser(description="Create dbt profiles.yml file.")
parser.add_argument("--host", required=True)
parser.add_argument("--port", default=5439, type=int)
parser.add_argument("--dbname", required=True)
parser.add_argument("--user", required=True)
parser.add_argument("--password", required=True)

args = parser.parse_args()

profile_dir = os.path.expanduser("~/.dbt/")
if not os.path.exists(profile_dir):
    os.makedirs(profile_dir)

profile_content = """
redshift_e2e:
  target: dev
  outputs:
    dev:
      type: redshift
      method: password
      host: {host}
      port: {port}
      dbname: {dbname}
      schema: core
      user: {user}
      password: {password}
      threads: 4
""".format(
    host=args.host,
    port=args.port,
    dbname=args.dbname,
    user=args.user,
    password=args.password,
)

with open(os.path.join(profile_dir, "profiles.yml"), "w") as f:
    f.write(profile_content)

print("\nSuccessfully created ~/.dbt/profiles.yml!")
