from enum import Enum

class Protocol(Enum):
	""" Enumeration of available protocols and approaches.

	Different approaches and protocols to physical quantum circuits require 
	different compilation of the logical quantum circuit.
	"""
	KLM = 'KLM'