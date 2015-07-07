# To execute this script, paste the following two lines in the blender console
# filename = "/home/dennisyu/Documents/Master/TopologyGen/cam10AtInter.py"
# exec(compile(open(filename).read(), filename, 'exec'))

import bpy
import random
import math

###City settings
#city size 500m^2, Seed = 520
#Create terrain = 10, Create meterials (sampling size) = 10 (texture size) = 4096, maximum height = 300, water level = 0, random options = 0
#Street texture size = 9999, slope limit = 5, Paris
#high poly models = 5, Total meterials = 10, texture size = 1024

#add camera (random position and sensing direction)
#city radius = 5000m
cameraPos = (-0.80, -0.60, 0.15)
cameraRotation = (math.pi*90.0/180, math.pi*0.0/180, math.pi*300.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (-0.80, -0.60, 0.15)
cameraRotation = (math.pi*90.0/180, math.pi*0.0/180, math.pi*290.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (-0.80, -0.60, 0.15)
cameraRotation = (math.pi*90.0/180, math.pi*0.0/180, math.pi*280.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (-0.80, -0.60, 0.15)
cameraRotation = (math.pi*90.0/180, math.pi*0.0/180, math.pi*270.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (-0.80, -0.60, 0.15)
cameraRotation = (math.pi*90.0/180, math.pi*0.0/180, math.pi*260.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);


cameraPos = (0.25, -1.00, 0.15)
cameraRotation = (math.pi*90.0/180, math.pi*0.0/180, math.pi*340.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (0.25, -1.00, 0.15)
cameraRotation = (math.pi*90.0/180, math.pi*0.0/180, math.pi*330.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (0.25, -1.00, 0.15)
cameraRotation = (math.pi*90.0/180, math.pi*0.0/180, math.pi*320.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (0.25, -1.00, 0.15)
cameraRotation = (math.pi*90.0/180, math.pi*0.0/180, math.pi*310.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (0.25, -1.00, 0.15)
cameraRotation = (math.pi*90.0/180, math.pi*0.0/180, math.pi*300.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);



bpy.data.scenes["Scene"].render.resolution_x = 1280;
bpy.data.scenes["Scene"].render.resolution_y = 720;
bpy.data.scenes["Scene"].render.resolution_percentage = 100;
# object has a attribute named type which can query the type
# print(str(object.type))
for object in bpy.data.objects:
    print(object.name+" is at location " + str(object.location))

# to setup the camera field of view(FoV)
#bpy.data.scenes["Scene"].camera.data.angle_x
#bpy.data.scenes["Scene"].camera.data.angle_y
	
	
print('\nPrint Scenes...'); 
sceneKey = bpy.data.scenes.keys()[0]; 
print('Using Scene['  + sceneKey + ']');
c=1;
logFileName="/home/dennisyu/Documents/Master/SourceData/test11/log.txt"
logFile=open(logFileName,"w+")
for obj in bpy.data.objects:
# Find cameras that match cameraNames 
    if ( obj.type =='CAMERA'): 
        print("Rendering scene["+sceneKey+"] with Camera["+obj.name+"]")
        logFile.write("Rendering scene["+sceneKey+"] with Camera["+obj.name+"]\n") 
        location = obj.location
        rotation = obj.rotation_euler 
        logFile.write("Pos "+str(location.x)+" "+str(location.y)+" "+str(location.z)+" Dir "+str(rotation.x)+" "+str(rotation.y)+" "+str(rotation.z)+"\n")
        # Set Scenes camera and output filename 
        bpy.data.scenes[sceneKey].camera = obj 

        # Render Scene and store the scene 
        bpy.ops.render.render( write_still=True ); 
        RR = "Render Result";
        bpy.data.images[RR].save_render("/home/dennisyu/Documents/Master/SourceData/test11/camera_"+str(c)+".png");
        c = c + 1; 

logFile.close()
