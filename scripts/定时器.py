from threading import Timer

def say():
    print('Hello World!')
    global timer
    timer = Timer(2,say)
    timer.start()


timer = Timer(1,say)
timer.start()
