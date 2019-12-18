import requests
import json
import os
import sys
import re
import time
from pprint import pprint
# from lxml import etree
import cgi

class API:
	def __init__(self, ip, port, username, password):
		requests.packages.urllib3.disable_warnings() 
		self.url = 'http://{ip}:{port}'.format(ip=ip, port=port)
		self.session = requests.session()
		self.username = username
		self.password = password
		
	def enable_secure(self):
		import string
		self.url = string.replace(self.url, 'http:', 'https:')
		
	def api_login(self, ip, sub_url):
		
		target_url = self.url+sub_url
		print target_url
		target_url += '?return_to_anchor=&login='+self.username+'&password='+self.password+'&remember_me=1&commit='
		r = self.session.post(target_url, data='', verify=False)
		if r.status_code != 200:
			print 'Unable to login correctly!'
			return False
		else:
			if self.api_verify_login(ip):
				print 'Login successfully!'
				return True
			else:
				return False

	def api_logout(self,ip, sub_url):
		target_url=sub_url
		print target_url
		self.api_get(target_url)
		
		if not self.api_verify_login():
			print 'Logout successfully!'
			return True
		else:
			return False

	def api_delete(self, url, ifjson=False, status_code=False):
		target_url = self.url+url
		print target_url
		r = self.session.delete(target_url, verify=False)
		print r.status_code
		print r.text
		print r.json
		time.sleep(1)
		if r.status_code == 200:
			if ifjson:
				return r.status_code, r.json()
			else:
				return r.status_code, r.content
		else:
			error_json_response = {"status_code": r.status_code}
			return r.status_code, error_json_response

	def api_delete_with_data(self, url, data, ifjson=False, status_code=False, ifdata=True):
		target_url = self.url+url
		headers={'content-type':'application/json'}
		print target_url
		print data
		r = ''
		if ifdata:
			r = self.session.delete(target_url, data=json.dumps(data), verify=False,headers=headers)
		else:
			r = self.session.delete(target_url, json=data, verify=False)
		print r.status_code
		print r.text
		if r.status_code == 200:
			if ifjson:
				return r.status_code, r.json()
			else:
				return r.status_code, r.content
		else:
			error_json_response = {"status_code": r.status_code}
			print r.content
			return r.status_code, error_json_response


	def api_get(self, url, ifjson=False, status_code=False):
		target_url = self.url+url
		print target_url
		r = self.session.get(target_url, verify=False)
		print r.status_code
		print r.text
		print r.json
		if ifjson:
			return r.status_code, r.json()
		else:
			return r.status_code, r.content
	
	def api_get1(self, url, headers = None):
		target_url = self.url+url
		print "*HTML* input body: " + str(target_url)
		if headers == None:
			r = self.session.get(target_url)
		else:
			r = self.session.get(target_url, headers=headers)
		try:
			return r.status_code, r.json()
		except:
			return r.status_code, r.text
	def api_put(self, url, data, ifjson=False, status_code=False, ifdata=True):
		target_url = self.url+url
		print target_url
		print data
		r = ''
		if ifdata:
			r = self.session.put(target_url, data=json.dumps(data), verify=False)
		else:
			r = self.session.put(target_url, json=data, verify=False)
		print r.status_code
		print r.text
		print r.json
		time.sleep(1)	
		if ifjson:
			return r.status_code, r.json()
		else:
			return r.status_code, r.content
	def api_put1(self, url, data, ifjson=False, status_code=False, ifdata=True, headers=None):
		target_url = self.url+url
		print target_url
		print data
		r = ''
		if ifdata:
			r = self.session.put(target_url, data=json.dumps(data), verify=False, headers=headers)
		else:
			r = self.session.put(target_url, json=data, verify=False, headers=headers)
		print r.status_code
		print r.text
		print r.json
		time.sleep(1)	
		if ifjson:
			return r.status_code, r.json()
		else:
			return r.status_code, r.content
	# ifjson = if the request is sent from Json format
	# ifdata = if the request is sent from Json format
	def api_post(self, url, data, ifjson=True, status_code=True, somthing=False):
		target_url = self.url+url
		print "*HTML* input body: " + str(data)
		if ifjson:
			headers={'content-type': "application/json"}			
			r = self.session.post(target_url, data=json.dumps(data),headers=headers)
			
		else:
			r = self.session.post(target_url, data=data)
		if status_code:
			return r.status_code, r.json()
		else:
			return r.content

	def api_post1(self, url, data, ifjson=True, status_code=True, headers=None):
		target_url = self.url+url
		print "*HTML* input body: " + str(target_url)
		print "*HTML* input body: " + str(data)
		print "*HTML* input body: " + str(headers)
		if ifjson:
					if headers == None:
						r = self.session.post(target_url, json=data)
					else:
						r = self.session.post(target_url, data=json.dumps(data), headers=headers)			
		else:
					if headers == None:
						r = self.session.post(target_url, json=data)
					else:
						r = self.session.post(target_url, data=data, headers=headers)					
		if status_code:
			return r.status_code, r.json()
		else:
			return r.content

	def api_post2(self, url, data, ifjson=True, status_code=True, headers = None):
		target_url = self.url+url
		if headers == None:
			r = self.session.post(target_url, json=data)
		else:
			r = self.session.post(target_url, data=data, headers=headers)
			print "*HTML* am here: " + str(headers)
		try:
			return r.status_code, r.json()
		except:
			return r.status_code, r.text

	def compare_json_objects(self, a, b):
		a, b = json.dumps(a, sort_keys=True), json.dumps(b, sort_keys=True)
		print a
		print b
		result = False
		if cmp(a,b) == 0:
			print 'Yes, these two json objects are the same.'
			result = True
		else:
				print 'No, these two json objects are not the same.'
				result = False
		return result

	def download_file(self, url, filename, size=False):
		if os.path.isfile(filename):
			os.remove(filename)
		import urllib
		urllib.urlretrieve(url, filename)
		file_size = os.path.getsize(filename)
		if not os.path.isfile(filename):
			print filename+' is not there!'
			return False
		if not size:
			return True
		if file_size != long(size):
			print str(file_size)+' != '+size
			return False
		print str(file_size)+' = '+size
		return True

	def api_post_file(self, url,file_key,file_path,data,ifjson=False, status_code=False):
 		target_url = self.url+url
 		print target_url
 		r = self.session.post(target_url, files={file_key: open(file_path, 'rb')}, data=data, verify=False)
 		print r.status_code
 		print r.text
 		if ifjson:
 			return r.status_code, r.json()
 		else:
 			return r.status_code, r.content

 	def api_download_file(self, url, local_path, ifjson=False ,status_code=False):
 		target_url = self.url+url
 		r = self.session.get(target_url, stream=True)
 		try:
	 		with open (local_path+cgi.parse_header(r.headers['Content-Disposition'])[-1]['filename'], 'wb') as f:
	 			f.write(r.content)
	 	except:
	 		None
 		if ifjson:
 			return r.status_code, r.json()
 		else:
 			return r.status_code, r.content

 	def api_download_file_with_name(self, url, local_path, ifjson=False ,status_code=False):
 		target_url = self.url+url
 		r = self.session.get(target_url, stream=True)
 		try:
	 		with open (local_path+cgi.parse_header(r.headers['Content-Disposition'])[-1]['filename'], 'wb') as f:
	 			f.write(r.content)
	 	except:
	 		None
 		if ifjson:
 			return r.status_code, r.json(), cgi.parse_header(r.headers['Content-Disposition'])[-1]['filename']
 		elif r.status_code!=200:
 			return r.status_code, r.content, r.status_code
 		else:
 			return r.status_code, r.content, cgi.parse_header(r.headers['Content-Disposition'])[-1]['filename']

 	def api_put_with_url(self, url, data, headers = None):
		target_url = url
		print target_url
		print data
		r = ''
		if headers == None:
			r = self.session.put(target_url, json=data)
		else:
			r = self.session.put(target_url, data=data, headers=headers)
		return r.status_code, r.json()
		
	