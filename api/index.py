import os
import sys

# Ensure backend directory is first in python path for Vercel Serverless
backend_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'backend'))
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

try:
    os.chdir(backend_dir)
except Exception:
    pass

from main import app
