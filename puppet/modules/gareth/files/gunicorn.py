bind = 'unix:/var/run/gunicorn/gareth.sock'
worker_class = 'gevent'
workers = 1 # @todo Increase this in the future for testing?
timeout = 60
log_file = '/var/log/gunicorn/gareth-worker.log'
