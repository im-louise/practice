'''
# main/py
# pip install fastapi
# pip install uvicorn[standard]
# 위에꺼 2개 설치
# 설치 완료 후 아래 터미널 명령어로 서버 on
uvicorn main:app --reload  >> main은 내가 지정한 파일명 / app는 내가 지정한 변수명
'''
from fastapi import FastAPI
import random
import requests
app = FastAPI()

@app.get('/hi')
def hi():
    return {'status':'베리굿'}

@app.get('/lotto')
def lotto():
    return {'numbers':random.sample(range(1, 46), 6)
    }

@app.get('/gogogo')
def gogogo():
    # 메세지 보내기
    bot_token = '7949424324:AAE35aP13bPFLPQFZueb3hcRdLRuC-EONO8'
    URL = f'https://api.telegram.org/bot{bot_token}'
    body = {
    'chat_id': 8459117190, 
    'text': '안녕?자동으로 보내지는거야.',
    }
    requests.get(URL + '/sendMessage', body)
    return {'status':'gogogo'}

