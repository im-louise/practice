'''
# main/py
# pip install fastapi
# pip install uvicorn[standard]
# 위에꺼 2개 설치
# 설치 완료 후 아래 터미널 명령어로 서버 on
uvicorn main:app --reload  >> main은 내가 지정한 파일명 / app는 내가 지정한 변수명

http://127.0.0.1:8000/docs 이 url 접속하면 문서화 되어 있음

'''
from fastapi import FastAPI
import random
import requests
from dotenv import load_dotenv
import os
from openai import OpenAI

load_dotenv()
app = FastAPI()

@app.get('/')
def home():
    return {'home':'sweet home'}

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


def send_message(chat_id, message):
    # .env 에서 'TELEGRAM_BOT_TOKEN'에 해당하는 값을 불러옴
    bot_token = os.getenv('TELEGRAM_BOT_TOKEN')

    URL = f'https://api.telegram.org/bot{bot_token}'
    body = {
        # 사용자 chat_id 는 어디서 가져옴..?
        'chat_id': chat_id,
        'text': message,
    }
    requests.get(URL + '/sendMessage', body)
    

# /telegram 라우팅으로 텔레그램 서버가 Bot에 업데이트가 있을 경우, 우리에게 알려줌
@app.post('/telegram')
async def telegram(request : requests):
    print('텔레그램에서 요청이 들어왔다!!!!')
    
    data = await request.json()
    print(data)
    sender_id = data['message']['chat']['id']
    input_msg = data['message']['text']

    client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
    
    res = client.responses.create(
        model='gpt-4.1-mini',
        input=input_msg,
        instructions='너는 초등학교 선생님이야. 모든 질문에 친절하게 설명해줘.',
        temperature=0
    )

    send_message(sender_id, res.output_text)

    return {'status': '굿'}

