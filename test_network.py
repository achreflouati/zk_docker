import socket

ip = "192.168.1.201"
port = 4370

print(f"Testing connectivity to {ip}:{port} ...")

s = socket.socket()
s.settimeout(5)
result = s.connect_ex((ip, port))
s.close()

if result == 0:
    print("Port 4370: OPEN - reseau OK, probleme ZK protocol")
else:
    print(f"Port 4370: CLOSED/TIMEOUT (code {result}) - probleme reseau")
