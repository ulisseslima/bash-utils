# pip install pyttsx3
import sys, pyttsx3

text = sys.argv[1]

engine = pyttsx3.init()
engine.say(text)
engine.runAndWait()
