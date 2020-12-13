import csv
import cv2
import urllib
import m3u8
import streamlink
import subprocess
import ssl
from datetime import datetime, timedelta
from upload import upload_file_to_bucket


ssl._create_default_https_context = ssl._create_unverified_context
DATA_PATH = "/home/core/itmo-viud/Creepio/data"


def writeToCsv(timestamp, pic):
    with open('scrapped_pictures.csv', 'a', newline='') as csvfile:
        csvwriter = csv.writer(csvfile, delimiter=' ',
                                quotechar=',', quoting=csv.QUOTE_MINIMAL)
        csvwriter.writerow([timestamp, pic])
    
#writeToCsv("test1", "test2")

def addSecs(tm, secs):
    date_time_obj = datetime.strptime(tm, "%Y.%m.%d-%H.%M.%S.%f")
    return date_time_obj + timedelta(seconds=secs)

#a = addSecs("2020.11.04-04.31.26.790224", 0.000300)


def cutVideoIntoPictures(fileName, time):
    vidcap = cv2.VideoCapture(DATA_PATH + "/streams" + fileName)
    success,image = vidcap.read()
    count = 0
    fps = vidcap.get(cv2.CAP_PROP_FPS)
    # print("Frames per second using video.get(cv2.CAP_PROP_FPS) : {0}".format(fps))
    while success:
        # save frame as JPEG file
        frameTime = addSecs(time, count / fps)
        frameName = "data/" + "%s.frame_%d.jpg" % (fileName, count)
        cv2.imwrite(frameName, image)
        success,image = vidcap.read()
        count += 1
        writeToCsv(frameName, frameTime)

#cutVideoIntoPictures('test_stream.ts', '2020.11.03-22.58.23.000000')

def get_stream(url):
    """
    Get upload chunk url
    """
    streams = streamlink.streams(url)
    stream_url = streams["best"]

    m3u8_obj = m3u8.load(stream_url.args['url'])
    return m3u8_obj.segments[0]

#print(get_stream("https://youtu.be/zFKwLSDcNzc"))


def dl_stream(url, filename, chunks):
    """
    Download each chunks
    """
    filenames = []
    pre_time_stamp = 0
    for i in range(chunks + 1):
        stream_segment = get_stream(url)
        cur_time_stamp = stream_segment.program_date_time.strftime("%Y.%m.%d-%H.%M.%S.%f")
        cur_date = stream_segment.program_date_time.strftime("%Y.%m.%d")

        if pre_time_stamp == cur_time_stamp:
            pass
        else:
            print(cur_time_stamp)
            videoName = filename + '_' + str(cur_time_stamp) + '.ts'
            name =  "/streams" + videoName
            filenames.append(name)
            filepath = DATA_PATH + name
            file = open(filepath, 'ab+')
            with urllib.request.urlopen(stream_segment.uri) as response:
                html = response.read()
                file.write(html)

            upload_file_to_bucket(cur_date, filepath)
            pre_time_stamp = cur_time_stamp
            #cutVideoIntoPictures(videoName, cur_time_stamp)
    return filenames

# do this before running
# sudo apt install ffmpeg
def convertStreamToMP4(infile, outfile):
    subprocess.run(['ffmpeg', '-i', infile, outfile])


## url = "https://www.youtube.com/watch?v=eJ7ZkQ5TC08"
## dl_stream(url, "/live", 5)