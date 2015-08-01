# To execute this script, paste the following two lines in the blender console
# filename = "/home/dennisyu/Documents/Master/TopologyGen/cameraAtInter_diffCamNum.py"
# exec(compile(open(filename).read(), filename, 'exec'))

import bpy
import random
import math

###City settings
#city size 500m^2, Seed = 520
#Create terrain = 10, Create meterials (sampling size) = 10 (texture size) = 4096, maximum height = 300, water level = 0, random options = 0
#Street texture size = 9999, slope limit = 5, Paris
#high poly models = 5, Total meterials = 10, texture size = 1024

# way of remove object, we need to select the objects first
# gather list of items of interest.
bpy.ops.object.select_all(action="DESELECT")
# remove all objects except the city.
removeList = [item.name for item in bpy.data.objects if item.type == "CAMERA" or item.type == "LAMP"]
for obj in removeList:
	bpy.data.objects[obj].select = True
bpy.ops.object.delete()

#move all the objects
bpy.ops.object.select_all(action="SELECT")
cityObjectList = [item.name for item in bpy.data.objects if item.select == True]
for obj in cityObjectList:
	bpy.data.objects[obj].location = [-2.5, -2.5, -3.0]

# add light
scene = bpy.context.scene
lamp_data = bpy.data.lamps.new(name="sun1", type='SUN')
lamp_data.energy = 1.0
lamp_data.sky.use_sky = True
lamp_data.sky.use_atmosphere = True
lamp_object = bpy.data.objects.new(name="sun1", object_data=lamp_data)
scene.objects.link(lamp_object)
lamp_object.location = (0.0, 0.0, 10.0)
lamp_object.select = True

lamp_data = bpy.data.lamps.new(name="sun2", type='HEMI')
lamp_data.energy = 1.0
lamp_object = bpy.data.objects.new(name="sun2", object_data=lamp_data)
scene.objects.link(lamp_object)
lamp_object.location = (0.0, 0.0, 10.0)
lamp_object.select = True

scene.objects.active = lamp_object

#add camera (random position and sensing direction)
#city radius = 5000m
# Intersection 1
cameraPos = (0.16, -0.04, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*70.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (0.16, -0.04, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*60.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (0.16, -0.04, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*50.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (0.16, -0.04, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*40.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (0.16, -0.04, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*30.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (0.16, -0.04, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*20.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);

# Intersection 2
cameraPos = (1.10, 0.22, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*135.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (1.10, 0.22, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*145.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (1.10, 0.22, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*155.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (1.10, 0.22, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*165.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (1.10, 0.22, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*175.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (1.10, 0.22, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*185.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);

# Intersection 3
cameraPos = (-1.97, -0.80, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*315.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (-1.97, -0.80, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*325.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (-1.97, -0.80, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*335.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (-1.97, -0.80, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*345.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (-1.97, -0.80, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*355.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (-1.97, -0.80, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*5.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);

# Intersection 4
cameraPos = (2.3, -0.08, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*160.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (2.3, -0.08, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*150.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (2.3, -0.08, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*140.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (2.3, -0.08, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*130.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (2.3, -0.08, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*120.0/180)
bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=cameraPos, rotation=cameraRotation);
cameraPos = (2.3, -0.08, 0.2)
cameraRotation = (math.pi*70.0/180, math.pi*0.0/180, math.pi*110.0/180)
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
logFileName="/home/dennisyu/Documents/Master/SourceData/test12/log.txt"
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
        bpy.data.images[RR].save_render("/home/dennisyu/Documents/Master/SourceData/test12/camera_"+str(c)+".png");
        c = c + 1; 

logFile.close()
