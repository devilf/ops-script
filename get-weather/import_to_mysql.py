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

#表存在，就删除
cursor.execute("DROP TABLE IF EXISTS city_code")

#建表语句
create_table_sql = """CREATE TABLE `city_code` (
  `city_name` varchar(20) DEFAULT NULL,
  `city_code` varchar(25) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
"""
#建表
cursor.execute(create_table_sql)

#插入数据
with open('city_for_code.json','r+',encoding='utf-8') as f:
    origin_data = f.readlines()
    current_data = eval(origin_data[0])
    #print(current_data.get('北京','Not Exists.'))
    for name, code in current_data.items():
        sql = """INSERT INTO city_code(city_name, city_code) VALUES ('%s', '%s')""" % (name, code)
        try:
            cursor.execute(sql)
        except:
            conn.rollback()
    conn.commit()
    conn.close()
