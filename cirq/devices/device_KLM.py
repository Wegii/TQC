from .deviceBase import DeviceBase

import abc
import cirq
from cirq.devices import LineQubit

class Device_KLM(DeviceBase, metaclass=abc.ABCMeta):
    """ Device using the KLM protocol.

    This class represents a device, which uses the KLM protocol. The KLM protocl
    is an implementation of linear optical quantum circuits. 

    See more at: https://en.wikipedia.org/wiki/KLM_protocol
    """

    def __init__(self, qubits_count):
        """ Inits Device_KLM.

        Args:
        qubits_count: Amount of qubits a circuit can use.
        """
        super().__init__()
        self.qubits = [LineQubit(i) for i in range(qubits_count)]

    def validate_operation(self, operation):
        if not isinstance(operation, cirq.GateOperation):
            raise ValueError('{!r} is not a supported operation'.format(operation))

        if not isinstance(operation.gate, (cirq.CXPowGate,
                                 cirq.XPowGate,
                                 cirq.HPowGate,
                                 cirq.MeasurementGate)):
            raise ValueError('{!r} is not a supported gate'.format(operation.gate))

        if len(operation.qubits) == 2:
            p, q = operation.qubits

            # Only adjacent operations are allowed, which solves the problem of 
            # crossing waveguides.
            # TODO: Elaborate!
            if not p.is_adjacent(q):
                raise ValueError('Non-local interaction: {}'.format(repr(operation)))

    def validate_circuit(self, circuit):
        for moment in circuit:
            for operation in moment.operations:
                self.validate_operation(operation)
