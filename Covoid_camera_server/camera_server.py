# USAGE
# python object_tracker.py --prototxt deploy.prototxt --model res10_300x300_ssd_iter_140000.caffemodel

# import the necessary packages
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
from tensorflow.keras.preprocessing.image import img_to_array
from tensorflow.keras.models import load_model
from pyimagesearch.centroidtracker import CentroidTracker
from imutils.video import VideoStream
import numpy as np
import face_recognition
import argparse
import imutils
import time
import cv2
import pickle
import base64
import random
from cloudant.client import Cloudant
from datetime import datetime
from datetime import date

def list_prediction(pred_list, label):
	count = 0
	for pred in pred_list:
		if pred == label:
			count += 1

	return count/len(pred_list)

# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-p", "--prototxt", required=True,
	help="path to Caffe 'deploy' prototxt file")
ap.add_argument("-m", "--model", required=True,
	help="path to Caffe pre-trained model")
ap.add_argument("-c", "--confidence", type=float, default=0.5,
	help="minimum probability to filter weak detections")
ap.add_argument("-d", "--maskmodel", type=str,
    default="mask_detector.model",
    help="path to trained face mask detector model")
ap.add_argument("-e", "--encodings", required=True,
	help="path to serialized db of facial encodings")

args = vars(ap.parse_args())

# initialize our centroid tracker and frame dimensions
ct = CentroidTracker()
maskNet = load_model(args["maskmodel"])
(H, W) = (None, None)

# load our serialized model from disk
print("[INFO] loading model...")
net = cv2.dnn.readNetFromCaffe(args["prototxt"], args["model"])

data = pickle.loads(open(args["encodings"], "rb").read())

#Connect to db
client = Cloudant.iam("4f50a42f-2cbe-410c-97ef-d8cfd286514d-bluemix", "o65IeWCGzjKETjI49-E6pJGQ-b05xfAz_axsiJA-UTWX")
session = client.connect()
my_database = client['image_captures']
image_database = client['images']

# initialize the video stream and allow the camera sensor to warmup
print("[INFO] starting video stream...")
vs = VideoStream(src=0).start()

time.sleep(2.0)

# loop over the frames from the video stream
global_objects = {}
global_objects_set = set()
while True:
	# read the next frame from the video stream and resize it
	frame = vs.read()


	frame = imutils.resize(frame, width=400)

	# if the frame dimensions are None, grab them
	if W is None or H is None:
		(H, W) = frame.shape[:2]

	# construct a blob from the frame, pass it through the network,
	# obtain our output predictions, and initialize the list of
	# bounding box rectangles
	blob = cv2.dnn.blobFromImage(frame, 1.0, (W, H),
		(104.0, 177.0, 123.0))
	net.setInput(blob)
	detections = net.forward()
	rects = []

	# loop over the detections
	for i in range(0, detections.shape[2]):
		# filter out weak detections by ensuring the predicted
		# probability is greater than a minimum threshold
		if detections[0, 0, i, 2] > args["confidence"]:
			# compute the (x, y)-coordinates of the bounding box for
			# the object, then update the bounding box rectangles list
			box = detections[0, 0, i, 3:7] * np.array([W, H, W, H])
			rects.append(box.astype("int"))

			# draw a bounding box surrounding the object so we can
			# visualize it
			(startX, startY, endX, endY) = box.astype("int")

	# update our centroid tracker using the computed set of bounding
	# box rectangles
	objects = ct.update(rects)

	# loop over the tracked objects
	local_objects_set = set()
	for (objectID, centroid),rect in zip(objects.items(),rects):
		# draw both the ID of the object and the centroid of the
		# object on the output frame
		(startX, startY, endX, endY) = rect

		face = frame[startY:endY, startX:endX]


		if np.shape(face) == ():
			continue

		face = cv2.resize(face, (224, 224))
		

		face_rgb = cv2.cvtColor(face, cv2.COLOR_BGR2RGB)
		face_arr = img_to_array(face_rgb)
		face_arr = preprocess_input(face_arr)
		faces = [face_arr]
		faces = np.array(faces, dtype="float32")
		preds = maskNet.predict(faces, batch_size=32)
		(mask, nomask) = preds[0]

		local_objects_set.add(objectID)
		if objectID not in global_objects_set:
			global_objects_set.add(objectID)
			global_objects[objectID] = []

		if nomask > 0.9:

			label = "nomask"
			encodings = face_recognition.face_encodings(frame, [rect])
			encoding = encodings[0]
			
			matches = face_recognition.compare_faces(data["encodings"], encoding)
			name = "Unknown"
			if True in matches:
			    # find the indexes of all matched faces then initialize a
			    # dictionary to count the total number of times each face
			    # was matched
				matchedIdxs = [i for (i, b) in enumerate(matches) if b]
				counts = {}
			    # loop over the matched indexes and maintain a count for
			    # each recognized face face
				for i in matchedIdxs:
					name = data["names"][i]
					counts[name] = counts.get(name, 0) + 1
			    # determine the recognized face with the largest number of
			    # votes (note: in the event of an unlikely tie Python will
			    # select first entry in the dictionary)
				label = max(counts, key=counts.get)
				
				global_objects[objectID].append(label)
				if len(global_objects[objectID]) > 15:
					global_objects[objectID].pop(0)
					print(global_objects[objectID])
					prediction = max(set(global_objects[objectID]), key = global_objects[objectID].count)
					if prediction != "mask":
						object_prediction = list_prediction(global_objects[objectID], prediction)
						if object_prediction > 0.7:
							print("Catched = {}".format(prediction))
							now = datetime.now()
							current_time = now.strftime("%H:%M:%S")
							image_doc_name = random.randint(1, 10000000)
							cv2.imwrite("./temp_images/test.jpg",face)
							image = open('./temp_images/test.jpg', 'rb')
							ir = image.read()
							violation_img = base64.b64encode(ir)
							date_today = now.strftime("%m %d %Y")


							if label not in my_database:
								data_db = {
								'_id': label, # Setting _id is optional
								'last_violation': current_time,
								'violations': [{'day':[
								{
								'date': date_today,
								'type': "No Mask",
								'time': current_time,
								'image': image_doc_name,
								'status': "U"
								}
								]}]
								}
								my_document = my_database.create_document(data_db)
 							else:
								my_document = my_database[label]
								length = len(my_document['violations'])
								data_db = {
								'date': date_today,
								'type': "No Mask",
								'time': current_time,
								'image': image_doc_name,
								'status': "U"
								}
								prev_date = my_document['violations'][length-1]['day'][0]['date']
								if prev_date == date_today:
									my_document['violations'][length-1]['day'].append(data_db)
								else:
									my_document['violations'].append({'day':[]})
									my_document['violations'][length-1]['day'].append(data_db)

							image_data = {
							'_id': str(image_doc_name),
							'image': violation_img
							}

							image_doc = image_database.create_document(image_data)
							image_doc.save()
							my_document.save()
							global_objects.pop(objectID)
							local_objects_set.discard(objectID)
							global_objects_set.discard(objectID)



		elif mask > 0.7:
			label = "mask"
			global_objects[objectID].append(label)
			if len(global_objects[objectID]) > 15:
				global_objects[objectID].pop(0)
		else:
			label = "mask"

		text = "{}".format(label)
		cv2.putText(frame, text, (centroid[0] - 10, centroid[1] - 10),
			cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
		cv2.circle(frame, (centroid[0], centroid[1]), 4, (0, 255, 0), -1)

	elements_removed_set = set()
	elements_removed = global_objects_set - local_objects_set
	global_objects_set = local_objects_set
	for idt in elements_removed_set:
		global_objects.pop(idt)

	# show the output frame
	cv2.imshow("Frame", frame)
	key = cv2.waitKey(1) & 0xFF

	# if the `q` key was pressed, break from the loop
	if key == ord("q"):
		break

# do a bit of cleanup
cv2.destroyAllWindows()
vs.stop()
