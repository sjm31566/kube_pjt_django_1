FROM python:3.9-slim
WORKDIR /app
# 필요한 패키지 설치
RUN apt-get update && apt-get install -y build-essential libpq-dev && rm -rf /var/lib/apt/lists/*
# 의존성 설치
COPY mysite/requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt
# 소스 복사
COPY . /app/
# Django 설정
WORKDIR /app/mysite
RUN python manage.py makemigrations && python manage.py migrate && python manage.py collectstatic --noinput
CMD ["python3", "manage.py", "runserver", "0.0.0.0:8000"]
EXPOSE 8000
