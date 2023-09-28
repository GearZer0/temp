import base64
from Crypto.Cipher import AES
import re
import json

def decrypt(key,ci):
    
    key = base64.b64decode(key)
    cip =base64.b64decode(ci)
    cipher = AES.new(key, AES.MODE_CBC, iv=cip[:16])
    return cipher.decrypt(cip[16:])[:-26]
    



with open("sample1","rb") as f:
    bufferr = f.read()

#try:

regex = b'{"k": "(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?", "v": "(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?"'

result = re.search(regex,bufferr)

key, data = result.group().decode().split(",")

key= key.split(":")[1][2:-1]

data = data.split(":")[1][2:-1]

jsnn = decrypt(key,data).decode("utf-8") + "]}]}"
    
jsonn = json.loads(jsnn)
print("*******Config**********")
print("server: telegram bot")
    
for x in range(len(jsonn["data"])):
    dataa = jsonn["data"][x]

    token = dataa["token"]

    chat_it = dataa["chatId"]

    profile_name = dataa["profileName"]

    
    
    print("token: "+token)
    print("chat_id : "+chat_it)
    print("profile name: "+profile_name)
    print("***********************")
