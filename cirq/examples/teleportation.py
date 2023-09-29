from .exampleBase import ExampleBase

import abc
import cirq

class teleportation(ExampleBase, metaclass=abc.ABCMeta):
    """ Circuit to generate a bell state.
    """

    def __init__(self):
        super().__init__()

    def generate_circuit(self) -> None:
        """ See base class. """

        tel_circuit = cirq.Circuit()
        q0, q1, q2 = cirq.LineQubit.range(3)

        tel_circuit.append(cirq.H(q1))
        tel_circuit.append(cirq.CNOT(q1,q2))

        tel_circuit.append(cirq.CNOT(q0,q1))
        tel_circuit.append(cirq.H(q0))


        self.circuit = tel_circuit
