import cv2
import time
import datetime as dt
import sys
import dropbox
from dropbox.files import WriteMode
from dropbox.exceptions import ApiError, AuthError
# Access token
TOKEN = 'DQoIUNUAH7EAAAAAAAAHdqLXXoiJkPlK_DnOmhTN6EYFeRj7v1kDzMe3_OLD-gig'

# Uploads contents of LOCALFILE to Dropbox
def backup():
    with open(LOCALFILE, 'rb') as f:
        print("Uploading " + LOCALFILE + " to Dropbox as " + BACKUPPATH + "...")
        try:
            dbx.files_upload(f.read(), BACKUPPATH, mode=WriteMode('overwrite'))
        except ApiError as err:
            if (err.error.is_path() and
                    err.error.get_path().error.is_insufficient_space()):
                sys.exit("ERROR: Cannot back up; insufficient space.")
            elif err.user_message_text:
                print(err.user_message_text)
                sys.exit()
            else:
                print(err)
                sys.exit()


       
   
def DownLoad():
    try:
        dbx.users_get_current_account()
    except AuthError as err:
        sys.exit(
            "ERROR: Invalid access token; try re-generating an access token from the app console on the web.")
    print("Download: "+LOCALFILE)
    backup()

    print("Done!")
# When program is started
if __name__ == '__main__':
    status = 'motion'
    idle_time = 0
    if (len(TOKEN) == 0):
        sys.exit("ERROR: Looks like you didn't add your access token. Open up backup-and-restore-example.py in a text editor and paste in your token in line 14.")
    print("Creating a Dropbox object...")
    dbx = dropbox.Dropbox(TOKEN)
    back = None
    ts = 0
    foto = False
    video = cv2.VideoCapture(0)
    # LOOP
    while True:
        ok, frame = video.read()
        gray = cv2.cvtColor(frame,cv2.COLOR_BGR2GRAY)
        gray = cv2.GaussianBlur(gray,(21,21),0)
        if back is None:
            back = gray
        if status == 'motion':
            frame_delta = cv2.absdiff(back,gray)
            thresh = cv2.threshold(frame_delta,25,255,cv2.THRESH_BINARY)[1]
            thresh = cv2.dilate(thresh,None,iterations=2)
            _,cnts,hierarchy = cv2.findContours(thresh,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)
            if len(cnts) != 0:
                largest = 0
                for i in range(len(cnts)):
                    if i != 0 & int(cv2.contourArea(cnts[i])) > int(cv2.contourArea(cnts[largest])):
                        largest = i
                if cv2.contourArea(cnts[largest]) > 500:
                    status = 'tracking'
        if status == 'tracking':
            if foto==False:
                timestamp = time.time()
                st = dt.datetime.fromtimestamp(timestamp).strftime('%d%H%M%S')
                name = "img" + str(st) + ".jpg"
                cv2.imwrite(name,frame)
                LOCALFILE = name
                BACKUPPATH = '/Foto/'+name
                DownLoad()
                foto = True
        cv2.imshow("Camera",frame)
        if idle_time >= 2:
            status = 'motion'
            idle_time = 0
            back = None
            ok = None
            foto = False
        idle_time += 1
        if cv2.waitKey(1) & 0xFF == ord("q") or cv2.getWindowProperty('Camera',0) == -1:
            break
video.release()
cv2.destroyAllWindows()
