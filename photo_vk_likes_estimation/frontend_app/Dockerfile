FROM photolikes-python-base

ENV UWSGI_WSGI_FILE=../frontend_app/wsgi.py

ENV UWSGI_SOCKET=0.0.0.0:12000 UWSGI_MASTER=1
ENV UWSGI_LAZY_APPS=1 UWSGI_WSGI_ENV_BEHAVIOR=holy

# Number of uWSGI workers and threads per worker (customize as needed):
ENV UWSGI_WORKERS=2 UWSGI_THREADS=4

# Start uWSGI
ENTRYPOINT ["uwsgi", "--show-config"]
