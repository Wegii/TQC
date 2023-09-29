from enum import Enum

class Part(Enum):
	""" Enumeration of available parts.

	This enumeration class contains all available parts for constructing 
	photonic circuits.
	"""
	directional_standard = 'directional_standard 5 20 0.4 15'
	directional_heated = 'directional_heated 5 20 0.4 15'
	hresonator = 'hresonator'
	hdirectional = 'hdirectional'
	waveguide_sspd = 'waveguide_sspd'
	waveguide_crossing = 'waveguide_crossing'