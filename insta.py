# python insta.py -l load_path -s store_path

import cv2
import argparse
import numpy as np
import os
import imghdr

def get_arguments():
    ap = argparse.ArgumentParser()
    
    try:
        ap.add_argument('-l', '--load', required=True,
                    help='load path for loading img')
    except:
         return 60
    try:
        ap.add_argument('-s', '--store', required=True,
                    help='load path for storing img')
        args = vars(ap.parse_args())
    except:
        return 50

    if not args['load'] or not args['store']:
        ap.error("Please enter path")
    return args


def main():

    while True:
        args = get_arguments()

        if args == 50:
            print("ERROR 50: Parameter input error ")
            return 50
        if args == 60:
            print("ERROR 60: Parameter output error ")
        else:
            img = str(args['load'])

        #Is there a file in the specified path
        if os.path.isfile(img) == False:
            #print("ERROR 100: File not exists")
            return 100
        
        #The input file is not an image
        if imghdr.what(img) == None:
            #print ("ERROR 101: The file is not an image.")
            return 101
        
        try:
            image = cv2.imread(img)
        except BaseException:
           # print("ERROR 103: Error reading image")
            return 103

        try:
            frame_to_thresh = image.copy()
            thresh = cv2.inRange(frame_to_thresh, (1, 1, 1), (250, 250, 250))

            kernel = np.ones((5, 5), np.uint8)
            mask = cv2.morphologyEx(thresh, cv2.MORPH_OPEN, kernel)
            mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)

            # find contours in the mask and initialize the current
            cnts = cv2.findContours(mask.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[-2]
        except:
          #  print("ERROR 104: File processing error")
            return 104

        # only proceed if at least one contour was found
        if len(cnts) > 0:
            try:
                c = max(cnts, key=cv2.contourArea)
                x, y, w, h = cv2.boundingRect(c)
                crop_img = image[y+1:y + h, x:x + w]
            except:
              #  print("ERROR 104: File processing error")
                return 104
            try:
                cv2.imwrite(str(args['store']), crop_img)
            except:
               # print("ERROR 105: Error save file")
                return 105
            
        return 0
        # else error no image detected


if __name__ == '__main__':
    main()

