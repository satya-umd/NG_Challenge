import os
bashcmd = "ffmpeg -i ./data/%s.mkv ./data_wav/%s.wav"
# print(class_name) if class_name!="" else ""
print(bashcmd)
os.system(bashcmd)

for file in os.listdir("data"):
    if file.endswith(".mkv"):
        file_name = file.split(".mkv")[0]
        os.system(bashcmd%(file_name, file_name))
