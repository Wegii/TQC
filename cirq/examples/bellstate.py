from .exampleBase import ExampleBase

import abc
import cirq

class Bellstate(ExampleBase, metaclass=abc.ABCMeta):
    """ Circuit to generate a Bell state.

    The class creates a circuit for generating a Bell state such as 
    sqrt(2) * (|00> + |11>).
    """

    def __init__(self):
        super().__init__()

    def generate_circuit(self) -> None:
        """ See base class. """

        bell_circuit = cirq.Circuit()
        q0, q1 = cirq.LineQubit.range(2)
        bell_circuit.append(cirq.H(q0))
        bell_circuit.append(cirq.CNOT(q1,q0))
        bell_circuit.append(cirq.measure(q0, q1, key='result'))

        self.circuit = bell_circuit
