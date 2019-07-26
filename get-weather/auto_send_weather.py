#!/usr/bin/env python
# -*- coding: UTF-8 -*-

from wxpy import *
import requests
import pymysql
from threading import Timer

def get_city_code(city_name):
    db_parames = {
    'host': 'localhost',
    'user': 'root',
    'password': '123456',
    'database': 'city_code_info'
    }
    #连接数据库
    conn = pymysql.connect(**db_parames)

    #创建游标对象，增删改查都在游标上进行
    cursor = conn.cursor()

    #创建查询语句
    select_sql = "SELECT * FROM city_code where city_name='%s'"%(city_name)
    try:
        cursor.execute(select_sql)
        result = cursor.fetchall()
        for row in result:
            city_code = row[1]
        return city_code
    except:
        return "Error: unable fetch data!"

def get_weather(city_name,get_date_time=3):
    city_code = get_city_code(city_name)
    url = 'http://t.weather.sojson.com/api/weather/city/%s'%(city_code)
    header = {
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36'
    }
    response = requests.get(url,header)
    response.encoding = 'utf-8'
    weather = response.json()
    day = {1: '明天', 2: '后天', 3: '大后天'}
    weather_lst = []
    for num in range(get_date_time):
        City = weather["cityInfo"]["city"]
        Weatherganmao = weather["data"]["ganmao"]
        Weatherquality = weather["data"]["quality"]
        Weathershidu = weather["data"]["shidu"]
        Weatherwendu = weather["data"]["wendu"]
        Weatherpm25 = str(weather["data"]["pm25"])
        Weatherpm10 = str(weather["data"]["pm10"])
        Dateymd = weather["data"]["forecast"][num]["ymd"]
        Dateweek = weather["data"]["forecast"][num]["week"]
        Sunrise = weather["data"]["forecast"][num]["sunrise"]
        Sunset = weather["data"]["forecast"][num]["sunset"]
        Windfx = weather["data"]["forecast"][num]["fx"]
        Windf1 = weather["data"]["forecast"][num]["fl"]
        Weathertype = weather["data"]["forecast"][num]["type"]
        Weathernotice = weather["data"]["forecast"][num]["notice"]
        Weatherhigh = weather["data"]["forecast"][num]["high"]
        Weatherlow = weather["data"]["forecast"][num]["low"]
        if num == 0:
            result = '今日天气预报' + '\n' \
                + '日期： ' + Dateymd + ' ' + Dateweek + ' ' + City + '\n' \
                + '天气： ' + Weathertype + ' ' + Windfx + ' ' + Windf1 + ' ' + Weathernotice + '\n' \
                + '当前温度： ' + Weatherwendu + '℃' + '\n' \
                + '空气湿度： ' + Weathershidu + '\n' \
                + '温度范围： ' + Weatherlow + '' + '~' + '' + Weatherhigh + '\n' \
                + '污染指数： ' + 'PM2.5: ' + Weatherpm25 + ' ' + 'PM10: ' + Weatherpm10 + '\n' \
                + '空气质量： ' + Weatherquality + '\n' \
                + '日出时间： ' + Sunrise + '\n' \
                + '日落时间： ' + Sunset + '\n' \
                + '温馨提示： ' + Weatherganmao
        else:
            which_day = day.get(num,'超出范围')
            result = '\n' + which_day + ' ' + '天气预报' + '\n' \
                + '日期： ' + Dateymd + ' ' + Dateweek + ' ' + City + '\n' \
                + '天气： ' + Weathertype + ' ' + Windfx + ' ' + Windf1 + ' ' + Weathernotice + '\n' \
                + '温度范围： ' + Weatherlow + '' + '~' + '' + Weatherhigh + '\n' \
                + '日出时间： ' + Sunrise + '\n' \
                + '日落时间： ' + Sunset + '\n' \
                + '温馨提示： ' + Weatherganmao
        weather_lst.append(result)
        weather_str = ''
        for msg in weather_lst:
            weather_str += msg + '\n'

    return weather_str

def send_wx(city_name, who):
    bot = Bot(cache_path=True)
    #bot = Bot(console_qr=2, cache_path='botoo.pkl')
    my_friend = bot.friends().search(who)[0]
    msg = get_weather(city_name)
    try:
        my_friend.send(msg)
    except:
        my_friend = bot.friends().search('fei')[0]
        my_friend.send(u"发送失败")

def auto_send():
    city_name = '朝阳区'
    friend_list = ['王漫']

    for who in friend_list:
        send_wx(city_name,who)
    global timer
    timer = Timer(86400,auto_send)
    timer.start()

if __name__ == '__main__':
    timer = Timer(1,auto_send)
    timer.start()

