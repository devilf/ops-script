import pymysql

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
name = '滕州市'
sql = "SELECT * FROM city_code where city_name='%s'"%(name)
cursor.execute(sql)
results = cursor.fetchall()
for row in results:
    city_code = row[1]
    print(city_code)
