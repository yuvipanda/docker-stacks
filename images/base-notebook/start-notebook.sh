#!/usr/bin/env python -u
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
import os
import sys
import shlex


# If we are in a JupyterHub, we pass on to `start-singleuser.sh` instead so it does the right thing
if "JUPYTERHUB_API_TOKEN" not in os.environ:
    print(
        "WARNING: using start-singleuser.sh instead of start-notebook.sh to start a server associated with JupyterHub.",
        file=sys.stderr,
    )
    os.execvp("/usr/local/bin/start-singleuser.sh", sys.argv[1:])


# Wrap everything in start.sh, no matter what
command = ["/usr/local/bin/start.sh"]

# If we want to survive restarts, tell that to start.sh
if os.environ.get("RESTARTABLE") == "yes":
    command.append("run-one-constantly")

# We always launch a jupyter subcommand from this script
command.append("jupyter")

# Launch the configured subcommand. Note that this should be a single string, so we don't split it
# We default to lab
jupyter_command = os.environ.get("DOCKER_STACKS_JUPYTER_CMD", "lab")
command.append(jupyter_command)

# Append any optional NOTEBOOK_ARGS we were passed in. This is supposed to be multiple args passed
# on to the notebook command, so we split it correctly with shlex
command += (
    []
    if "NOTEBOOK_ARGS" not in os.environ
    else shlex.split(os.environ["NOTEBOOK_ARGS"])
)

# Execute the command!
os.execvp(command[0], command)
