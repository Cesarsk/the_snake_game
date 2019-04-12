from Tkinter import *
from PIL import Image, ImageTk
import shutil
import os
import datetime

# Utils functions
def slideImage():
      # First one is for Mac
      file = os.getcwd()+'/downloads/the_snake_game/romEditor/resources/imgs'+str(setSelected)+'.bin'
      # file = os.getcwd()+'\\resources\\imgs'+str(setSelected)+'.bin'
      # Change Image Accordingly to setSelected
      img = ImageTk.PhotoImage(Image.open(file))
      panel.configure(image=img)
      panel.image = img

# onClick functions
def applyClicked():
   lbl.configure(text="Layout has been applied. Enjoy!")
   # Load .VHD to change
   # First one is for Mac
   originalFile = os.getcwd()+'/downloads/the_snake_game/vhdl_files/logic/gui/stages.vhd'
   backupFile = os.getcwd()+'downloads/the_snake_game/romEditor/backups/stages.bak'
   #originalFile = os.getcwd()+'\\..\\vhdl_files\\logic\\gui\\stages.vhd'
   #backupFile = os.getcwd()+'\\backups\\stages.bak'
   # Load new .VHD
   # First one is for Mac
   newFile = os.getcwd()+'/downloads/the_snake_game/romEditor/resources/set'+str(setSelected)+'.dat'
   #newFile = os.getcwd()+'\\resources\\set'+str(setSelected)+'.dat'
   # Save a backup file of .VHD to overwrite
   shutil.copyfile(originalFile, backupFile)  
   # Replace old .VHD to new .VHD
   shutil.copyfile(newFile,originalFile)

def leftClicked():
      lbl.configure(text="Pick the layout you like the most!")
      global setSelected
      if setSelected == 1:
            setSelected = 3
            lbl.configure(text="Selected Layout: "+str(setSelected))
            slideImage()

      elif setSelected == 2:
            setSelected = 1
            lbl.configure(text="Selected Layout: "+str(setSelected))
            slideImage()
      else:
            setSelected = 2
            lbl.configure(text="Selected Layout: "+str(setSelected))
            slideImage()
                  
def rightClicked():
      lbl.configure(text="Pick the layout you like the most!")
      global setSelected
      if setSelected == 1:
            setSelected = 2
            lbl.configure(text="Selected Layout: "+str(setSelected))
            slideImage()

      elif setSelected == 2:
            setSelected = 3
            lbl.configure(text="Selected Layout: "+str(setSelected))
            slideImage()
      else:
            setSelected = 1
            lbl.configure(text="Selected Layout: "+str(setSelected))
            slideImage()
      
# Init frame
frame = Tk() 
frame.title("Snake Level Editor")

# Define variables
setSelected = 1

# First for Mac, second for Windows
file = os.getcwd()+'/downloads/the_snake_game/romEditor/resources/imgs'+str(setSelected)+'.bin'
# file = os.getcwd()+'\\resources\\imgs'+str(setSelected)+'.bin'

# Defining Components on Frame
head = Label(frame, text="Pick the layout you like the most!", font=("Helvetica",14))
lbl = Label(frame, text="Selected Layout: "+str(setSelected), font=("Helvetica",14))
lbl2 = Label(frame, text="NOTE: Remember to re-compile the project to apply changes", font=("Helvetica",10))
btnleft = Button(frame, text="PREVIOUS", bg="white", fg="black", command=leftClicked)
btnright = Button(frame, text="NEXT", bg="white", fg="black", command=rightClicked)
btn = Button(frame, text="APPLY LAYOUT", bg="white", fg="black", command=applyClicked)

# Defining Components on Frame
img = Image.open(file)
pic = ImageTk.PhotoImage(img)
panel = Label(frame, image = pic)

# Positioning Components on Frame
head.pack(side = "top")
lbl.pack(after = head)
lbl2.pack(after = lbl)
panel.pack(after = lbl2, fill = "both", expand = "yes")
btn.pack(after = panel, side = BOTTOM)
btnleft.pack(side=LEFT)
btnright.pack(side=RIGHT)

# Starting Frame
frame.mainloop()