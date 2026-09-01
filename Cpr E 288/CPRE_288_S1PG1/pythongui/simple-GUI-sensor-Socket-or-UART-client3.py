import serial
import time
import socket
import tkinter as tk
import threading
import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import NavigationToolbar2Tk

absolute_path = os.path.dirname(__file__)
relative_path = "./"
full_path = os.path.join(absolute_path, relative_path)
filename = 'sensor-scan.txt'

# Global variables
window = None
Last_command_Label = None
gui_send_message = None
global ax

# Main function to set up and start the GUI
def main():
    global window, Last_command_Label, gui_send_message, canvas_widget
    window = tk.Tk()
    window.title("CyBot Control Panel")
    window.geometry("650x1000")  # Set the initial size of the window

    logo_path = os.path.join(absolute_path, "logo.png")
    logo_image = tk.PhotoImage(file=logo_path)

    resized_logo = logo_image.subsample(10, 10)

    logo_label = tk.Label(window, image=resized_logo)
    logo_label.pack(side=tk.TOP, padx=5, pady=5)
    

    Last_command_Label = tk.Label(window, text="Last Command Sent:")
    Last_command_Label.pack(pady=10)

    create_button("Press to Quit", send_quit).pack(pady=5)

    movement_frame = tk.Frame(window)
    movement_frame.pack(pady=10)
    create_button("Forward", send_forward, movement_frame).grid(row=0, column=0, padx=5)
    create_button("Reverse", send_reverse, movement_frame).grid(row=0, column=1, padx=5)
    create_button("Left", send_left, movement_frame).grid(row=1, column=0, padx=5)
    create_button("Right", send_right, movement_frame).grid(row=1, column=1, padx=5)
    create_button("Stop", send_stop, movement_frame).grid(row=2, column=0, columnspan=2, pady=5)

    create_button("Press to Scan", send_scan).pack(pady=10)

    create_button("Collect Data", send_collect).pack()
    create_button("Toggle", send_toggle).pack()

    canvas_widget = display_polar_plot(filename)

    my_thread = threading.Thread(target=socket_thread)
    my_thread.start()

    window.mainloop()

# Function to create a button with common styling
def create_button(text, command, parent=None):
    button = tk.Button(parent if parent else window, text=text, command=command, width=15, height=2)
    return button

# Function to display the polar plot
def display_polar_plot(filename):
    global ax, window

    # Check if the plot already exists
    if hasattr(window, 'canvas'):
        update_plot(filename, window.canvas)
        return window.canvas

    file_object = open(full_path + filename, 'r')
    file_header = file_object.readline()
    file_data = file_object.readlines()
    file_object.close()

    angle_degrees = []
    distance = []

    for line in file_data:
        data = line.split()
        angle_degrees.append(float(data[0]))
        distance.append(float(data[1]))

    angle_degrees = np.array(angle_degrees)
    angle_radians = (np.pi / 180) * angle_degrees

    fig, ax = plt.subplots(subplot_kw={'projection': 'polar'})
    ax.plot(angle_radians, distance, color='r', linewidth=4.0)
    ax.set_xlabel('Distance (m)', fontsize=14.0)
    ax.set_ylabel('Angle (degrees)', fontsize=14.0)
    ax.xaxis.set_label_coords(0.5, 0.15)
    ax.tick_params(axis='both', which='major', labelsize=14)
    ax.set_rmax(2.5)
    ax.set_rticks([0.5, 1, 1.5, 2, 2.5])
    ax.set_rlabel_position(-22.5)
    ax.set_thetamax(180)
    ax.set_xticks(np.arange(0, np.pi + 0.1, np.pi / 4))
    ax.grid(True)
    ax.set_title("Mock-up Polar Plot of CyBot Sensor Scan from 0 to 180 Degrees", size=14, y=1.0, pad=-24)

    canvas = FigureCanvasTkAgg(fig, master=window)
    canvas_widget = canvas.get_tk_widget()
    canvas_widget.pack()

    toolbar = NavigationToolbar2Tk(canvas, window)
    toolbar.update()
    canvas_widget.pack()

    # Store the canvas, figure, and axis as attributes of the window
    window.canvas = canvas
    window.fig = fig
    window.ax = ax

    return canvas


def update_plot(filename, canvas_widget):
    global window
    # Open the file and read data
    file_object = open(full_path + filename, 'r')
    file_header = file_object.readline()
    file_data = file_object.readlines()
    file_object.close()

    angle_degrees = []
    distance = []

    for line in file_data:
        data = line.split()
        angle_degrees.append(float(data[0]))
        distance.append(float(data[1]))

    angle_degrees = np.array(angle_degrees)
    angle_radians = (np.pi / 180) * angle_degrees

    # Update the existing plot
    window.ax.clear()
    window.ax.plot(angle_radians, distance, color='r', linewidth=4.0)
    window.ax.set_xlabel('Distance (m)', fontsize=14.0, color='white')
    window.ax.set_ylabel('Angle (degrees)', fontsize=14.0, color='white')
    window.ax.xaxis.set_label_coords(0.5, 0.15)
    window.ax.tick_params(axis='both', which='major', labelsize=14, labelcolor='white')
    window.ax.set_rmax(2.5)
    window.ax.set_rticks([0.5, 1, 1.5, 2, 2.5])
    window.ax.set_rlabel_position(-22.5)
    window.ax.set_thetamax(180)
    window.ax.set_xticks(np.arange(0, np.pi + 0.1, np.pi / 4))
    window.ax.grid(True)
    window.ax.set_title("Mock-up Polar Plot of CyBot Sensor Scan from 0 to 180 Degrees", size=14, y=1.0, pad=-24, color='white')

    # Redraw the canvas
    window.canvas.draw()

    # Update the canvas reference
    canvas_widget.get_tk_widget().pack_forget()
    canvas_widget.get_tk_widget().pack()

# Functions for button actions
def send_quit():
    global gui_send_message
    gui_send_message = "quit\n"
    time.sleep(1)
    window.destroy()

def send_scan():
    global gui_send_message
    gui_send_message = "l\n"

    # Wait for the scan to complete
    #time.sleep(25)  # You might need to adjust the delay based on how long the scan takes

    # After the scan is complete, update the plot
    #send_collect()

def send_toggle():
    global gui_send_message
    gui_send_message = "tl\n"

def send_forward():
    global gui_send_message
    gui_send_message = "w\n"

def send_collect():
    global gui_send_message
    gui_send_message = "1\n"
    update_plot(filename, canvas_widget)

def send_reverse():
    global gui_send_message
    gui_send_message = "s\n"

def send_left():
    global gui_send_message
    gui_send_message = "a\n"

def send_right():
    global gui_send_message
    gui_send_message = "d\n"

def send_stop():
    global gui_send_message
    gui_send_message = "e\n"

def socket_thread():
    global Last_command_Label, gui_send_message, canvas_widget

    absolute_path = os.path.dirname(__file__)
    relative_path = "./"
    full_path = os.path.join(absolute_path, relative_path)
    filename = 'sensor-scan.txt'

    HOST = "192.168.1.1"
    PORT = 288
    cybot_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    cybot_socket.connect((HOST, PORT))
    cybot = cybot_socket.makefile("rbw", buffering=0)

    send_message = "Ready!\n"
    gui_send_message = "wait\n"

    cybot.write(send_message.encode())
    print("Sent to server: " + send_message)

    while send_message != 'quit\n':
        command_display = "Last Command Sent:\t" + send_message
        Last_command_Label.config(text=command_display)

        if (send_message == "l\n") or (send_message == "w\n") or (send_message == "s\n") or \
                (send_message == "a\n") or (send_message == "d\n") or (send_message == "t\n") or (send_message == "1\n"):
            rx_message = bytearray(1)
            #file_object = open(full_path + filename, 'w')
            cybot.write(send_message.encode())
            
            if (send_message == "l\n") or (send_message == "1\n"):
                file_object = open(full_path + filename, 'w')
                while (rx_message.decode() != "\rend\n" and rx_message.decode() != "end\n"):
                    rx_message = cybot.readline()
                    file_object.write(rx_message.decode())
                    print(rx_message.decode())
            

                file_object.close()
                #update_plot(filename, canvas_widget)
            
            elif (send_message == "w\n") or (send_message == "s\n") or \
                (send_message == "a\n") or (send_message == "d\n") or (send_message == "tl\n"):
                while (rx_message.decode() != "\rend\n" and rx_message.decode() != "end\n"):
                    rx_message = cybot.readline()

        else:
            print("Waiting for server reply\n")
            rx_message = cybot.readline()
            print("Got a message from server: " + rx_message.decode() + "\n")

        while gui_send_message == "wait\n":
            time.sleep(.1)
        send_message = gui_send_message

        gui_send_message = "wait\n"

        cybot.write(send_message.encode())

    print("Client exiting, and closing file descriptor, and/or network socket\n")
    time.sleep(2)
    cybot.close()
    cybot_socket.close()

main()