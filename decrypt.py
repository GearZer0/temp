import base64
from Crypto.Cipher import AES


path_1="9UhFR102Duk7kPWjQIYtAQ==.8x/7z/X3yHJDEiqJqrEzX+LzNsF0GHXD4ICvAt+E/BvqpvkmSMDdYQkDnozXwbCD"
path_2="eVzhGinCI5eSKxKnuQRnVQ==.sjdr3IOtPXkpSAlIo+vYMqGxwJ8PE8NifWEyrWXFyG+KrOeGhdqiyWEX2zA1dhy1"
path_3="FJ6Jcqgtd9DzgDlPa8MpfQ==.iQ9DqIQii6rTQYwJ9c3qAP2BcElca/bbOuMiMYl5QV3ZU1zkOvnaoazTnGjFK+gIuDS74ur8LLZmd/RgtSAlbw=="
path_4="/sowYNFVbFqPC6Mpub5+8g==.kO4+xXlsOGrYTo+j/mmJ8UnEB7B+0XifxjN8N6QMAv2+VBD1A1n3g3sdPkVu0ovc"

URL ="7AYuuFRuD0hgmbSubZ7lTg==.weLKFjA1teLwjQ8U6r65vMUn+7VSrIA/DrE7uz4rzT5EFr0oKA/kjqy49YngtIzHeGFnGF5U2jFRVarBa1ZtK8tETF18fEgwudeOx567NeA+fjfUg544+QtqJnm3B+w8"
name_aes_key = "z3HHWl10+mE500ZL1VRrPw==.lvNaRxOo7K2owXkZ4lLl0OA7PAsb2tD2v20TyWSZEcU="
telegram_string = "93r0fcLku3BMtbO7ZfS6Ww==.OvA/ay+4I6droKvkQCrnosXPGweHXdFxtq17VOC/NF2p5G7on+ryCfYqWzaAsZ07"

def decrypt(enc_text):
    key,ci = enc_text.split(".")
    key = base64.b64decode(key)
    cip =base64.b64decode(ci)
    cipher = AES.new(key, AES.MODE_CBC, iv=cip[:16])
    return cipher.decrypt(cip[16:])
    
print(decrypt(path_1))
print(decrypt(path_2))
print(decrypt(path_3))
print(decrypt(path_4))
print(decrypt(URL))
print(decrypt(name_aes_key))
print(decrypt(telegram_string))
