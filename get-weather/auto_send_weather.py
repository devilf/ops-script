from wxpy import *
import requests


url = 'http://t.weather.sojson.com/api/weather/city/101010600'
header = {
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36'
}
def get_weather(city,date):
    response = requests.get(url,header)
    response.encoding = 'utf-8'
    weather = response.json()
    City = weather["cityInfo"]["city"]
    Dateymd = weather["data"]["forecast"][0]["ymd"]
    Dateweek = weather["data"]["forecast"][0]["week"]
    Sunrise = weather["data"]["forecast"][0]["sunrise"]
    Sunset = weather["data"]["forecast"][0]["sunset"]
    Windfx = weather["data"]["forecast"][0]["fx"]
    Windf1 = weather["data"]["forecast"][0]["fl"]
    Weathertype = weather["data"]["forecast"][0]["type"]
    Weathernotice = weather["data"]["forecast"][0]["notice"]
    Weatherganmao = weather["data"]["ganmao"]
    Weatherquality = weather["data"]["quality"]
    Weathershidu = weather["data"]["shidu"]
    Weatherwendu = weather["data"]["wendu"]
    Weatherpm25 = str(weather["data"]["pm25"])
    Weatherpm10 = str(weather["data"]["pm10"])
    Weatherhigh = weather["data"]["forecast"][0]["high"]
    Weatherlow = weather["data"]["forecast"][0]["low"]

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

bot = Bot()
bot = Bot(console_qr=2, cache_path='botoo.pkl')


