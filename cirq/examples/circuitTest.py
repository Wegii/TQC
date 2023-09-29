from .exampleBase import ExampleBase

import abc
import cirq

class CircuitTest(ExampleBase, metaclass=abc.ABCMeta):
    """ Circuit to perform tests with.

    The class creates a circuit consisting of a H, CNOT and X gate.
    """

    def __init__(self):
        super().__init__()

    def generate_circuit(self) -> None:
        """ See base class. """

        bell_circuit = cirq.Circuit()
        q0, q1, q2 = cirq.LineQubit.range(3)
        bell_circuit.append(cirq.H(q0))
        bell_circuit.append(cirq.H(q1))
        bell_circuit.append(cirq.H(q2))

        bell_circuit.append(cirq.X(q0))
        bell_circuit.append(cirq.X(q2))

        bell_circuit.append(cirq.CNOT(q1,q0))
        bell_circuit.append(cirq.CNOT(q1, q2))
        bell_circuit.append(cirq.CNOT(q1, q2))
        bell_circuit.append(cirq.CNOT(q1, q0))

        bell_circuit.append(cirq.H(q0))
        bell_circuit.append(cirq.X(q2))

        bell_circuit.append(cirq.H(q1))
        bell_circuit.append(cirq.H(q2))

        self.circuit = bell_circuit
