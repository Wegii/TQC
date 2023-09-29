from .parts import Part
from .gate import Gate
from .protocol import Protocol

import abc

class Gate_CNOT(Gate, metaclass=abc.ABCMeta):
	""" CNOT gate.

	Class representing the CNOT gate.
	"""

	def __init__(self, protocol):
		super().__init__(protocol)

	def compile(self, qubit_c, qubit_t) -> str:
		""" See base class. """
		if self.protocol == Protocol.KLM:
			return self.__compile_KLM(qubit_c, qubit_t)
		else:
			return self.__compile_KLM(qubit_c, qubit_t)
		
	def __compile_KLM(self, qubit_c, qubit_t) -> str:
		""" Construct the CNOT gate using the KLM protocol. 

		The gate consists of a left- and rightmost 50/50 directional coupler, and
		three central 67/33 directional couplers.

		Args:
		    qubit_c: Control qubit.
		    qubit_t: Target qubit to perform the operation on.
		"""
		content = '' #'_cnot:\n'

		# Check if distance between target and control is bigger than one, then
		# use waveguide crossings for swapping waveguides. The target will be 
		# shifted towards the control qubit.
		q_swap = self.__swap(qubit_c, qubit_t)
		content += q_swap

		# Construct CNOT gate
		c = qubit_c.x
		t = qubit_t.x #self.__get_target()
		#print("c" + str(c) + " - t" + str(t))

		# First 50:50 DC
		i = str(2*t)
		o = str(2*t + 1)
		content += Part.directional_standard.value + ' (' + o + ',' + i + ') (' + o + ',' + i + ')' + '\n'

		# Central three 67:33 DCs
		i = str(2*c)
		ii = str(2*c - 1)
		i2 = str(2*t)
		o = str(2*c + 1)
		content += Part.directional_standard.value + ' (~,' + o + ') (~,' + o + ')' + '\n'
		content += Part.directional_standard.value + ' (' + i + ',' + ii + ') (' + i + ',' + ii + ')' + '\n'
		content += Part.directional_standard.value + ' (' + i2 + ',~) (' + i2 + ',~)' + '\n'

		# Second 50:50 DC
		i = str(2*t)
		o = str(2*t+1)
		content += Part.directional_standard.value + ' (' + o + ',' + i + ') (' + o + ',' + i + ')' + '\n'

		# Swap qubits back, if necessary
		content += q_swap

		return content

	def __get_target(self, qubit_c, qubit_t) -> int:
		""" Return target qubit.
		
		Depending on the logical distance between both qubits, the target qubit
		will be shifted towards the control qubit.

		Args:
			qubit_c: Control qubit.
			qubit_t: Target qubit.
		"""
		if qubit_t.x < qubit_c:
			return qubit_c.x - 1
		else:
			return qubit_c.x + 1

	def __swap(self, qubit_c, qubit_t):
		""" See base class. """
		if abs(qubit_t.x - qubit_c.x) > 1:
			return super().swap(qubit_c, qubit_t)
		else:
			return ''



class Gate_H(Gate, metaclass=abc.ABCMeta):
	""" Hadamard gate.

	Class representing the Hadamard gate.
	"""

	def __init__(self, protocol):
		super().__init__(protocol)

	def compile(self, qubit_t) -> str:
		""" See base class. """

		if self.protocol == Protocol.KLM:
			return self.__compile_KLM(qubit_t)
		else:
			return self.__compile_KLM(qubit_t)

	def __compile_KLM(self, qubit_t) -> str:
		""" Construct the Hadamard gate.

		The gate consists of a single 50/50 directional coupler.

		Args:
		    qubit_t: Target qubit to perform the operation on.
		"""
		content = '' #'_H:\n'
		i = str(2*qubit_t.x)
		o = str(2*qubit_t.x + 1)
		content += Part.directional_standard.value + ' (' + o + ',' + i + ') (' + o + ',' + i + ')' + '\n'

		return content 
	    


class Gate_X(Gate, metaclass=abc.ABCMeta):
	""" Pauli-X gate.

	Class representing the Pauli-X gate.
	"""

	def __init__(self, protocol):
		super().__init__(protocol)

	def compile(self, qubit_t) -> str:
		""" See base class. """

		if self.protocol == Protocol.KLM:
			return self.__compile_KLM(qubit_t)
		else:
			return self.__compile_KLM(qubit_t)

	def __compile_KLM(self, qubit_t) -> str:
		""" Construct the Pauli-X gate.

	    The gate consists of a single waveguide crossing.
	    Args:	        
	    	qubit_t: Target qubit to perform the operation on.
	    """
		content = '' #'_X:\n'

		i = str(2*qubit_t.x)
		o = str(2*qubit_t.x + 1)
		content += Part.waveguide_crossing.value + ' (' + o + ',' + i + ') (' + o + ',' + i + ')' + '\n'

		return content
