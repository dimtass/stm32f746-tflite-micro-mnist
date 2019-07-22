from PIL import ImageTk, Image, ImageDraw, ImageFilter
import PIL
from tkinter import *
import numpy as np

class MnistDigitDraw:
    def __init__(self, master, width, height):
        self._master = master
        self._width = width
        self._height = height
        self._mnist_width = 28
        self._mnist_height = 28
        self._output_image = PIL.Image.new('L', (self._mnist_width, self._mnist_height), (255))
        self._export_fname = 'digit.txt'

    def start(self):
        # Create a frame that will host the canvas and buttons
        self._frame = Frame(self._master)
        # Canvas for drawing
        self._canvas = Canvas(self._frame, width=self._width, height=self._height, bg='white')
        # create an empty PIL image and draw object to draw on
        self._input_image = PIL.Image.new('L', (self._width, self._height), (255))
        self._draw = ImageDraw.Draw(self._input_image)
        self._canvas.pack(expand=YES, fill=BOTH, side=LEFT)
        self._canvas.bind("<B1-Motion>", self._paint)

        # Canvas for displaying the result image
        self._img_canvas = Canvas(self._frame, width=self._width, height=self._height, bg='white')
        self._img_canvas.pack(expand=YES, fill=BOTH, side=RIGHT)
        # self._img_canvas.create_image(self._width/2, self._height/2, image=self._output_image)

        # Inference button
        self._btn_inference = Button(self._frame, text="Inference", command = self._btn_inference)
        self._btn_inference.pack(side=BOTTOM)
        # Inference button
        self._btn_export = Button(self._frame, text="Export", command = self._btn_export)
        self._btn_export.pack(side=BOTTOM)
        # Clear button
        self._btn_clear = Button(self._frame, text="Clear", command = self._btn_clear)
        self._btn_clear.pack(side=BOTTOM)
        # Add controls
        self._frame.pack()

    def _paint(self,event):
        x1, y1 = (event.x - 1), (event.y - 1)
        x2, y2 = (event.x + 1), (event.y + 1)
        self._canvas.create_oval(x1, y1, x2, y2, fill="black",width=30)
        self._draw.line([x1, y1, x2, y2],fill="black",width=30)

    def _convert_image(self):
        # First down-scale the image at mnist size
        img = self._input_image.resize((self._mnist_width,self._mnist_height), PIL.Image.ANTIALIAS).filter(ImageFilter.SHARPEN)
        # Then up-scale again to width/height
        self._output_image = ImageTk.PhotoImage(img.resize((self._width, self._height), PIL.Image.NONE))
        # Display the image in the right windows
        self._img_canvas.create_image(self._width/2, self._height/2, image=self._output_image)
        arr = self._image_to_array(img)
        return arr

    def _btn_export(self):
        """
        Exports the digit to a text file in order to import it in the jupyter notebook
        """
        # Convert the image to the MNIST format
        arr = self._convert_image()
        # Convert the image to a numpy array
        # Debug save array to file
        np.savetxt(self._export_fname, arr)
        print("Exported image to %s" % (self._export_fname))

    def _btn_inference(self):
        """
        Send the data to the stm32f746 for processing
        """
        # Convert the image to the MNIST format
        arr = self._convert_image()
        # Send the array to the MCU via serial
        print("Not implemented yet...")

    def _btn_clear(self):
        """
        Clear the image in order to re-draw
        """
        # Clear canvas
        self._canvas.delete(ALL)
        self._img_canvas.delete(ALL)
        # Clear left image
        del self._input_image
        self._input_image = PIL.Image.new('L', (self._width, self._height), (255))
        self._draw = ImageDraw.Draw(self._input_image)

    def _image_to_array(self, im):
        """
        This function returns the pixel values.
        The imput is a png file location.
        """
        tv = list(im.getdata())  # get pixel values
        # normalize pixels to 0 and 1. 0 is pure white, 1 is pure black.
        tva = [(255 - x) * 1.0 / 255.0 for x in tv]
        return tva


if __name__=="__main__":
    var = Tk()
    dd = DigitDraw(var, 250, 250)
    dd.start()
    var.mainloop()