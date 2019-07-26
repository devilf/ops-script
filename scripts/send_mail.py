#!/usr/bin/env python
# -*- coding: UTF-8 -*-


import smtplib
import sys
from email.header import Header
from email.mime.text import MIMEText



class SendMail():
    def __init__(self,mail_host,mail_user,mail_pass,sender,receivers,content,title):
        self.mail_host = mail_host
        self.mail_user = mail_user
        self.mail_pass = mail_pass
        self.sender = sender
        self.receivers = receivers
        self.content = content
        self.title = title

    def sendEmail(self):
        msg = MIMEText(content,'plain','utf-8')
        msg['From'] = "{}".format(sender)
        msg['To'] = ",".join(receivers)
        msg['Subject'] = title
        try:
            smtpObj = smtplib.SMTP_SSL(mail_host,465)
            smtpObj.login(mail_user,mail_pass)
            smtpObj.sendmail(sender,receivers,msg.as_string())
            print('mail send successful.')
        except smtplib.SMTPException as e:
            print(e)

if __name__ == '__main__':
    mail_host = "smtp.xxx.com"
    mail_user = "xxxx@yyyy.com"
    mail_pass = 'PassW0rd123456'
    sender = 'xxxx@yyyy.com'
    receivers = str(sys.argv[1]).split(',')
    content = sys.argv[2]
    title = sys.argv[3]
    m = SendMail(mail_host,mail_user,mail_pass,sender,receivers,content,title)
    m.sendEmail()


