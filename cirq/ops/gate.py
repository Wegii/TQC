from .parts import Part

class Gate:
	""" Abstract class representing a gate.

	Class representing a arbitrary gate to compile.
	
	Attributes:
		protocol: Physical protocol to compile to.
	"""
	protocol = None

	def __init__(self, protocol):
		self.protocol = protocol

	def compile(self):
		""" Compile the gate.
		
		Depending on the specified protocol
		
		"""
		raise NotImplementedError

	def swap(self, qubit1, qubit2) -> str:
		""" Swap qubits.

		Swap qubit1 with qubit2. Qubits are physically implemented using the
		dual-rail enconding.

		Args:
			qubit1: Starting qubit.
			qubit2: Ending qubit.
		"""
		content = ''

		# TODO: Check which of the two qubits is the lower one
		# TODO: Check if swapping with multiple qubits works

		low = qubit1.x
		upper = qubit2.x

		print(2*low + 3)
		print(upper)
		# Swap qubits until both qubits are adjacent
		while 2*low + 3 <= upper + 1:
			i = str(2*low)
			o = str(2*low + 1)
			i1 = str(2*low + 2)
			o1 = str(2*low + 3)
			content += Part.waveguide_crossing.value + ' (' + i1 + ',' + o + ') (' + i1 + ',' + o + ')' + '\n'

			content += Part.waveguide_crossing.value + ' (' + o + ',' + i + ') (' + o + ',' + i + ')' + '\n'
			content += Part.waveguide_crossing.value + ' (' + o1 + ',' + i1 + ') (' + o1 + ',' + i1 + ')' + '\n'
			
			content += Part.waveguide_crossing.value + ' (' + i1 + ',' + o + ') (' + i1 + ',' + o + ')' + '\n'

			# Swap next qubits
			low += 2

		return content + '\n'
