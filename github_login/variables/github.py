# coding: utf-8
import os
import datetime
import time
import base64
import requests
import re
import sys
import random
import string
from os.path import abspath, join, dirname
import json

Login_Page_XP='//*[@id="login"]/form'
Username_title_XP='//*[@id="login"]/form//label[@for="login_field"]'
Passowrd_title_XP='//*[@id="login"]/form//label[@for="password"]'
Forgot_password_XP='//*[@id="login"]/form//a[@class="label-link"]'
Username_input_XP='//*[@id="login_field"]'   
Passowrd_input_XP='//*[@id="password"] '  
SUBMIT_BUTTON_XPATH='//*[@id="login"]//input[@type="submit"]'
Repositories_XP='//div[@class="js-repos-container"]/h2'