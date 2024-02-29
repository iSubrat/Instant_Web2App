import sys

def check_updated():
  updated = False
  if updated:
    return True
  else:
    raise RuntimeError("Workflow execution halted due to an error")
    sys.exit(0)


check_updated()
