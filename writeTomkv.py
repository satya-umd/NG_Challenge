import csv
import subprocess, os

classes= {
"/m/02rlv9":2,
"/m/0912c9":3,
"/t/dd00130":4,
"/m/01yrx":5,
"/m/07rpkh9":7,
"/m/09xqv":8,
"/m/0bt9lr":9,
"/m/07sx8x_":12,
"/m/0g6b5":13,
"/m/09ld4":14,
"/m/03k3r":15,
"/m/03p19w":17,
"/m/04229":18,
"/m/032n05":19,
"/m/09d5_":21,
"/m/04qvtq":22,
"/m/01d380":23,
"/m/07bgp":24,
"/m/0h9mv":25,
"/t/dd00048":27,
"/m/09x0r":28
}
count={}
class_list = list(classes.keys())
def convert(st,st1=""):

    timeS = int(float(st))
    if(st1!=""):
        timeS = int(float(st1))-timeS
    return str(int(timeS/60))+":"+str(timeS%60)

input_file = csv.DictReader(open("class_labels_indices.csv"))
with open("class_labels_indices.csv") as infile:
    reader = csv.reader(infile)
    classeDict = {rows[1]:rows[2] for rows in reader}

input_file1 = csv.DictReader(open("unbalanced_train_segments.csv"))
with open("unbalanced_train_segments.csv") as infile1:
    reader1 = csv.reader(infile1)
    # filesDict = {rows[0]:rows[3] if len(rows)>=3 else None for rows in reader1}
    for rows in reader1:
        if len(rows)<3:
            continue
        class_name=""
        flag = False
        for x in range(3,len(rows)):
            if rows[x] in class_list:
                class_name+=str(classes[rows[x]])+","
                # if("/m/01d380"==rows[x]):
                #     print(rows)
                if(classes[rows[x]] in count):
                    count[classes[rows[x]]]+=1
                    if(count[classes[rows[x]]] < 20):
                        flag = True
                else:
                    count[classes[rows[x]]]=1
        if class_name!="" and flag:
            class_name += "_"+str(rows[0])
            bashcmd = "ffmpeg $(youtube-dl -g 'https://www.youtube.com/watch?v=%s' | sed 's/.*/-ss %s -i &/') -t %s -c copy ./data/classes_%s.mkv"%(rows[0],convert(rows[1]),convert(rows[1],rows[2]), class_name)
            # print(class_name) if class_name!="" else ""
            print(bashcmd)
            os.system(bashcmd)

print(count)
